package org.oscarehr.common.dao;

import org.apache.commons.lang.StringUtils;
import org.opensaml.xml.signature.Q;
import org.oscarehr.common.model.BillingServiceSchedule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Repository
public class BillingServiceScheduleDao extends AbstractDao<BillingServiceSchedule> {
    private SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");

    public BillingServiceScheduleDao() {
        super(BillingServiceSchedule.class);
    }
    
    public List<BillingServiceSchedule> getAll(String providerNo) {
        if (StringUtils.trimToNull(providerNo) == null) {
            return getAllClinic();
        }

        String queryStr = "FROM BillingServiceSchedule b WHERE b.deleted = false and b.providerNo = :providerNo";

        Query q = entityManager.createQuery(queryStr);
        q.setParameter("providerNo", providerNo);

        return q.getResultList();
    }

    public List<BillingServiceSchedule> getAllClinic() {
        return getAllClinic(null);
    }
    
    public List<BillingServiceSchedule> getAllClinic(List<String> notInCodes) {
        String queryStr = "FROM BillingServiceSchedule b WHERE b.deleted = false and b.providerNo is null";
        
        if (notInCodes != null && !notInCodes.isEmpty()) {
            queryStr += " and b.serviceCode not in (:codes)";
        }
        
        Query q = entityManager.createQuery(queryStr);

        if (notInCodes != null && !notInCodes.isEmpty()) {
            q.setParameter("codes", notInCodes);
        }

        return q.getResultList();
    }
    
    
}
