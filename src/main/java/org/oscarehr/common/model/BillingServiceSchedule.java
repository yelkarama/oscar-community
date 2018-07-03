package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;
import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@Entity
@Table(name = "billing_service_schedule")
public class BillingServiceSchedule extends AbstractModel<Integer> implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
    @Column(name = "service_code", nullable = false)
    private String serviceCode;
    @Column(name = "billing_time", nullable = false)
    private Date billingTime = null;
    @Column(name = "provider_no")
    private String providerNo;
    private Boolean deleted = false;
    @Transient
    String serviceDescription = "";

    public BillingServiceSchedule() {
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getServiceCode() {
        return serviceCode;
    }

    public void setServiceCode(String serviceCode) {
        this.serviceCode = serviceCode;
    }

    public String getBillingTime(){
        return (new SimpleDateFormat("HH:mm:ss")).format(this.billingTime);
    }

    public void setBillingTime(String time) {
        Date billingTime = null;
        try {
            billingTime = (new SimpleDateFormat("HH:mm:ss")).parse(time);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        
        this.billingTime = billingTime;
    }


    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Boolean getDeleted() {
        return deleted;
    }

    public void setDeleted(Boolean deleted) {
        this.deleted = deleted;
    }

    public String getServiceDescription() {
        return serviceDescription;
    }

    public void setServiceDescription(String serviceDescription) {
        this.serviceDescription = serviceDescription;
    }
}
