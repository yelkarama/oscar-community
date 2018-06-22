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

import org.oscarehr.common.model.ConsultationRequestExtArchive;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
public class ConsultationRequestExtArchiveDao extends AbstractDao<ConsultationRequestExtArchive> {
    public ConsultationRequestExtArchiveDao() {
        super(ConsultationRequestExtArchive.class);
    }

    public String getConsultationRequestExtsByKey(Integer archiveId,String key) {
        Query query = entityManager.createQuery("select cre.value from ConsultationRequestExtArchive cre where cre.archiveId=?1 and cre.name=?2");
        query.setParameter(1, archiveId);
        query.setParameter(2, key);
        List<String> results = query.getResultList();
        if(results.size()>0)
            return results.get(0);
        return null;
    }
}
