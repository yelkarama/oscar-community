package org.oscarehr.common.model;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "appointment_reminder_status")
public class AppointmentReminderStatus extends AbstractModel<Integer>
{
    @Id
    @GeneratedValue
    @Column(name = "id")
    private Integer id;

    @Column(name = "appt_reminder_id")
    private Integer apptReminderId;

    @Column(name = "provider_no")
    private String providerNo;

    @Column(name = "all_delivered")
    private Boolean allDelivered;

    @Column(name = "delivery_time")
    private Timestamp deliveryTime;

    @Column(name = "reminders_sent")
    private Integer remindersSent;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getApptReminderId() {
        return apptReminderId;
    }

    public void setApptReminderId(Integer apptReminderId) {
        this.apptReminderId = apptReminderId;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Boolean getAllDelivered() {
        return allDelivered;
    }

    public void setAllDelivered(Boolean delivered) {
        this.allDelivered = delivered;
    }

    public Timestamp getDeliveryTime() {
        return deliveryTime;
    }

    public void setDeliveryTime(Timestamp deliveryTime) {
        this.deliveryTime = deliveryTime;
    }

    public Integer getRemindersSent() {
        return remindersSent;
    }

    public void setRemindersSent(Integer remindersSent) {
        this.remindersSent = remindersSent;
    }
}
