package org.oscarehr.common.dao;

import org.oscarehr.common.model.AppointmentReminderStatus;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;

@Repository
@SuppressWarnings("unchecked")
public class AppointmentReminderStatusDao extends AbstractDao<AppointmentReminderStatus> {

    public AppointmentReminderStatusDao() {
        super(AppointmentReminderStatus.class);
    }

    public AppointmentReminderStatus getByAppointmentReminderNo(Integer apptReminderId) {
        String sql = "select a from AppointmentReminderStatus a where a.apptReminderId=?";
        Query query = entityManager.createQuery(sql);
        query.setParameter(1, apptReminderId);

        return(AppointmentReminderStatus) query.getSingleResult();
    }
}
