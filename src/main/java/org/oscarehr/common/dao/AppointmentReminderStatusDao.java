package org.oscarehr.common.dao;

import org.oscarehr.common.model.AppointmentReminderStatus;
import org.springframework.stereotype.Repository;

@Repository
@SuppressWarnings("unchecked")
public class AppointmentReminderStatusDao extends AbstractDao<AppointmentReminderStatus> {

    public AppointmentReminderStatusDao() {
        super(AppointmentReminderStatus.class);
    }
}
