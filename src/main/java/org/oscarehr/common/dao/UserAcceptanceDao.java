package org.oscarehr.common.dao;

import org.oscarehr.common.model.UserAcceptance;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class UserAcceptanceDao extends AbstractDao<UserAcceptance>
{
    public UserAcceptanceDao() {
        super(UserAcceptance.class);
    }

    public UserAcceptance getByProviderNo(String providerNo)
    {
        Query q = entityManager.createQuery("select x from UserAcceptance x where x.providerNo=?");
        q.setParameter(1, providerNo);
        List<UserAcceptance> result = q.getResultList();
        if (!result.isEmpty()) { return result.get(0);}
        return null;
    }
}
