package org.oscarehr.common.model;

import oscar.oscarBilling.ca.on.bean.BillingClaimsOutsideUseReportBean;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Entity
@Table(name="billing_on_ou_report")
public class BillingONOUReport extends AbstractModel<Integer> implements Serializable {
    public BillingONOUReport() {
    }

    public BillingONOUReport(String reportId, Date reportDate, Date reportPeriodStart, Date reportPeriodEnd, 
                             String groupId, String groupType, String groupName, 
                             String providerOhipNo, String providerLast, String providerFirst, String providerMiddle, 
                             String patientHin, String patientLast, String patientFirst, Date patientBirthDate, 
                             Date serviceDate, String serviceCode, String serviceDescription, BigDecimal serviceAmount, 
                             String reportFile) {
        this.reportId = reportId;
        this.reportDate = reportDate;
        this.reportPeriodStart = reportPeriodStart;
        this.reportPeriodEnd = reportPeriodEnd;
        this.groupId = groupId;
        this.groupType = groupType;
        this.groupName = groupName;
        this.providerOhipNo = providerOhipNo;
        this.providerLast = providerLast;
        this.providerFirst = providerFirst;
        this.providerMiddle = providerMiddle;
        this.patientHin = patientHin;
        this.patientLast = patientLast;
        this.patientFirst = patientFirst;
        this.patientBirthDate = patientBirthDate;
        this.serviceDate = serviceDate;
        this.serviceCode = serviceCode;
        this.serviceDescription = serviceDescription;
        this.serviceAmount = serviceAmount;
        this.reportFile = reportFile;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
    @Column(name = "report_id")
    private String reportId;
    @Column(name = "report_date")
    @Temporal(TemporalType.TIMESTAMP)
    private Date reportDate;
    @Column(name = "report_period_start")
    @Temporal(TemporalType.TIMESTAMP)
    private Date reportPeriodStart;
    @Column(name = "report_period_end")
    @Temporal(TemporalType.TIMESTAMP)
    private Date reportPeriodEnd;
    @Column(name = "group_id")
    private String groupId = "0000";
    @Column(name = "group_type")
    private String groupType = "";
    @Column(name = "group_name")
    private String groupName = "";
    @Column(name = "provider_ohip_no")
    private String providerOhipNo = "";
    @Column(name = "provider_last")
    private String providerLast = "";
    @Column(name = "provider_first")
    private String providerFirst = "";
    @Column(name = "provider_middle")
    private String providerMiddle = "";
    @Column(name = "patient_hin")
    private String patientHin = "";
    @Column(name = "patient_last")
    private String patientLast = "";
    @Column(name = "patient_first")
    private String patientFirst = "";
    @Column(name = "patient_dob")
    @Temporal(TemporalType.TIMESTAMP)
    private Date patientBirthDate;
    @Column(name = "service_date")
    @Temporal(TemporalType.TIMESTAMP)
    private Date serviceDate;
    @Column(name = "service_code")
    private String serviceCode = "";
    @Column(name = "service_description")
    private String serviceDescription = "";
    @Column(name = "service_amount")
    private BigDecimal serviceAmount;
    @Column(name = "report_file")
    private String reportFile = "";

    @Override
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }

    public String getReportId() {
        return reportId;
    }
    public void setReportId(String reportId) {
        this.reportId = reportId;
    }

    public Date getReportDate() {
        return reportDate;
    }
    public void setReportDate(Date reportDate) {
        this.reportDate = reportDate;
    }

    public Date getReportPeriodStart() {
        return reportPeriodStart;
    }
    public void setReportPeriodStart(Date reportPeriodStart) {
        this.reportPeriodStart = reportPeriodStart;
    }

    public Date getReportPeriodEnd() {
        return reportPeriodEnd;
    }
    public void setReportPeriodEnd(Date reportPeriodEnd) {
        this.reportPeriodEnd = reportPeriodEnd;
    }

    public String getGroupId() {
        return groupId;
    }
    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getGroupType() {
        return groupType;
    }
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    public String getGroupName() {
        return groupName;
    }
    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getProviderOhipNo() {
        return providerOhipNo;
    }
    public void setProviderOhipNo(String providerOhipNo) {
        this.providerOhipNo = providerOhipNo;
    }

    public String getProviderLast() {
        return providerLast;
    }
    public void setProviderLast(String providerLast) {
        this.providerLast = providerLast;
    }

    public String getProviderFirst() {
        return providerFirst;
    }
    public void setProviderFirst(String providerFirst) {
        this.providerFirst = providerFirst;
    }

    public String getProviderMiddle() {
        return providerMiddle;
    }
    public void setProviderMiddle(String providerMiddle) {
        this.providerMiddle = providerMiddle;
    }

    public String getPatientHin() {
        return patientHin;
    }
    public void setPatientHin(String patientHin) {
        this.patientHin = patientHin;
    }

    public String getPatientLast() {
        return patientLast;
    }
    public void setPatientLast(String patientLast) {
        this.patientLast = patientLast;
    }

    public String getPatientFirst() {
        return patientFirst;
    }
    public void setPatientFirst(String patientFirst) {
        this.patientFirst = patientFirst;
    }

    public Date getPatientBirthDate() {
        return patientBirthDate;
    }
    public void setPatientBirthDate(Date patientBirthDate) {
        this.patientBirthDate = patientBirthDate;
    }

    public Date getServiceDate() {
        return serviceDate;
    }
    public void setServiceDate(Date serviceDate) {
        this.serviceDate = serviceDate;
    }

    public String getServiceCode() {
        return serviceCode;
    }
    public void setServiceCode(String serviceCode) {
        this.serviceCode = serviceCode;
    }

    public String getServiceDescription() {
        return serviceDescription;
    }
    public void setServiceDescription(String serviceDescription) {
        this.serviceDescription = serviceDescription;
    }

    public BigDecimal getServiceAmount() {
        return serviceAmount;
    }
    public void setServiceAmount(BigDecimal serviceAmount) {
        this.serviceAmount = serviceAmount;
    }

    public String getReportFile() {
        return reportFile;
    }
    public void setReportFile(String reportFile) {
        this.reportFile = reportFile;
    }
}
    