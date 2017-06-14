package org.oscarehr.common.dao;

import org.oscarehr.common.model.FreshbooksAppointmentInfo;
import org.oscarehr.common.model.FreshbooksInsuranceCompanies;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class FreshbooksInsuranceCompaniesDao extends AbstractDao<FreshbooksInsuranceCompanies>
{
    public FreshbooksInsuranceCompaniesDao() { super(FreshbooksInsuranceCompanies.class); }

    public FreshbooksInsuranceCompanies getByCompanyIdAndProviderNo(int companyId, String providerNo)
    {
        Query q = entityManager.createQuery("select x from FreshbooksInsuranceCompanies x where x.id=? and x.providerNo=?");
        q.setParameter(1, companyId);
        q.setParameter(2, providerNo);

        List<FreshbooksInsuranceCompanies> results = q.getResultList();

        if (!results.isEmpty()) { return results.get(0); }

        return null;
    }
}
