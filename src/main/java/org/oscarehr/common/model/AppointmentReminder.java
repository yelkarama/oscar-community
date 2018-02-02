package org.oscarehr.common.model;

import javax.persistence.*;

@Entity
@Table(name = "appointment_reminders")
public class AppointmentReminder extends AbstractModel<Integer> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "appointment_id")
    private Integer appointmentId;

    @Column(name = "reminder_email")
    private String reminderEmail;

    @Column(name = "reminder_phone")
    private String reminderPhone;

    @Column(name = "reminder_cell")
    private String reminderCell;

    @Column(name = "confirmed")
    private Boolean confirmed;

    @Column(name = "cancelled")
    private Boolean cancelled;

    @Column(name = "unique_cancellation_key")
    private String uniqueCancellationKey;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(Integer appointmentId) {
        this.appointmentId = appointmentId;
    }

    public String getReminderEmail() {
        return reminderEmail;
    }

    public void setReminderEmail(String reminderEmail) {
        this.reminderEmail = reminderEmail;
    }

    public String getReminderPhone() {
        return reminderPhone;
    }

    public void setReminderPhone(String reminderPhone) {
        this.reminderPhone = reminderPhone;
    }

    public String getReminderCell() {
        return reminderCell;
    }

    public void setReminderCell(String reminderCell) {
        this.reminderCell = reminderCell;
    }

    public Boolean getConfirmed() {
        return confirmed;
    }

    public void setConfirmed(Boolean confirmed) {
        this.confirmed = confirmed;
    }

    public Boolean getCancelled() {
        return cancelled;
    }

    public void setCancelled(Boolean cancelled) {
        this.cancelled = cancelled;
    }

    public String getUniqueCancellationKey() {
        return uniqueCancellationKey;
    }

    public void setUniqueCancellationKey(String uniqueCancellationKey) {
        this.uniqueCancellationKey = uniqueCancellationKey;
    }
}