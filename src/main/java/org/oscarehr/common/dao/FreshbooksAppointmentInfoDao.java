package org.oscarehr.common.dao;

import org.oscarehr.common.model.FreshbooksAppointmentInfo;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;
import java.util.List;

@Repository
@SuppressWarnings("unchecked")
public class FreshbooksAppointmentInfoDao extends AbstractDao<FreshbooksAppointmentInfo>
{
    public FreshbooksAppointmentInfoDao() {
        super(FreshbooksAppointmentInfo.class);
    }
    
    public FreshbooksAppointmentInfo getByInvoiceAndBusinessId(String invoiceId, String provFreshbooksId)
    {
        Query q = entityManager.createQuery("select x from FreshbooksAppointmentInfo x where x.freshbooksInvoiceId=? and x.providerFreshbooksId=?");
        q.setParameter(1, invoiceId);
        q.setParameter(2, provFreshbooksId);
        
        List<FreshbooksAppointmentInfo> result = q.getResultList();

        if (!result.isEmpty()) { return result.get(0);}
        
        return null;
    }

    public FreshbooksAppointmentInfo getByAppointmentNo(String appointmentNo)
    {
        if (appointmentNo.isEmpty() || appointmentNo == null) { appointmentNo = "-1"; }
        Query q = entityManager.createQuery("select x from FreshbooksAppointmentInfo x where x.appointmentNo=?");
        q.setParameter(1, Integer.parseInt(appointmentNo));

        List<FreshbooksAppointmentInfo> result = q.getResultList();

        if (!result.isEmpty() && result.size() > 0) { return result.get(0); }

        return null;
    }
}
