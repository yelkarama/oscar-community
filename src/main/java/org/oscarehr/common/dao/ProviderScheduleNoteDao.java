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

import org.oscarehr.common.model.ProviderScheduleNote;
import org.springframework.stereotype.Repository;

import javax.persistence.NoResultException;
import javax.persistence.Query;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@Repository
public class ProviderScheduleNoteDao extends AbstractDao<ProviderScheduleNote>{

	public ProviderScheduleNoteDao() {
		super(ProviderScheduleNote.class);
	}

    public ProviderScheduleNote findByProviderNoAndDate(String providerNo, Date date) {
        String sql = "SELECT n FROM ProviderScheduleNote n " +
                "WHERE n.id.providerNo = :providerNo AND n.id.date = :date";
        Query query = entityManager.createQuery(sql);
        query.setParameter("providerNo", providerNo);
        query.setParameter("date", date);
        ProviderScheduleNote result = null;
        try {
            result = (ProviderScheduleNote) query.getSingleResult();
        } catch (NoResultException e) {
            //do nothing
        }
        return result;
    }
    
	public ProviderScheduleNote findByProviderNoAndDate(String providerNo, String dateString) throws ParseException {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        return findByProviderNoAndDate(providerNo, dateFormat.parse(dateString));
    }
}
