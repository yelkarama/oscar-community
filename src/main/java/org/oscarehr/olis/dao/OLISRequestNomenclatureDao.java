/**
 * Copyright (c) 2008-2012 Indivica Inc.
 *
 * This software is made available under the terms of the
 * GNU General Public License, Version 2, 1991 (GPLv2).
 * License details are available via "indivica.ca/gplv2"
 * and "gnu.org/licenses/gpl-2.0.html".
 */
package org.oscarehr.olis.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.Query;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OLISRequestNomenclature;
import org.springframework.stereotype.Repository;

@Repository
public class OLISRequestNomenclatureDao extends AbstractDao<OLISRequestNomenclature>{

	
	public OLISRequestNomenclatureDao() {
	    super(OLISRequestNomenclature.class);
    }

	public OLISRequestNomenclature findByNameId(String id) {
        String sql = "select x from "+ this.modelClass.getName() + " x where x.requestCode=?";
		Query query = entityManager.createQuery(sql);
		query.setParameter(1, id);

		return getSingleResultOrNull(query);
	}

	public List<OLISRequestNomenclature> searchByName(String name) {
		String sql = "select x from "+ this.modelClass.getName() + " x where x.requestAlternateName1 LIKE :name";
		Query query = entityManager.createQuery(sql);
		query.setParameter("name", name + "%");
		query.setMaxResults(10);

		List<OLISRequestNomenclature> requestNomenclatures = query.getResultList();
		
		return requestNomenclatures;
	}
	
	@SuppressWarnings("unchecked")
    public List<OLISRequestNomenclature> findAll() {
		String sql = "select x from " + this.modelClass.getName() + " x";
		Query query = entityManager.createQuery(sql);
		return query.getResultList();
	}
	
	public Map<String, OLISRequestNomenclature> findByOlisTestRequestCodes(List<String> requestCodes) {
	    Query q = entityManager.createQuery("SELECT x FROM " + this.modelClass.getName() + " x WHERE x.requestCode IN (:requestCodes)");
	    q.setParameter("requestCodes", requestCodes);
	    List<OLISRequestNomenclature> resultsList = q.getResultList();

        Map<String, OLISRequestNomenclature> resultsMap = new HashMap<String, OLISRequestNomenclature>();
        for (OLISRequestNomenclature olisRequestNomenclature : resultsList) {
            resultsMap.put(olisRequestNomenclature.getRequestCode(), olisRequestNomenclature);
        }
        return resultsMap;
    }
}
