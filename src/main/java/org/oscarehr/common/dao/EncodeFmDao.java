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

import org.oscarehr.common.model.AbstractCodeSystemModel;
import org.oscarehr.common.model.EncodeFm;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Repository
public class EncodeFmDao extends AbstractCodeSystemDao<EncodeFm> {

	public EncodeFmDao() {
		super(EncodeFm.class);
	}

	@Override
	public List<EncodeFm> searchCode(String term) {
		List<EncodeFm> results = getLikeUniqueNoAndDesc(term);
		results.addAll(getLikeIcd9AndDesc(term));
		results.addAll(getLikeIcd10AndDesc(term));
		//remove duplicate entries
		Set<EncodeFm> s = new LinkedHashSet<>(results);
		return new ArrayList<>(s);
	}

	@Override
	public EncodeFm findByCode(String code) {
		List<EncodeFm> results = getByUniqueNo(code);
		results.addAll(getByIcd9(code));
		results.addAll(getByIcd10(code));
		if(results.isEmpty()) { return null; }
		return results.get(0);
	}

	@Override
	public AbstractCodeSystemModel<?> findByCodingSystem(String codingSystem) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.EncodeFm LIKE :cs");
		query.setParameter("cs", codingSystem);
		query.setMaxResults(1);
		return getSingleResultOrNull(query);
	}
	
	public List<EncodeFm> getByUniqueNo(String UniqueNo) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.EncodeFm = :UniqueNo");
		query.setParameter("UniqueNo", UniqueNo);
		@SuppressWarnings("unchecked")
		List<EncodeFm> results = query.getResultList();
		return results;
	}
	public List<EncodeFm> getByIcd9(String icd9Code) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.ICD9CM = :icd9");
		query.setParameter("icd9", "%"+icd9Code+"%");
		@SuppressWarnings("unchecked")
		List<EncodeFm> results = query.getResultList();
		return results;
	}
	public List<EncodeFm> getByIcd10(String icd10Code) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.ICD10 = :icd10");
		query.setParameter("icd10", "%"+icd10Code+"%");
		@SuppressWarnings("unchecked")
		List<EncodeFm> results = query.getResultList();
		return results;
	}
	
	public List<EncodeFm> getLikeUniqueNoAndDesc(String UniqueNo) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.EncodeFm LIKE :UniqueNo OR f.description LIKE :desc ORDER BY f.description");
		query.setParameter("UniqueNo", "%"+UniqueNo+"%");
		query.setParameter("desc", "%"+UniqueNo+"%");
		@SuppressWarnings("unchecked")
		List<EncodeFm> results = query.getResultList();
		return results;
	}
	public List<EncodeFm> getLikeIcd9AndDesc(String icd9Code) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.ICD9CM LIKE :icd9 OR f.description LIKE :desc ORDER BY f.description");
		query.setParameter("icd9", "%"+icd9Code+"%");
		query.setParameter("desc", "%"+icd9Code+"%");
		@SuppressWarnings("unchecked")
		List<EncodeFm> results = query.getResultList();
		return results;
	}
	public List<EncodeFm> getLikeIcd10AndDesc(String icd10Code) {
		Query query = entityManager.createQuery("SELECT f FROM EncodeFm f WHERE f.ICD10 LIKE :icd10 OR f.description LIKE :desc ORDER BY f.description");
		query.setParameter("icd10", "%"+icd10Code+"%");
		query.setParameter("desc", "%"+icd10Code+"%");
		@SuppressWarnings("unchecked")
		List<EncodeFm> results = query.getResultList();
		return results;
	}
}
