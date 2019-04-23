/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OlisFilteredLabResult;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
public class OlisFilteredLabResultDao extends AbstractDao<OlisFilteredLabResult>{
	
	public OlisFilteredLabResultDao() {
	    super(OlisFilteredLabResult.class);
    }
    
    public List<String> getPlacerGroupNosByProviderNo(String providerNo) {
        Query query = entityManager.createQuery("SELECT r.placerGroupNo FROM " + this.modelClass.getName() + " r WHERE r.providerNo = ?1");
        query.setParameter(1, providerNo);
        return query.getResultList();
    }
    
    public OlisFilteredLabResult findByPlacerGroupNoAndProviderNo(String placerGroupNo, String providerNo) {
        Query query = entityManager.createQuery("SELECT r FROM " + this.modelClass.getName() + " r WHERE r.placerGroupNo=?1 and r.providerNo = ?2");
        query.setParameter(1, placerGroupNo);
        query.setParameter(2, providerNo);
        return getSingleResultOrNull(query);
    }
}
