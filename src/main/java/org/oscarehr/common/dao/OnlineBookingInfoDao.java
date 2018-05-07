package org.oscarehr.common.dao;

import javax.persistence.Query;
import org.oscarehr.common.model.OnlineBookingInfo;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class OnlineBookingInfoDao extends AbstractDao<OnlineBookingInfo>{

    public OnlineBookingInfoDao() {
        super(OnlineBookingInfo.class);
    }

    public OnlineBookingInfo getOnlineBookingPreference(String key, String providerNo) {
        Query query = entityManager.createQuery("SELECT o FROM OnlineBookingInfo o WHERE o.key = ?1 AND o.providerNo = ?2");
        query.setParameter(1, key);
        query.setParameter(2, providerNo);

        List<OnlineBookingInfo> resultList = query.getResultList();
        if (resultList.isEmpty()) return null;
        return resultList.get(0);
    }
}
