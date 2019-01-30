package org.oscarehr.olis.model;

import org.oscarehr.common.model.AbstractModel;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity(name = "olis_facilities")
public class OLISFacilities extends AbstractModel<Integer> {

    @Id
    @GeneratedValue
    @Column(name = "licence_number")
    private Integer id;
    @Column(name = "facility_name")
    private String facilityName;
    @Column(name = "facility_address_line1")
    private String facilityAddressLine1;
    @Column(name = "facility_address_line2")
    private String facilityAddressLine2;
    @Column(name = "facility_address_city")
    private String facilityAddressCity;
    @Column(name = "facility_postal_code")
    private String facilityPostalCode;
    @Column(name = "oid")
    private String oid;
    @Column(name = "full_id")
    private String fullId;

    @Override
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getFacilityName() {
        return facilityName;
    }

    public void setFacilityName(String facilityName) {
        this.facilityName = facilityName;
    }

    public String getFacilityAddressLine1() {
        return facilityAddressLine1;
    }

    public void setFacilityAddressLine1(String facilityAddressLine1) {
        this.facilityAddressLine1 = facilityAddressLine1;
    }

    public String getFacilityAddressLine2() {
        return facilityAddressLine2;
    }

    public void setFacilityAddressLine2(String facilityAddressLine2) {
        this.facilityAddressLine2 = facilityAddressLine2;
    }

    public String getFacilityAddressCity() {
        return facilityAddressCity;
    }

    public void setFacilityAddressCity(String facilityAddressCity) {
        this.facilityAddressCity = facilityAddressCity;
    }

    public String getFacilityPostalCode() {
        return facilityPostalCode;
    }

    public void setFacilityPostalCode(String facilityPostalCode) {
        this.facilityPostalCode = facilityPostalCode;
    }

    public String getOid() {
        return oid;
    }

    public void setOid(String oid) {
        this.oid = oid;
    }

    public String getFullId() {
        return fullId;
    }

    public void setFullId(String fullId) {
        this.fullId = fullId;
    }
}
