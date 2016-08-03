package org.oscarehr.common.dao;

import java.util.List;

import javax.persistence.Query;

import org.oscarehr.common.model.DemographicGroupLink;
import org.oscarehr.common.model.DemographicGroupPK;
import org.springframework.stereotype.Repository;

@Repository
public class DemographicGroupLinkDao extends AbstractDao<DemographicGroupLink> {

	public DemographicGroupLinkDao() {
		super(DemographicGroupLink.class);
	}

	/**
	 * Adds a DemographicGroupLink with the provided demographicNo and groupId, and returns the newly created DemographicGroupLink.
	 * 
	 * If a DemographicGroupLink already exists with these values, it is simply returned and no new DemographicGroupLink object is created.
	 */
	public DemographicGroupLink add(int demographicNo, int groupId) {
		if (demographicNo <= 0 || groupId <= 0) {
 			throw new IllegalArgumentException();
 		}
 		
 		DemographicGroupLink dg = find(demographicNo, groupId);
 		if (dg != null) {
			return dg;
		}
		
 		dg = new DemographicGroupLink();
 		DemographicGroupPK dgpk = new DemographicGroupPK(demographicNo, groupId);
 		
 		dg.setId(dgpk);
 		
 		persist(dg);
 		
 		return dg;
	}
	
	public void remove(int demographicNo, int groupId) {
		if (demographicNo <= 0 || groupId <= 0) {
 			throw new IllegalArgumentException();
 		}
 		
 		String sql = "delete from DemographicGroupLink x where x.id.demographicNo = ? and x.id.demographicGroupId = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, demographicNo);
    	query.setParameter(2, groupId);
		
		query.executeUpdate();
	}
	
	public List<DemographicGroupLink> findByDemographicNo(int demographicNo) {
    	String sql = "select x from DemographicGroupLink x where x.id.demographicNo = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, demographicNo);

        @SuppressWarnings("unchecked")
        List<DemographicGroupLink> results = query.getResultList();
        return results;
    }
    
    public List<DemographicGroupLink> findByGroupId(int groupId) {
    	String sql = "select x from DemographicGroupLink x where x.id.demographicGroupId = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, groupId);

        @SuppressWarnings("unchecked")
        List<DemographicGroupLink> results = query.getResultList();
        return results;
    }
    
    public DemographicGroupLink find(int demographicNo, int groupId) {
    	String sql = "select x from DemographicGroupLink x where x.id.demographicNo = ? and x.id.demographicGroupId = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, demographicNo);
    	query.setParameter(2, groupId);

        @SuppressWarnings("unchecked")
        List<DemographicGroupLink> results = query.getResultList();
        
        if (results.size() > 0) {
			return results.get(0);
		}
        
        return null;
    }
    
    public void removeDemographicGroupLinkByGroupId(int groupId) {
 		if (groupId <= 0) {
 			throw new IllegalArgumentException();
 		}

		String sql = "delete from DemographicGroupLink x where x.id.demographicGroupId = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, groupId);
		
		query.executeUpdate();
 	}
 	
 	public void removeDemographicGroupLinkByDemographicNo(int demographicNo) {
 		if (demographicNo <= 0) {
 			throw new IllegalArgumentException();
 		}

		String sql = "delete from DemographicGroupLink x where x.id.demographicNo = ?";
    	Query query = entityManager.createQuery(sql);
    	query.setParameter(1, demographicNo);
		
		query.executeUpdate();
 	}
}