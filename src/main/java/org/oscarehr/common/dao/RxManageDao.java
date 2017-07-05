package org.oscarehr.common.dao;

import org.oscarehr.common.model.RxManage;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class RxManageDao extends AbstractDao<RxManage> 
{
    public RxManageDao() { super(RxManage.class); }
    
    public RxManage findByProviderNo(String providerNo)
    {
        Query query = entityManager.createQuery("FROM RxManage rx WHERE rx.providerNo = :providerNo");
        query.setParameter("providerNo", providerNo);
        
        List<RxManage> results = query.getResultList();
        if (!results.isEmpty())
        {
            return results.get(0);   
        }
        
        return null;
    }
    
}
