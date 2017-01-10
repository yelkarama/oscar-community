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

import java.util.List;

import javax.persistence.Query;
import org.springframework.stereotype.Repository;

import org.oscarehr.common.model.DaySheetConfiguration;

@Repository
public class DaySheetConfigurationDao extends AbstractDao<DaySheetConfiguration> {

	protected DaySheetConfigurationDao() {
		super(DaySheetConfiguration.class);
	}
	
	@SuppressWarnings("unchecked")
	public List<DaySheetConfiguration> getConfigurationList() {
		String sql = "SELECT x FROM DaySheetConfiguration x ORDER BY x.pos";
		Query query = entityManager.createQuery(sql);		
		List<DaySheetConfiguration> results = query.getResultList();
		return results;
	}

	public DaySheetConfiguration getConfig(int id){
    	Query query = entityManager.createQuery("select x from DaySheetConfiguration x where x.id= :id");
		query.setParameter("id", id);
		
        @SuppressWarnings("unchecked")
        List<DaySheetConfiguration> configList = query.getResultList();
        if(configList.size()>0) {
        	return configList.get(0);
        }
        return null;
    }

    public void save(DaySheetConfiguration dsConfig) {
        if(dsConfig.getId() != null && dsConfig.getId()>0) {
        	merge(dsConfig);
        } else {
        	persist(dsConfig);
        }
    }
}
