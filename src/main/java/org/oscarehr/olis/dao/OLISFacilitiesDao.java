package org.oscarehr.olis.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OLISFacilities;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;

@Repository
public class OLISFacilitiesDao extends AbstractDao<OLISFacilities> {

    public OLISFacilitiesDao() {
        super (OLISFacilities.class);
    }

    public OLISFacilities findByLicenceNumber(Integer licenceNumber) {
        try {
            String sql = "select x from "+ this.modelClass.getName() + " x where x.id=?";
            Query query = entityManager.createQuery(sql);
            query.setParameter(1, licenceNumber);
            return (OLISFacilities) query.getSingleResult();
        }
        catch (javax.persistence.NoResultException nre) {
            nre.printStackTrace();
            return null;
        }
    }
    
    public OLISFacilities findByFullId(String fullId) {
        try {
            String sql = "select x from "+ this.modelClass.getName() + " x where x.fullId = :fullId";
            Query query = entityManager.createQuery(sql);
            query.setParameter("fullId", fullId);
            return (OLISFacilities) query.getSingleResult();
        }
        catch (javax.persistence.NoResultException nre) {
            nre.printStackTrace();
            return null;
        }
    }
}
