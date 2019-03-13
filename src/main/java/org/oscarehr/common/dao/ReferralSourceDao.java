package org.oscarehr.common.dao;

import org.oscarehr.common.model.ReferralSource;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class ReferralSourceDao extends AbstractDao<ReferralSource>  {
    public ReferralSourceDao() {super(ReferralSource.class);}

    public List<ReferralSource> getReferralSourceList() {
        Query query = entityManager.createQuery("FROM org.oscarehr.common.model.ReferralSource rf");
        List<ReferralSource> results = query.getResultList();

        if (!results.isEmpty()) {
            return results;
        }

        return null;
    }

}