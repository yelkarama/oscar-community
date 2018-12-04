package org.oscarehr.olis.model;

import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class OlisLabResultDisplay {
    
    private String labUuid;
    private int labObrIndex;
    private String placerGroupNo;
    private String testRequestSortKey;
    private String testRequestName;
    private String status;
    private String specimenType;
    private String resultsIndicator;
    private String orderingPractitioner;
    private String orderingPractitionerFull;
    private String admittingPractitioner;
    private String reportingFacilityName = "";
    private String olisLastUpdated;
    private String collectionDate;
    private String collectorsComment;
    
    private List<OlisMeasurementsResultDisplay> measurements = new ArrayList<OlisMeasurementsResultDisplay>();

    public OlisLabResultDisplay() { }

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

    public String getSpecimenType() {
        return specimenType;
    }
    public void setSpecimenType(String specimentType) {
        this.specimenType = specimentType;
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

    public String getOrderingPractitionerFull() {
        return orderingPractitionerFull;
    }
    public void setOrderingPractitionerFull(String orderingPractitionerFull) {
        this.orderingPractitionerFull = orderingPractitionerFull;
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

    public String getCollectorsComment() {
        return collectorsComment;
    }
    public void setCollectorsComment(String collectorsComment) {
        this.collectorsComment = collectorsComment;
    }

    public List<OlisMeasurementsResultDisplay> getMeasurements() {
        return measurements;
    }
    public void setMeasurements(List<OlisMeasurementsResultDisplay> measurements) {
        this.measurements = measurements;
    }

    public static List<OlisLabResultDisplay> getListFromHandler(OLISHL7Handler olisHandler, String resultUuid) {
        List<OlisLabResultDisplay> results = new ArrayList<OlisLabResultDisplay>();
        
        ArrayList headers = olisHandler.getHeaders();
        for (int i = 0; i < headers.size(); i++) {
            
            int obr = olisHandler.getMappedOBR(i);
            int lineNumber = obr + 1;
            if (olisHandler.isChildOBR(lineNumber)) {
                continue;
            }

            OlisLabResultDisplay labResult = new OlisLabResultDisplay();

            // Lab specific values
            labResult.setLabUuid(resultUuid);
            labResult.setLabObrIndex(obr);
            labResult.setTestRequestName(olisHandler.getOBRName(obr));
            labResult.setStatus(olisHandler.getObrStatus(obr));
            labResult.setSpecimenType(olisHandler.getObrSpecimenSource(obr));
            labResult.setResultsIndicator(olisHandler.getObrStatus(obr));
            labResult.setTestRequestSortKey(olisHandler.getZBR11(obr));
            labResult.setCollectorsComment(olisHandler.getCollectorsComment(obr));
            
            // Report level values
            labResult.setOrderingPractitioner(olisHandler.getShortDocName());
            labResult.setOrderingPractitionerFull(olisHandler.getDocName());
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

            for (int obx = 0; obx < olisHandler.getOBXCount(obr); obx++) {
                OlisMeasurementsResultDisplay measurement = new OlisMeasurementsResultDisplay();
                measurement.setMeasurementObxIndex(obx);
                measurement.setParentLab(labResult);
                measurement.setTestResultName(olisHandler.getOBXName(obr, obx));
                measurement.setStatus(olisHandler.getTestResultStatusMessage(olisHandler.getOBXResultStatus(obr, obx).charAt(0)));
                measurement.setResultValue(olisHandler.getOBXResult(obr, obx));
                measurement.setFlag(olisHandler.getOBXAbnormalFlag(obr, obx));
                measurement.setReferenceRange(olisHandler.getOBXReferenceRange(obr, obx));
                measurement.setUnits(olisHandler.getOBXUnits(obr, obx));
                String abnormal = olisHandler.getOBXAbnormalFlag(obr, obx);
                measurement.setAbnormal(abnormal != null && (abnormal.equals("A") || abnormal.startsWith("H") || olisHandler.isOBXAbnormal(obr, obx)));
                measurement.setNatureOfAbnormalText(olisHandler.getNatureOfAbnormalTest(obr, obx));
                measurement.setIsAttachment("ED".equals(olisHandler.getOBXValueType(obr, obx).trim()));

                for (int commentIndex = 0; commentIndex < olisHandler.getOBXCommentCount(obr, obx); commentIndex++) {
                    measurement.getComments().add(olisHandler.getOBXComment(obr, obx, commentIndex));
                }
                
                labResult.getMeasurements().add(measurement);
            }
            
            results.add(labResult);
        }
        
        return results;
    }

    public static final Comparator<OlisLabResultDisplay> DEFAULT_OLIS_SORT_COMPARATOR = new Comparator<OlisLabResultDisplay>() {
        @Override
        public int compare(OlisLabResultDisplay o1, OlisLabResultDisplay o2) {
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
