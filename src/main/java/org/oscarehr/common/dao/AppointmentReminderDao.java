package org.oscarehr.common.dao;

import org.oscarehr.common.model.AppointmentReminder;
import org.springframework.stereotype.Repository;

import javax.persistence.Query;

@Repository
@SuppressWarnings("unchecked")
public class AppointmentReminderDao extends AbstractDao<AppointmentReminder> {

    public AppointmentReminderDao() {
        super(AppointmentReminder.class);
    }

    public AppointmentReminder getByAppointmentNo(Integer appointmentNo) {
        String sql = "select a from AppointmentReminder a where a.appointmentId=?";
        Query query = entityManager.createQuery(sql);
        query.setParameter(1, appointmentNo);

        return(AppointmentReminder) query.getSingleResult();
    }
}
