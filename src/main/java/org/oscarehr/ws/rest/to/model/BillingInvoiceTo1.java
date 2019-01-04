/**
 * Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for the
 * Department of Family Medicine
 * McMaster University
 * Hamilton
 * Ontario, Canada
 */
package org.oscarehr.ws.rest.to.model;
import org.oscarehr.common.model.BillingONCHeader1;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.Date;
import java.util.Set;

public class BillingInvoiceTo1 implements Serializable {
    
    private String transactionId = "HE";
    private String recordId = "H";
    private String hin = null;
    private String ver = "";
    private String dob = null;
    private String payProgram = "HCP";
    private String payee = "P";
    private String refNum = "";
    private String facilityNum = null;
    private Date admissionDate = null;
    private String refLabNum = "";
    private String manualReview = "";
    private String location = null;
    private Integer demographicNo = 0;
    private String providerNo = null;
    private String providerOhipNo = "";
    private String providerRmaNo = "";
    private Integer appointmentNo = null;
    private String demographicName = null;
    private String sex = "1";
    private String province = "ON";
    private Date billingDate = null;
    private BigDecimal total = new BigDecimal("0.00");
    private BigDecimal paid = new BigDecimal("0.00");
    private String status = null;
    private String comment = "";
    private String visitType = null;
    private String appointmentProviderNo = null;
    private String asstProviderNo = null;
    private String creator;
    private Date timestamp = new Timestamp(System.currentTimeMillis());
    private String clinic = null;
    private Set<BillingItemTo1> billingItems = Collections.emptySet();

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getRecordId() {
        return recordId;
    }

    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

    public String getHin() {
        return hin;
    }

    public void setHin(String hin) {
        this.hin = hin;
    }

    public String getVer() {
        return ver;
    }

    public void setVer(String ver) {
        this.ver = ver;
    }

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getPayProgram() {
        return payProgram;
    }

    public void setPayProgram(String payProgram) {
        this.payProgram = payProgram;
    }

    public String getPayee() {
        return payee;
    }

    public void setPayee(String payee) {
        this.payee = payee;
    }

    public String getRefNum() {
        return refNum;
    }

    public void setRefNum(String refNum) {
        this.refNum = refNum;
    }

    public String getFacilityNum() {
        return facilityNum;
    }

    public void setFacilityNum(String facilityNum) {
        this.facilityNum = facilityNum;
    }

    public Date getAdmissionDate() {
        return admissionDate;
    }

    public void setAdmissionDate(Date admissionDate) {
        this.admissionDate = admissionDate;
    }

    public String getRefLabNum() {
        return refLabNum;
    }

    public void setRefLabNum(String refLabNum) {
        this.refLabNum = refLabNum;
    }

    public String getManualReview() {
        return manualReview;
    }

    public void setManualReview(String manualReview) {
        this.manualReview = manualReview;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Integer getDemographicNo() {
        return demographicNo;
    }

    public void setDemographicNo(Integer demographicNo) {
        this.demographicNo = demographicNo;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public String getProviderOhipNo() {
        return providerOhipNo;
    }

    public void setProviderOhipNo(String providerOhipNo) {
        this.providerOhipNo = providerOhipNo;
    }

    public String getProviderRmaNo() {
        return providerRmaNo;
    }

    public void setProviderRmaNo(String providerRmaNo) {
        this.providerRmaNo = providerRmaNo;
    }

    public Integer getAppointmentNo() {
        return appointmentNo;
    }

    public void setAppointmentNo(Integer appointmentNo) {
        this.appointmentNo = appointmentNo;
    }

    public String getDemographicName() {
        return demographicName;
    }

    public void setDemographicName(String demographicName) {
        this.demographicName = demographicName;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public Date getBillingDate() {
        return billingDate;
    }

    public void setBillingDate(Date billingDate) {
        this.billingDate = billingDate;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public BigDecimal getPaid() {
        return paid;
    }

    public void setPaid(BigDecimal paid) {
        this.paid = paid;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getVisitType() {
        return visitType;
    }

    public void setVisitType(String visitType) {
        this.visitType = visitType;
    }

    public String getAppointmentProviderNo() {
        return appointmentProviderNo;
    }

    public void setAppointmentProviderNo(String appointmentProviderNo) {
        this.appointmentProviderNo = appointmentProviderNo;
    }

    public String getAsstProviderNo() {
        return asstProviderNo;
    }

    public void setAsstProviderNo(String asstProviderNo) {
        this.asstProviderNo = asstProviderNo;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator;
    }

    public Date getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }

    public String getClinic() {
        return clinic;
    }

    public void setClinic(String clinic) {
        this.clinic = clinic;
    }

    public Set<BillingItemTo1> getBillingItems() {
        return billingItems;
    }

    public void setBillingItems(Set<BillingItemTo1> billingItems) {
        this.billingItems = billingItems;
    }
    
    public BillingONCHeader1 toBillingONCHeader1() {
        BillingONCHeader1 billingHeader = new BillingONCHeader1();
        billingHeader.setTranscId(this.getTransactionId());
        billingHeader.setRecId(this.getRecordId());
        billingHeader.setPayProgram(this.getPayProgram());
        billingHeader.setPayee(this.getPayee());
        billingHeader.setRefNum(this.getRefNum());
        billingHeader.setFaciltyNum(this.getFacilityNum());
        billingHeader.setRefLabNum(this.getRefLabNum());
        billingHeader.setManReview(this.getManualReview());
        billingHeader.setLocation(this.getLocation());
        billingHeader.setDemographicNo(this.getDemographicNo());
        billingHeader.setProviderNo(this.getProviderNo());
        billingHeader.setAppointmentNo(this.getAppointmentNo());
        billingHeader.setProvince(this.getProvince());
        billingHeader.setComment(this.getComment());
        billingHeader.setVisitType(this.getVisitType());
        billingHeader.setCreator(this.getCreator());
        return billingHeader;
    }
}
