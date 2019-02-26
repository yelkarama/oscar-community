package oscar.oscarBilling.ca.on.bean;

import java.math.BigDecimal;
import java.util.Date;

public class BillingClaimsOutsideUseReportBean {
    public BillingClaimsOutsideUseReportBean() {
    }

    public BillingClaimsOutsideUseReportBean(String reportId, String reportDate, String reportName, String reportPeriodStart, String reportPeriodEnd,
                                             String groupId, String groupType, String groupName,
                                             String providerBillNo, String providerLast, String providerFirst, String providerMiddle,
                                             String hin, String patientLast, String patientFirst, String dob, String patientSex,
                                             String serviceDate, String serviceCode, String serviceDescription, BigDecimal serviceAmount) {
        this.reportId = reportId;
        this.reportDate = reportDate;
        this.reportName = reportName;
        this.reportPeriodStart = reportPeriodStart;
        this.reportPeriodEnd = reportPeriodEnd;
        this.groupId = groupId;
        this.groupType = groupType;
        this.groupName = groupName;
        this.providerBillNo = providerBillNo;
        this.providerLast = providerLast;
        this.providerFirst = providerFirst;
        this.providerMiddle = providerMiddle;
        this.hin = hin;
        this.patientLast = patientLast;
        this.patientFirst = patientFirst;
        this.dob = dob;
        this.patientSex = patientSex;
        this.serviceDate = serviceDate;
        this.serviceCode = serviceCode;
        this.serviceDescription = serviceDescription;
        this.serviceAmount = serviceAmount;
    }

    String reportId = "";
    String reportDate;
    String reportName = "";
    String reportPeriodStart;
    String reportPeriodEnd;
    
    String groupId = "";
    String groupType = "";
    String groupName = "";
    
    String providerBillNo = "";
    String providerLast = "";
    String providerFirst = "";
    String providerMiddle = "";
    
    String hin = "";
    String patientLast = "";
    String patientFirst = "";
    String dob = "";
    String patientSex = "";
    
    String serviceDate;
    String serviceCode = "";
    String serviceDescription = "";   // only for group type FHN/FHO
    BigDecimal serviceAmount;       // only for group type FHN/FHO

    public String getReportId() {
        return reportId;
    }
    public void setReportId(String reportId) {
        this.reportId = reportId;
    }

    public String getReportDate() {
        return reportDate;
    }
    public void setReportDate(String reportDate) {
        this.reportDate = reportDate;
    }

    public String getReportName() {
        return reportName;
    }
    public void setReportName(String reportName) {
        this.reportName = reportName;
    }

    public String getReportPeriodStart() {
        return reportPeriodStart;
    }
    public void setReportPeriodStart(String reportPeriodStart) {
        this.reportPeriodStart = reportPeriodStart;
    }

    public String getReportPeriodEnd() {
        return reportPeriodEnd;
    }
    public void setReportPeriodEnd(String reportPeriodEnd) {
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

    public String getProviderBillNo() {
        return providerBillNo;
    }
    public void setProviderBillNo(String providerBillNo) {
        this.providerBillNo = providerBillNo;
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

    public String getHin() {
        return hin;
    }
    public void setHin(String hin) {
        this.hin = hin;
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

    public String getDob() {
        return dob;
    }
    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getPatientSex() {
        return patientSex;
    }
    public void setPatientSex(String patientSex) {
        this.patientSex = patientSex;
    }

    public String getServiceDate() {
        return serviceDate;
    }
    public void setServiceDate(String serviceDate) {
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
}
