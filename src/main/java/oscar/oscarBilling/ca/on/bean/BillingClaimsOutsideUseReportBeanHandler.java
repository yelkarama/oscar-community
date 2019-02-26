package oscar.oscarBilling.ca.on.bean;

import noNamespace.REPORTDocument;
import org.apache.commons.lang.StringUtils;
import org.apache.xmlbeans.XmlOptions;
import org.oscarehr.common.dao.BillingONOUReportDao;
import org.oscarehr.common.model.AbstractModel;
import org.oscarehr.common.model.BillingONOUReport;
import org.oscarehr.util.SpringUtils;

import java.io.File;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Vector;

public class BillingClaimsOutsideUseReportBeanHandler {
    Vector<BillingClaimsOutsideUseReportBean> claimsOutsideUseReportBeanVector = new Vector<BillingClaimsOutsideUseReportBean>(); // OU Report bean vector
    
    public Boolean verdict = true; // verdict creating bean vector
    
    public BillingClaimsOutsideUseReportBeanHandler(String filepath) {
        init(filepath);
    }
    
    public Boolean init(String filepath) {
        BillingONOUReportDao billingONOUReportDao = SpringUtils.getBean(BillingONOUReportDao.class);
        List<AbstractModel<?>> ouReportsToSave = new ArrayList<AbstractModel<?>>();                 // holds reports to save
        String reportFile = filepath.substring(filepath.lastIndexOf("/") + 1);  // filename
        
        try {
            // set xml options
            XmlOptions opts = new XmlOptions();
            opts.setDocumentType(REPORTDocument.type);
            opts.setCharacterEncoding(StandardCharsets.ISO_8859_1.name()); // char encoding of OU files
            
            
            // parse report document and get report and group objects
            REPORTDocument.REPORT report = (REPORTDocument.Factory.parse(new File(filepath), opts)).getREPORT();
            REPORTDocument.REPORT.GROUP group = report.getGROUP();


            Calendar reportDate = report.getREPORTDTL().getREPORTDATE();
            Calendar periodStart = report.getREPORTDTL().getREPORTPERIODSTART();
            Calendar periodEnd = report.getREPORTDTL().getREPORTPERIODEND();

            String groupId = group.getGROUPDTLArray(0).getGROUPID();
            String groupType = group.getGROUPDTLArray(0).getGROUPTYPE();
            String groupName = group.getGROUPDTLArray(0).getGROUPNAME();
            
            
            // save report if no match found
            List<BillingONOUReport> reportMatches = billingONOUReportDao.match(reportDate.getTime(), periodStart.getTime(), periodEnd.getTime(), reportFile);
            boolean saveReport = reportMatches.isEmpty();
            
            
            // iterate through group providers
            for (REPORTDocument.REPORT.GROUP.PROVIDER provider : group.getPROVIDERArray()) {
                String providerBillNo = provider.getPROVIDERDTLArray(0).getPROVIDERNUMBER();
                String providerLastName = provider.getPROVIDERDTLArray(0).getPROVIDERLASTNAME();
                String providerFirstName = provider.getPROVIDERDTLArray(0).getPROVIDERFIRSTNAME();
                String providerMiddleName = StringUtils.trimToEmpty(provider.getPROVIDERDTLArray(0).getPROVIDERMIDDLENAME());
                

                // iterate through provider's patients
                for (REPORTDocument.REPORT.GROUP.PROVIDER.PATIENT patient : provider.getPATIENTArray()) {
                    String hin = patient.getPATIENTDTLArray(0).getPATIENTHEALTHNUMBER();
                    String patientLastName = patient.getPATIENTDTLArray(0).getPATIENTLASTNAME();
                    String patientFirstName = patient.getPATIENTDTLArray(0).getPATIENTFIRSTNAME();

                    
                    Calendar dateOfBirth = patient.getPATIENTDTLArray(0).getPATIENTBIRTHDATE();

                    // iterate through patient's services
                    for (REPORTDocument.REPORT.GROUP.PROVIDER.PATIENT.SERVICEDTL1 serviceData : patient.getSERVICEDTL1Array()) {
                        Calendar serviceDate = serviceData.getSERVICEDATE();
                        String serviceCode = serviceData.getSERVICECODE();
                        String serviceDescription = serviceData.getSERVICEDESCRIPTION();
                        BigDecimal serviceAmount = serviceData.getSERVICEAMT();
                        
                        //create bean for display
                        BillingClaimsOutsideUseReportBean claimsOUBean = new BillingClaimsOutsideUseReportBean();
                        claimsOUBean.setReportId(report.getREPORTDTL().getREPORTID());
                        claimsOUBean.setReportDate(reportDate.toString());
                        claimsOUBean.setReportName(report.getREPORTDTL().getREPORTNAME());
                        claimsOUBean.setReportPeriodStart(periodStart.toString());
                        claimsOUBean.setReportPeriodEnd(periodEnd.toString());

                        claimsOUBean.setGroupId(groupId);
                        claimsOUBean.setGroupType(groupType);
                        claimsOUBean.setGroupName(groupName);

                        claimsOUBean.setProviderBillNo(providerBillNo);
                        claimsOUBean.setProviderLast(providerLastName);
                        claimsOUBean.setProviderFirst(providerFirstName);
                        claimsOUBean.setProviderMiddle(providerMiddleName);

                        claimsOUBean.setHin(hin);
                        claimsOUBean.setPatientLast(patientLastName);
                        claimsOUBean.setPatientFirst(patientFirstName);
                        claimsOUBean.setDob(dateOfBirth.toString());
                        claimsOUBean.setPatientSex(patient.getPATIENTDTLArray(0).getPATIENTSEX().toString());

                        claimsOUBean.setServiceDate(serviceDate.toString());
                        claimsOUBean.setServiceCode(serviceCode);
                        claimsOUBean.setServiceDescription(serviceDescription);
                        claimsOUBean.setServiceAmount(serviceAmount);
                        
                        claimsOutsideUseReportBeanVector.add(claimsOUBean);
                        
                        if (saveReport) {
                            // add to list of reports to save
                            ouReportsToSave.add(new BillingONOUReport(report.getREPORTDTL().getREPORTID(), reportDate.getTime(), periodStart.getTime(), periodEnd.getTime(),
                                    groupId, groupType, groupName,
                                    providerBillNo, providerLastName, providerFirstName, providerMiddleName,
                                    hin, patientLastName, patientFirstName, dateOfBirth.getTime(),
                                    serviceDate.getTime(), serviceCode, serviceDescription, serviceAmount,
                                    reportFile));
                        }
                    }
                }
            }
            
            if (saveReport) {
                // save all reports
                billingONOUReportDao.batchPersist(ouReportsToSave);
            }
        } catch (Exception e) {
            verdict = false;
            e.printStackTrace();
        }

        return verdict;
    }

    public Vector getClaimsOutsideUseReportBeanVector() {
        return claimsOutsideUseReportBeanVector;
    }
    public void setClaimsOutsideUseReportBeanVector(Vector claimsOutsideUseReportBeanVector) {
        this.claimsOutsideUseReportBeanVector = claimsOutsideUseReportBeanVector;
    }

    public Boolean getVerdict() {
        return verdict;
    }
    public void setVerdict(Boolean verdict) {
        this.verdict = verdict;
    }
}
