package org.oscarehr.common.dao;

import org.oscarehr.common.model.PharmacyInfo;
import org.oscarehr.common.model.PrescriptionFax;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
public class PrescriptionFaxDao extends AbstractDao<PrescriptionFax> {

    public PrescriptionFaxDao() {
        super(PrescriptionFax.class);
    }

    @SuppressWarnings("unchecked")
    public List<PrescriptionFax> findFaxedByPrescriptionIdentifier(String rxId) {
        String sql = "select f from PrescriptionFax f, PharmacyInfo x where f.pharmacyId = x.id and x.status = :status and f.rxId = :prescriptionIdentifier order by f.dateFaxed desc, x.name, x.address";
        Query query = entityManager.createQuery(sql);
        query.setParameter("status", PharmacyInfo.ACTIVE);
        query.setParameter("prescriptionIdentifier", rxId);

        return query.getResultList();
    }
}
