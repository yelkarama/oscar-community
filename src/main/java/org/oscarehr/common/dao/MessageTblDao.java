/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.common.dao;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Query;

import org.apache.log4j.Logger;
import org.oscarehr.common.model.MessageTbl;
import org.oscarehr.common.model.MsgDemoMap;
import org.oscarehr.common.model.OscarCommLocations;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;
import org.springframework.stereotype.Repository;
import oscar.oscarMessenger.data.MsgDisplayMessage;
import oscar.oscarMessenger.pageUtil.MsgDisplayMessagesBean;

@Repository
@SuppressWarnings("unchecked")
public class MessageTblDao extends AbstractDao<MessageTbl>{
    private static Logger logger = MiscUtils.getLogger();

	public MessageTblDao() {
		super(MessageTbl.class);
	}
	
	public List<MessageTbl> findByMaps(List<MsgDemoMap> m) {
		String sql = "select x from MessageTbl x where x.id in (:m)";
    	Query query = entityManager.createQuery(sql);
    	List<Integer> ids = new ArrayList<Integer>();
    	for(MsgDemoMap temp:m) {
    		ids.add(temp.getMessageID());
    	}
    	query.setParameter("m", ids);
        List<MessageTbl> results = query.getResultList();
        return results;
	}
	
	public List<MessageTbl> findByProviderAndSendBy(String providerNo, Integer sendBy) {
		Query query = createQuery("m", "m.sentByNo = :providerNo and m.sentByLocation = :sendBy");
		query.setParameter("providerNo", providerNo);
		query.setParameter("sendBy", sendBy);
		return query.getResultList();
	}

	public List<MessageTbl> findByIds(List<Integer> ids) {
		Query query = createQuery("m", "m.id in (:ids) order by m.date");
		query.setParameter("ids", ids);
		return query.getResultList();
    }

    public List<MsgDisplayMessage> findBySentToProviderAndStartDateAndEndDate(List<String> providerNos, Date startDate, Date endDate, String orderBy, int page) {
        List<MsgDisplayMessage> results = new ArrayList<MsgDisplayMessage>();
        StringBuilder sql = new StringBuilder();
        OscarCommLocationsDao oscarCommLocationsDao = SpringUtils.getBean(OscarCommLocationsDao.class);
        List<OscarCommLocations> comms = oscarCommLocationsDao.findByCurrent1(1);
        OscarCommLocations currentLocation = comms.isEmpty() ? null : comms.get(0);

        sql.append("SELECT m.messageid, mdm.demographic_no, ml.status,  m.thesubject, m.thedate, m.theime, m.attachment, m.pdfattachment, m.sentby, m.sentto, sentByProv.specialty, ml.provider_no AS sentToProviderNo, sentToProv.specialty ");
        sql.append("FROM messagetbl m LEFT JOIN msgDemoMap mdm ON mdm.messageID = m.messageid LEFT JOIN messagelisttbl ml ON ml.message = m.messageid ");
        sql.append("LEFT JOIN provider sentByProv ON sentByProv.provider_no = m.sentbyNo LEFT JOIN provider sentToProv ON sentToProv.provider_no = ml.provider_no ");
        sql.append(createBySentToProviderAndStartDateAndEndDateWhereSql(providerNos, startDate, endDate, currentLocation));
        
        String orderBySql = "ORDER BY " + MsgDisplayMessagesBean.getOrderBy(orderBy) + " ";
        sql.append(orderBySql);
        
        if (page > 0) {
            int recordsToDisplay = 25;
            int fromRecordNum = (recordsToDisplay * page) - recordsToDisplay;
            String limitSql = "limit " + fromRecordNum + ", " + recordsToDisplay;
            sql.append(limitSql);
        }

        Query query = entityManager.createNativeQuery(sql.toString());
        
        if (providerNos != null && !providerNos.isEmpty()) { query.setParameter("providerNos", providerNos); }
        if (startDate != null) { query.setParameter("startDate", startDate); }
        if (endDate != null) { query.setParameter("endDate", endDate); }
        if (currentLocation != null) { query.setParameter("remoteLocation", currentLocation.getId()); }
        

        try {
            List<Object[]> resultObjects = query.getResultList();
            for (Object[] resultObject : resultObjects) {

                MsgDisplayMessage dm = new MsgDisplayMessage();
                dm.messageId = String.valueOf(resultObject[0]);
                dm.demographic_no = String.valueOf(resultObject[1]);
                dm.status = String.valueOf(resultObject[2]);
                dm.thesubject = String.valueOf(resultObject[3]);
                dm.thedate = String.valueOf(resultObject[4]);
                dm.theime = String.valueOf(resultObject[5]);
                dm.attach = (String.valueOf(resultObject[6]) == null) ? "0" : "1";
                dm.pdfAttach = (String.valueOf(resultObject[7]) == null) ? "0" : "1";
                dm.sentby = String.valueOf(resultObject[8]);
                dm.sentto = String.valueOf(resultObject[9]);
                dm.setSentBySpecialty(String.valueOf(resultObject[10]));
                dm.setSentToProviderNo(String.valueOf(resultObject[11]));
                dm.setSentToSpecialty(String.valueOf(resultObject[12]));

                results.add(dm);
            }
        } catch (Exception e) {
            logger.error("Error", e);
        }

        return results;
    }
    
    public Integer findBySentToProviderAndStartDateAndEndDateCount(List<String> providerNos, Date startDate, Date endDate) {
        OscarCommLocationsDao oscarCommLocationsDao = SpringUtils.getBean(OscarCommLocationsDao.class);
        List<OscarCommLocations> comms = oscarCommLocationsDao.findByCurrent1(1);
        OscarCommLocations currentLocation = comms.isEmpty() ? null : comms.get(0);
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(m.messageid) ");
        sql.append("FROM messagetbl m LEFT JOIN msgDemoMap mdm ON mdm.messageID = m.messageid LEFT JOIN messagelisttbl ml ON ml.message = m.messageid ");
        sql.append(createBySentToProviderAndStartDateAndEndDateWhereSql(providerNos, startDate, endDate, currentLocation));

        Query query = entityManager.createNativeQuery(sql.toString());

        if (providerNos != null && !providerNos.isEmpty()) { query.setParameter("providerNos", providerNos); }
        if (startDate != null) { query.setParameter("startDate", startDate); }
        if (endDate != null) { query.setParameter("endDate", endDate); }
        if (currentLocation != null) { query.setParameter("remoteLocation", currentLocation.getId()); }

        return ((BigInteger) query.getSingleResult()).intValue();
    }
    
    private String createBySentToProviderAndStartDateAndEndDateWhereSql(List<String> providerNos, Date startDate, Date endDate, OscarCommLocations currentLocation) {
        StringBuilder sql = new StringBuilder();
        sql.append("WHERE ml.status NOT LIKE 'del' ");
        if (providerNos != null && !providerNos.isEmpty()) { sql.append("AND ml.provider_no IN (:providerNos) "); }//= :providerNo "); }
        if (startDate != null) { sql.append("AND m.thedate >= :startDate "); }
        if (endDate != null) { sql.append("AND m.thedate <= :endDate "); }
        if (currentLocation != null) { sql.append("AND remoteLocation = :remoteLocation "); }
        
        return sql.toString();
    }
    
    public List<MessageTbl> getByDemographicNo(String demographicNo) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT m.* FROM messagetbl m ");
        sql.append("LEFT JOIN msgDemoMap d ON d.messageID = m.messageid ");
        sql.append("WHERE d.demographic_no = :demographicNo ");
        sql.append("ORDER BY m.thedate DESC, m.theime DESC");
        
        Query query = entityManager.createNativeQuery(sql.toString(), MessageTbl.class);
        query.setParameter("demographicNo", demographicNo);

        List<MessageTbl> messages = query.getResultList();
	    
	    return messages;
    }
}
