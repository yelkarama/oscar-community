package org.oscarehr.olis.model;

import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class OlisLabResultListDisplay {
    
    private String labUuid;
    private int labObrIndex;
    
    
    private String placerGroupNo;
    private String testRequestSortKey;

    private String patientHealthNumber = "";
    private String patientName = "";
    private String patientSex = "";
    
    private String testRequestName;
    private String status;
    private String specimentType;
    private String resultsIndicator;
    
    private String orderingPractitioner;
    private String admittingPractitioner;
    
    private String reportingFacilityName = "";
    
    private String olisLastUpdated;
    private String collectionDate;

    public OlisLabResultListDisplay() { }

    public String getLabUuid() {
        return labUuid;
    }
    public void setLabUuid(String labUuid) {
        this.labUuid = labUuid;
    }

    public int getLabObrIndex() {
        return labObrIndex;
    }
    public void setLabObrIndex(int labObrIndex) {
        this.labObrIndex = labObrIndex;
    }

    public String getPlacerGroupNo() {
        return placerGroupNo;
    }
    public void setPlacerGroupNo(String placerGroupNo) {
        this.placerGroupNo = placerGroupNo;
    }

    public String getTestRequestSortKey() {
        return testRequestSortKey;
    }
    public void setTestRequestSortKey(String testRequestSortKey) {
        this.testRequestSortKey = testRequestSortKey;
    }

    public String getPatientHealthNumber() {
        return patientHealthNumber;
    }
    public void setPatientHealthNumber(String patientHealthNumber) {
        this.patientHealthNumber = patientHealthNumber;
    }

    public String getPatientName() {
        return patientName;
    }
    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getPatientSex() {
        return patientSex;
    }
    public void setPatientSex(String patientSex) {
        this.patientSex = patientSex;
    }

    public String getTestRequestName() {
        return testRequestName;
    }
    public void setTestRequestName(String testRequestName) {
        this.testRequestName = testRequestName;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getSpecimentType() {
        return specimentType;
    }
    public void setSpecimentType(String specimentType) {
        this.specimentType = specimentType;
    }

    public String getResultsIndicator() {
        return resultsIndicator;
    }
    public void setResultsIndicator(String resultsIndicator) {
        this.resultsIndicator = resultsIndicator;
    }

    public String getReportingFacilityName() {
        return reportingFacilityName;
    }
    public void setReportingFacilityName(String reportingFacilityName) {
        this.reportingFacilityName = reportingFacilityName;
    }

    public String getOrderingPractitioner() {
        return orderingPractitioner;
    }
    public void setOrderingPractitioner(String orderingPractitioner) {
        this.orderingPractitioner = orderingPractitioner;
    }

    public String getAdmittingPractitioner() {
        return admittingPractitioner;
    }
    public void setAdmittingPractitioner(String admittingPractitioner) {
        this.admittingPractitioner = admittingPractitioner;
    }

    public String getOlisLastUpdated() {
        return olisLastUpdated;
    }
    public void setOlisLastUpdated(String olisLastUpdated) {
        this.olisLastUpdated = olisLastUpdated;
    }

    public String getCollectionDate() {
        return collectionDate;
    }
    public void setCollectionDate(String collectionDate) {
        this.collectionDate = collectionDate;
    }

    public static List<OlisLabResultListDisplay> getListFromHandler(OLISHL7Handler olisHandler, String resultUuid) {
        List<OlisLabResultListDisplay> results = new ArrayList<OlisLabResultListDisplay>();
        
        ArrayList headers = olisHandler.getHeaders();
        for (int i = 0; i < headers.size(); i++) {
            
            int obr = olisHandler.getMappedOBR(i);
            int lineNumber = obr + 1;
            if (olisHandler.isChildOBR(lineNumber)) {
                continue;
            }

            OlisLabResultListDisplay labResult = new OlisLabResultListDisplay();

            // Lab specific values
            labResult.setLabUuid(resultUuid);
            labResult.setLabObrIndex(obr);
            labResult.setTestRequestName(olisHandler.getOBRName(obr));
            labResult.setStatus(olisHandler.getObrStatus(obr));
            labResult.setSpecimentType(olisHandler.getObrSpecimenSource(obr));
            labResult.setResultsIndicator(olisHandler.getObrStatus(obr));
            labResult.setTestRequestSortKey(olisHandler.getZBR11(obr));
            
            // Report level values
            labResult.setPatientHealthNumber(olisHandler.getHealthNum());
            labResult.setPatientName(olisHandler.getPatientName());
            labResult.setPatientSex(olisHandler.getSex());
            labResult.setOrderingPractitioner(olisHandler.getShortDocName());
            labResult.setAdmittingPractitioner(olisHandler.getAdmittingProviderNameShort());
            labResult.setOlisLastUpdated(olisHandler.getLastUpdateInOLIS());
            labResult.setReportingFacilityName(olisHandler.getReportingFacilityName());
            
            String collectionDate = olisHandler.getCollectionDateTime(obr);
            if (collectionDate.contains(" - ")) {
                collectionDate = collectionDate.substring(0, collectionDate.indexOf(" - "));
            }
            labResult.setCollectionDate(collectionDate);
            
            String orderStatusCode = olisHandler.getOrderStatus();
            if ("P".equals(orderStatusCode)) {
                labResult.setStatus("Partial");
            } else if ("F".equals(orderStatusCode)) {
                labResult.setStatus("Final");
            } else if ("C".equals(orderStatusCode)) {
                labResult.setStatus("Corrected");
            }
            
            labResult.setPlacerGroupNo(olisHandler.getAccessionNum());
            
            results.add(labResult);
        }
        
        return results;
    }

    public static final Comparator<OlisLabResultListDisplay> DEFAULT_OLIS_SORT_COMPARATOR = new Comparator<OlisLabResultListDisplay>() {
        @Override
        public int compare(OlisLabResultListDisplay o1, OlisLabResultListDisplay o2) {
            int placerGroupNoCompare = o1.getPlacerGroupNo().compareTo(o2.getPlacerGroupNo());
            int requestSortKeyCompare = o1.getTestRequestSortKey().compareTo(o2.getTestRequestSortKey());
            
            if (placerGroupNoCompare == 0) {
                return ((requestSortKeyCompare == 0) ? placerGroupNoCompare : requestSortKeyCompare);
            } else {
                return placerGroupNoCompare;
            }
        }
    };
}
