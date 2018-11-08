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
package org.oscarehr.common;

import java.util.Date;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.oscarehr.PMmodule.dao.ProviderDao;
import org.oscarehr.common.dao.ScheduleDateDao;
import org.oscarehr.common.dao.ScheduleTemplateDao;
import org.oscarehr.common.dao.UserPropertyDAO;
import org.oscarehr.common.model.Provider;
import org.oscarehr.common.model.ScheduleDate;
import org.oscarehr.common.model.ScheduleTemplate;
import org.oscarehr.common.model.ScheduleTemplatePrimaryKey;
import org.oscarehr.common.model.UserProperty;
import org.oscarehr.util.LoggedInInfo;
import org.oscarehr.util.MiscUtils;
import org.oscarehr.util.SpringUtils;

public class GroupProviderUtil {

	ProviderDao providerDao = SpringUtils.getBean(ProviderDao.class);
	UserPropertyDAO userPropertyDAO = SpringUtils.getBean(UserPropertyDAO.class);
	ScheduleTemplateDao scheduleTemplateDAO = SpringUtils.getBean(ScheduleTemplateDao.class);
	ScheduleDateDao scheduleDateDao = SpringUtils.getBean(ScheduleDateDao.class);
	
	Logger logger = MiscUtils.getLogger();
	
	public boolean cloneExistingGroupProvider(LoggedInInfo loggedInInfo, String providerNo, String firstName, String lastName, String seriesName, String startDate, String endDate, String[] daysOfWeek) {
		Provider existingProvider = providerDao.getProvider(providerNo);
		
		if(existingProvider == null) {
			logger.warn("existing provider not found");
			return false;
		}
		
		Provider provider  = new Provider();
		try {
			BeanUtils.copyProperties(provider, existingProvider);
		}catch(Exception e) {
			logger.warn("Error",e);
			return false;
		}
		int i=1;
		provider.setProviderNo(null);
		do {
			if(providerDao.getProvider(String.valueOf(i)) == null) {
				provider.setProviderNo(String.valueOf(i));
			}
			i++;
		}while(provider.getProviderNo() == null);
		
		provider.setLastName(lastName);
		provider.setFirstName(firstName);
		provider.setLastUpdateDate(new Date());
		provider.setLastUpdateUser(loggedInInfo.getLoggedInProviderNo());
		
		providerDao.saveProvider(provider);
		
		//set the properties
		userPropertyDAO.saveProp(provider.getProviderNo(), "groupModule", "true");
		userPropertyDAO.saveProp(provider.getProviderNo(), "seriesName", seriesName);
		userPropertyDAO.saveProp(provider.getProviderNo(), "createdBy", loggedInInfo.getLoggedInProviderNo());
		
		copyProperty(providerNo,provider.getProviderNo(),"dropIn");
		copyProperty(providerNo,provider.getProviderNo(),"series_num_trackers");	
		copyProperty(providerNo,provider.getProviderNo(),"dropIn");
		copyProperty(providerNo,provider.getProviderNo(),"createdByProgram");
		
		UserProperty numUp = userPropertyDAO.getProp(provider.getProviderNo(), "series_num_trackers");
		int numTrackers = 0;
		if(numUp != null && !StringUtils.isEmpty(numUp.getValue())) {
			numTrackers = Integer.parseInt(numUp.getValue());
		}
		for(int x=0;x<numTrackers;x++) {
			copyProperty(providerNo,provider.getProviderNo(),"series_tracker" + (x+1));
			
		}
				
		//apply the schedule
		for(ScheduleTemplate st:scheduleTemplateDAO.findByProviderNoAndName(providerNo,"Group Series")) {
			ScheduleTemplate s = new ScheduleTemplate();
			s.setId(new ScheduleTemplatePrimaryKey());
			s.getId().setProviderNo(provider.getProviderNo());
			s.getId().setName("Group Series");
			s.setSummary(st.getSummary());
			s.setTimecode(st.getTimecode());
			scheduleTemplateDAO.persist(s);
		}
		
		
		DateTimeFormatter pattern = DateTimeFormat.forPattern("yyyy-MM-dd");
		DateTime startDate1 = pattern.parseDateTime(startDate);
		DateTime endDate1 = pattern.parseDateTime(endDate);

		while (startDate1.isBefore(endDate1) || startDate1.equals(endDate1)){
		    if ( contains(daysOfWeek,startDate1.getDayOfWeek())){
		    	ScheduleDate sd = new ScheduleDate();
		    	sd.setDate(startDate1.toDate());
		    	sd.setProviderNo(provider.getProviderNo());
		    	sd.setAvailable('1');
		    	sd.setPriority('b');
		    	sd.setReason("");
		    	sd.setHour("Group Series");
		    	sd.setCreator(loggedInInfo.getLoggedInProvider().getFormattedName());
		    	sd.setStatus('A');
		    	scheduleDateDao.persist(sd);
		    }
		    startDate1 = startDate1.plusDays(1);
		}

		return true;
	}
	
	boolean contains(String[] days, int dayOfWeek) {
		for(String day : days) {
			if(dayOfWeek == Integer.parseInt(day)) {
				return true;
			}
		}
		return false;
	}
	
	void copyProperty(String sourceProviderNo, String destinationProviderNo, String propertyName) {
		UserProperty up = userPropertyDAO.getProp(sourceProviderNo,propertyName);
		if(up != null) {
			UserProperty up2 = new UserProperty();
			up2.setName(propertyName);
			up2.setProviderNo(destinationProviderNo);
			up2.setValue(up.getValue());
			userPropertyDAO.persist(up2);
		}
	}
}
