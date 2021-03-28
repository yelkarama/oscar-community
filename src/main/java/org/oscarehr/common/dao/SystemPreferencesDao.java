/**
 * Copyright (c) 2014-2015. KAI Innovations Inc. All Rights Reserved.
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

import org.oscarehr.common.model.SystemPreferences;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class SystemPreferencesDao extends AbstractDao<SystemPreferences>
{
    public SystemPreferencesDao() { super(SystemPreferences.class); }

    public SystemPreferences findPreferenceByName(String name)
    {
        Query query = entityManager.createQuery("FROM SystemPreferences sp WHERE sp.name = :name");
        query.setParameter("name", name);

        List<SystemPreferences> results = query.getResultList();
        if (!results.isEmpty())
        {
            return results.get(0);
        }

        return null;
    }
}
