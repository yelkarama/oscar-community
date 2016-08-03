package org.oscarehr.common.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.PatientType;

public class PatientTypeDao extends AbstractDao<PatientType> {

	public PatientTypeDao() {
		super(PatientType.class);
	}
	
	public List <PatientType>findAllPatientTypes() {
		String sql = "select t from PatientType t";
    	Query query = entityManager.createQuery(sql);
        @SuppressWarnings("unchecked")
        List<PatientType> results = query.getResultList();
        return results;
	}
}