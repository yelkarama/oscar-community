package org.oscarehr.common.model;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "appointmentReminderStatus")
public class AppointmentReminderStatus extends AbstractModel<Integer>
{
    @Id
    @GeneratedValue
    @Column(name = "id")
    private Integer id;

    @Column(name = "apptReminderId")
    private Integer apptReminderId;

    @Column(name = "providerNo")
    private String providerNo;

    @Column(name = "allDelivered")
    private Boolean allDelivered;

    @Column(name = "deliveryTime")
    private Timestamp deliveryTime;

    @Column(name = "remindersSent")
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
