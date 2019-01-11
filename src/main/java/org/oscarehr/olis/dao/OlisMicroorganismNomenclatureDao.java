package org.oscarehr.olis.dao;

import org.oscarehr.common.dao.AbstractDao;
import org.oscarehr.olis.model.OlisMicroorganismNomenclature;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class OlisMicroorganismNomenclatureDao extends AbstractDao<OlisMicroorganismNomenclature> {
    public OlisMicroorganismNomenclatureDao() {
        super(OlisMicroorganismNomenclature.class);
    }

    public Map<String, OlisMicroorganismNomenclature> findAllByMicroorganismCodes(List<String> requestCodes) {
        String sql = "SELECT x FROM " + this.modelClass.getName() + " x WHERE x.microorganismCode IN (:microorganismCodes)";
        Query q = entityManager.createQuery(sql);
        q.setParameter("microorganismCodes", requestCodes);
        List<OlisMicroorganismNomenclature> resultsList = q.getResultList();

        Map<String, OlisMicroorganismNomenclature> resultsMap = new HashMap<>();
        for (OlisMicroorganismNomenclature nomenclature: resultsList) {
            resultsMap.put(nomenclature.getMicroorganismCode(), nomenclature);
        }
        return resultsMap;
    }
    
}
