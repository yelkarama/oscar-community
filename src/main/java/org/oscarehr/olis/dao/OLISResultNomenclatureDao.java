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
import org.oscarehr.olis.model.OLISResultNomenclature;
import org.springframework.stereotype.Repository;

@Repository
public class OLISResultNomenclatureDao extends AbstractDao<OLISResultNomenclature>{

	
	public OLISResultNomenclatureDao() {
	    super(OLISResultNomenclature.class);
    }

	public OLISResultNomenclature findByLoincCode(String code) {
		String sql = "select x from "+ this.modelClass.getName() + " x where x.loincCode = :loincCode";
		Query query = entityManager.createQuery(sql);
		query.setParameter("loincCode", code);
		
		return getSingleResultOrNull(query);
	}
	
	@SuppressWarnings("unchecked")
    public List<OLISResultNomenclature> findAll() {
		String sql = "select x from " + this.modelClass.getName() + " x";
		Query query = entityManager.createQuery(sql);
		return query.getResultList();
	}

	public Map<String, OLISResultNomenclature> findByOlisTestLoincCodes(List<String> requestCodes) {
		Query q = entityManager.createQuery("SELECT x FROM " + this.modelClass.getName() + " x WHERE x.loincCode IN (:requestCodes)");
		q.setParameter("requestCodes", requestCodes);
		List<OLISResultNomenclature> resultsList = q.getResultList();

		Map<String, OLISResultNomenclature> resultsMap = new HashMap<String, OLISResultNomenclature>();
		for (OLISResultNomenclature olisRequestNomenclature : resultsList) {
			resultsMap.put(olisRequestNomenclature.getLoincCode(), olisRequestNomenclature);
		}
		return resultsMap;
	}
}
