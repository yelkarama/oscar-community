package org.oscarehr.common.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.DemographicGroup;
import org.springframework.stereotype.Repository;

@Repository
public class DemographicGroupDao extends AbstractDao<DemographicGroup> {

	public DemographicGroupDao() {
		super(DemographicGroup.class);
	}

	/**
	 * Adds a DemographicGroup with the provided name and description, and returns the newly created DemographicGroup.
	 * 
	 * If a DemographicGroup already exists with these values, it is simply returned and no new DemographicGroup object is created.
	 */
	public DemographicGroup add(String name, String description) {
		if (name == null || name.length() == 0 || description == null) {
 			throw new IllegalArgumentException();
 		}
 		
 		DemographicGroup dg = find(name);
 		if (dg != null) {
			return dg;
		}
		
 		dg = new DemographicGroup();
 		dg.setName(name);
 		dg.setDescription(description);
 		
 		persist(dg);
 		
 		return dg;
	}
	
	public void save(DemographicGroup group) {
		if (group == null) {
 			throw new IllegalArgumentException();
 		}
 		
 		// Check if duplicate
 		if (group.getId() == null || group.getId() == 0) {
			DemographicGroup dg = findByName(group.getName());
	 		if (dg != null) {
				throw new IllegalArgumentException("Unable to save DemographicGroup - a group with that name already exists.");
			}
		}
 		
		merge(group);
	}
	
	public void delete(DemographicGroup group) {
		if (group == null) {
 			throw new IllegalArgumentException();
 		}
 	
		if(contains(group)){
			remove(group);
		}
		else {
			remove(group.getId());
		}
	}
	
	public List<DemographicGroup> getAll() {
    	String sql = "select x from DemographicGroup x";
    	Query query = entityManager.createQuery(sql);

        @SuppressWarnings("unchecked")
        List<DemographicGroup> results = query.getResultList();
        return results;
    }
    
    public DemographicGroup find(int id) {
    	String sql = "select x from DemographicGroup x where x.id = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, id);

        @SuppressWarnings("unchecked")
        List<DemographicGroup> results = query.getResultList();
        
        if (results.size() > 0) {
			return results.get(0);
		}
        
        return null;
    }
    
    public DemographicGroup find(String name, String description) {
    	String sql = "select x from DemographicGroup x where x.name = ? and x.description = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, name);
    	query.setParameter(2, description);

        @SuppressWarnings("unchecked")
        List<DemographicGroup> results = query.getResultList();
        
        if (results.size() > 0) {
			return results.get(0);
		}
        
        return null;
    }
    
    public DemographicGroup findByName(String name) {
    	String sql = "select x from DemographicGroup x where x.name = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, name);

        @SuppressWarnings("unchecked")
        List<DemographicGroup> results = query.getResultList();
        
        if (results.size() > 0) {
			return results.get(0);
		}
        
        return null;
    }
}