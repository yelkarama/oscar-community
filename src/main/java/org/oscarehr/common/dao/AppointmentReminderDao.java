package org.oscarehr.common.dao;

import org.oscarehr.common.model.AppointmentReminder;
import org.springframework.stereotype.Repository;

@Repository
@SuppressWarnings("unchecked")
public class AppointmentReminderDao extends AbstractDao<AppointmentReminder> {

    public AppointmentReminderDao() {
        super(AppointmentReminder.class);
    }
}
