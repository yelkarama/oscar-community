/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
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
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */

package org.oscarehr.common.dao;

import org.oscarehr.common.model.ConsultationRequestArchive;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class ConsultationRequestArchiveDao extends AbstractDao<ConsultationRequestArchive> {
    public ConsultationRequestArchiveDao() {
        super(ConsultationRequestArchive.class);
    }
    
    public List<ConsultationRequestArchive> findByRequestId(Integer requestId) {
        Query query = entityManager.createQuery("SELECT c FROM ConsultationRequestArchive c WHERE c.requestId = :requestId ORDER BY c.archiveTimestamp DESC");
        query.setParameter("requestId", requestId);

        return query.getResultList();
    }
    
    public Map<Integer, Date> findArchiveIdAndDateByRequestId(Integer requestId) {
        Query query = entityManager.createQuery("SELECT c.id, c.archiveTimestamp FROM ConsultationRequestArchive c WHERE c.requestId = :requestId ORDER BY c.archiveTimestamp DESC");
        query.setParameter("requestId", requestId);
        ArrayList<Object[]> resultList = (ArrayList<Object[]>) query.getResultList();
        Map<Integer, Date> result = new HashMap<>();
        Calendar cal = Calendar.getInstance();
        
        for (Object[] item : resultList) {
            cal.setTimeInMillis(((Timestamp) item[1]).getTime());
            result.put((Integer) item[0], cal.getTime());
        }
        return result;
    }
}
