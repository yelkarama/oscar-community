package org.oscarehr.common.model;

import org.codehaus.jackson.annotate.JsonBackReference;
import org.hibernate.annotations.NotFound;
import org.hibernate.annotations.NotFoundAction;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.PrePersist;
import javax.persistence.PreRemove;
import javax.persistence.PreUpdate;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;

@Entity
@Table(name = "prescription_fax")
public class PrescriptionFax extends AbstractModel<Integer> implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(name = "rx_id")
    private String rxId;
    @Column(name = "pharmacy_id")
    private Integer pharmacyId;
    @Column(name = "provider_no")
    private String providerNo;
    @Column(name = "prescribe_it_fax")
    private Boolean prescribeItFax = false;
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "date_faxed")
    private Date dateFaxed;
    
    @OneToOne
    @JoinColumn(name ="pharmacy_id", insertable = false, updatable = false)
    @JsonBackReference
    @NotFound(action = NotFoundAction.IGNORE)
    private PharmacyInfo pharmacyInfo;

    @Override
    public Integer getId() {
        return id;
    }

    public PrescriptionFax() {
    }

    public PrescriptionFax(String rxId, Integer pharmacyId, String providerNo) {
        this.rxId = rxId;
        this.pharmacyId = pharmacyId;
        this.providerNo = providerNo;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getRxId() {
        return rxId;
    }

    public void setRxId(String rxId) {
        this.rxId = rxId;
    }

    public Integer getPharmacyId() {
        return pharmacyId;
    }

    public void setPharmacyId(Integer pharmacyId) {
        this.pharmacyId = pharmacyId;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Boolean getPrescribeItFax() {
        return prescribeItFax;
    }

    public void setPrescribeItFax(Boolean prescribeItFax) {
        this.prescribeItFax = prescribeItFax;
    }

    public Date getDateFaxed() {
        return dateFaxed;
    }

    public void setDateFaxed(Date dateFaxed) {
        this.dateFaxed = dateFaxed;
    }

    public PharmacyInfo getPharmacyInfo() {
        return pharmacyInfo;
    }

    public void setPharmacyInfo(PharmacyInfo pharmacyInfo) {
        this.pharmacyInfo = pharmacyInfo;
    }

    @PreRemove
    protected void jpaPreventDelete() {
        throw (new UnsupportedOperationException("Remove is not allowed for this type of item."));
    }

    @PreUpdate
    @PrePersist
    protected void autoPreSave() {
        dateFaxed = new Date();
    }
}

   