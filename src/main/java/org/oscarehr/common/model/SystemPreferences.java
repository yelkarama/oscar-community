package org.oscarehr.common.model;

import javax.persistence.*;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Entity
@Table(name="SystemPreferences")
public class SystemPreferences extends AbstractModel<Integer>
{

    public static final List<String> RX_PREFERENCE_KEYS = Arrays.asList("rx_paste_provider_to_echart", "rx_show_end_dates","rx_show_start_dates", "rx_show_refill_duration", "rx_show_refill_quantity");
    public static final List<String> SCHEDULE_PREFERENCE_KEYS = Arrays.asList("schedule_display_type", "schedule_display_custom_roster_status");
    public static final List<String> ECHART_PREFERENCE_KEYS = Arrays.asList("echart_hide_timer");
    public static final List<String> MASTER_FILE_PREFERENCE_KEYS = Arrays.asList("display_former_name", "redirect_for_contact");
    public static final List<String> GENERAL_SETTINGS_KEYS = Arrays.asList("replace_demographic_name_with_preferred");
    public static final String LAB_DISPLAY_PREFERENCE_KEYS = "code_show_hide_column";
    public static final List<String> REFERRAL_SOURCE_PREFERENCE_KEYS = Arrays.asList("enable_referral_source");
    public static final String KIOSK_DISPLAY_PREFERENCE_KEYS = "check_in_all_appointments";
    public static final List<String> DOCUMENT_SETTINGS_KEYS = Arrays.asList("document_description_typeahead");
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name="name")
    private String name;

    @Column(name="value")
    private String value;

    @Column(name="updateDate")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateDate;

    public SystemPreferences() {}
    public SystemPreferences(String name, String value) {
        this.name = name;
        this.value = value;
        this.updateDate = new Date();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    /**
     * Gets the system preference as a boolean
     * @return true if value is "true", false otherwise
     */
    public Boolean getValueAsBoolean() {
        return "true".equals(value);
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Date getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }
}
