package org.oscarehr.olis.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OlisHospital;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;

@Repository
public class OlisHospitalDao extends AbstractDao<OlisHospital> {
    public OlisHospitalDao() {
        super(OlisHospital.class);
    }

    public OlisHospital findByFullId(String fullId) {
        try {
            String sql = "SELECT x FROM "+ this.modelClass.getName() + " x WHERE x.fullId = :fullId";
            Query query = entityManager.createQuery(sql);
            query.setParameter("fullId", fullId);
            return (OlisHospital) query.getSingleResult();
        }
        catch (javax.persistence.NoResultException nre) {
            nre.printStackTrace();
            return null;
        }
    }
}
