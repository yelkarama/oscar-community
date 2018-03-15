package org.oscarehr.common.dao;

import org.apache.log4j.Logger;
import org.oscarehr.common.model.AppointmentReminder;
import org.oscarehr.util.MiscUtils;
import org.springframework.stereotype.Repository;

import javax.persistence.NoResultException;
import javax.persistence.Query;

import javax.persistence.Query;

@Repository
@SuppressWarnings("unchecked")
public class AppointmentReminderDao extends AbstractDao<AppointmentReminder> {

    public AppointmentReminderDao() {
        super(AppointmentReminder.class);
    }

    private Logger logger = MiscUtils.getLogger();

    public AppointmentReminder getByAppointmentNo(Integer appointmentNo) {
        String sql = "select a from AppointmentReminder a where a.appointmentId=?";
        Query query = entityManager.createQuery(sql);
        query.setParameter(1, appointmentNo);

        try {
            return(AppointmentReminder) query.getSingleResult();
        } catch (NoResultException nre) {
            logger.debug("No appointment reminder record found to cancel/delete! | " + nre);
            return null;
        }
    }
}
