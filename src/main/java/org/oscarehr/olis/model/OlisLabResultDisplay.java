package org.oscarehr.olis.model;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.CompareToBuilder;
import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class OlisLabResultDisplay {
    
    private String labUuid;
    private int labObrIndex;
    private String placerGroupNo;
    private String testRequestZbr11;
    private String testRequestName;
    private String requestStatus;
    private String specimenType;
    private String resultsIndicator;
    private String orderingPractitioner;
    private String orderingPractitionerFull;
    private String admittingPractitioner;
    private String reportingFacilityName = "";
    private String olisLastUpdated;
    private String collectionDate;
    private String collectorsComment;
    private OLISRequestNomenclature nomenclature;
    
    private List<OlisMeasurementsResultDisplay> measurements = new ArrayList<OlisMeasurementsResultDisplay>();
    
    private static SimpleDateFormat collectionDateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss z");

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

    public String getTestRequestZbr11() {
        return testRequestZbr11;
    }
    public void setTestRequestZbr11(String testRequestZbr11) {
        this.testRequestZbr11 = testRequestZbr11;
    }

    public String getTestRequestName() {
        return testRequestName;
    }
    public void setTestRequestName(String testRequestName) {
        this.testRequestName = testRequestName;
    }

    public String getRequestStatus() {
        return requestStatus;
    }
    public void setRequestStatus(String requestStatus) {
        this.requestStatus = requestStatus;
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

    public Date getCollectionDateAsDate() {
        try {
            return collectionDateTimeFormatter.parse(collectionDate);
        } catch (ParseException e) {
            return null;
        }
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

    public OLISRequestNomenclature getNomenclature() {
        return nomenclature;
    }
    public void setNomenclature(OLISRequestNomenclature nomenclature) {
        this.nomenclature = nomenclature;
    }

    public List<OlisMeasurementsResultDisplay> getMeasurements() {
        return measurements;
    }
    public void setMeasurements(List<OlisMeasurementsResultDisplay> measurements) {
        this.measurements = measurements;
    }

    public static List<OlisLabResultDisplay> getListFromHandler(OLISHL7Handler olisHandler, String resultUuid) {
        List<OlisLabResultDisplay> results = new ArrayList<OlisLabResultDisplay>();
        
        // Get OLIS Request Nomenclature for lab results for adding to results
        Map<String, OLISRequestNomenclature> nomenclatureMap = olisHandler.getOlisRequestNomenclatureMap();
        
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
            labResult.setRequestStatus(olisHandler.getTestRequestStatusMessage(olisHandler.getObrStatusFinal(obr).charAt(0)));
            labResult.setSpecimenType(olisHandler.getOBRSpecimentType(obr));
            labResult.setResultsIndicator(olisHandler.getObrStatus(obr));
            labResult.setTestRequestZbr11(olisHandler.getZBR11(obr));
            labResult.setCollectorsComment(olisHandler.getCollectorsComment(obr));
            labResult.setNomenclature(nomenclatureMap.get(olisHandler.getNomenclatureRequestCode(obr)));
            
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
            
            labResult.setPlacerGroupNo(olisHandler.getAccessionNum());

            int obxCount = olisHandler.getOBXCount(obr);
            if (obxCount > 0) {
                for (int obx = 0; obx < obxCount; obx++) {
                    String resultStatus = olisHandler.getOBXResultStatus(obr, obx).trim();
                    
                    // Gets the OBX value type
                    String valueType = olisHandler.getOBXValueType(obr,obx).trim();
                    String resultValue;
                    // If the value type is a coded entry, it needs to get OBX 5.2
                    // If it isn't a coded entry, then gets OBX 5.1
                    if (valueType.equals("CE")) {
                        resultValue = olisHandler.getOBXCEName(obr, obx);
                    } else {
                        resultValue = olisHandler.getOBXResult(obr, obx);
                    }
                    
                    OlisMeasurementsResultDisplay measurement = new OlisMeasurementsResultDisplay();
                    measurement.setMeasurementObxIndex(obx);
                    measurement.setParentLab(labResult);
                    measurement.setTestResultName(olisHandler.getOBXName(obr, obx));
                    measurement.setStatus(olisHandler.getTestResultStatusMessage(resultStatus.charAt(0)));
                    measurement.setResultValue(resultValue);
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

                    // Checks if the results is invalid, a status of W, and if it is, sets the flag
                    if (resultStatus.equalsIgnoreCase("W")) {
                        measurement.setInvalid(true);
                    }
                    
                    labResult.getMeasurements().add(measurement);
                }
            } else {
                int commentCount = olisHandler.getOBRCommentCount(obr);
                for (int cc = 0; cc < commentCount; cc++) {
                    String comment = olisHandler.getOBRComment(obr, cc);
                    
                    OlisMeasurementsResultDisplay result = new OlisMeasurementsResultDisplay();
                    result.setMeasurementObxIndex(0);
                    result.setParentLab(labResult);
                    result.getComments().add(comment);
                    labResult.getMeasurements().add(result);
                }
            }
            
            results.add(labResult);
        }
        
        return results;
    }

    public static final Comparator<OlisLabResultDisplay> DEFAULT_OLIS_SORT_COMPARATOR = new Comparator<OlisLabResultDisplay>() {
        @Override
        public int compare(OlisLabResultDisplay o1, OlisLabResultDisplay o2) {
            CompareToBuilder compareToBuilder = new CompareToBuilder();
            compareToBuilder.append(o2.getCollectionDateAsDate(), o1.getCollectionDateAsDate());
            compareToBuilder.append(o1.getPlacerGroupNo(), o2.getPlacerGroupNo());

            if (!StringUtils.isEmpty(o1.getTestRequestZbr11()) && !StringUtils.isEmpty(o2.getTestRequestZbr11())) {
                compareToBuilder.append(o1.getTestRequestZbr11(), o2.getTestRequestZbr11());
            }
            if (o1.getNomenclature() != null && o2.getNomenclature() != null) {
                if (!StringUtils.isEmpty(o1.getNomenclature().getSortKey()) && !StringUtils.isEmpty(o2.getNomenclature().getSortKey())) {
                    compareToBuilder.append(o1.getNomenclature().getSortKey(), o2.getNomenclature().getSortKey());
                }
                if (!StringUtils.isEmpty(o1.getNomenclature().getRequestAlternateName1()) && !StringUtils.isEmpty(o1.getNomenclature().getRequestAlternateName1())) {
                    compareToBuilder.append(o1.getNomenclature().getRequestAlternateName1(), o2.getNomenclature().getRequestAlternateName1());
                }
            }
            compareToBuilder.append(o1.getLabObrIndex(), o2.getLabObrIndex());
            
            return compareToBuilder.toComparison();
        }
    };
}