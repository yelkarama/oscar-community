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

import org.oscarehr.common.model.AlertDismissal;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
public class AlertDismissalDao extends AbstractDao<AlertDismissal> {

	public AlertDismissalDao() {
		super(AlertDismissal.class);
	}

    public AlertDismissal findByIdAndProviderNo(Integer id, String providerNo) {
        String sql = "SELECT x FROM AlertDismissal x WHERE x.id.alertId = :id AND x.id.providerNo = :providerNo";
        Query query = entityManager.createQuery(sql);
        query.setParameter("id" ,id);
        query.setParameter("providerNo" , providerNo);
        query.setMaxResults(1);

        @SuppressWarnings("unchecked")
        List<AlertDismissal> results = query.getResultList();
        if (results.isEmpty()) {
            return null;
        } else {
            return results.get(0);
        }
    }
    
    public Boolean isDismissed(Integer id, String providerNo) {
	    return (findByIdAndProviderNo(id, providerNo) != null);
    }
}