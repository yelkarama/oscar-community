package org.oscarehr.olis.model;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class OlisMeasurementsResultDisplay {
    
    private OlisLabResultDisplay parentLab;

    private int measurementObxIndex;
    private String testResultName = "";
    private String status = "";
    private String resultValue = "";
    private String flag = "";
    private String referenceRange = "";
    private String units = "";
    private boolean isAbnormal = false;
    private String natureOfAbnormalText = "";
    private List<String> comments = new ArrayList<>();
    private boolean isAttachment = false;
    private boolean isInvalid = false;
    private boolean isBlocked = false;
    private OlisLabResultSortable resultSortable;
            
    OlisMeasurementsResultDisplay() { }

    public int getMeasurementObxIndex() {
        return measurementObxIndex;
    }
    public void setMeasurementObxIndex(int measurementObxIndex) {
        this.measurementObxIndex = measurementObxIndex;
    }

    public OlisLabResultDisplay getParentLab() {
        return parentLab;
    }
    public void setParentLab(OlisLabResultDisplay parentLab) {
        this.parentLab = parentLab;
    }

    public String getTestResultName() {
        return testResultName;
    }
    public void setTestResultName(String testResultName) {
        this.testResultName = testResultName;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getResultValue() {
        return resultValue;
    }
    public void setResultValue(String resultValue) {
        this.resultValue = resultValue;
    }

    public String getFlag() {
        return flag;
    }
    public void setFlag(String flag) {
        this.flag = flag;
    }

    public String getReferenceRange() {
        return referenceRange;
    }
    public void setReferenceRange(String referenceRange) {
        this.referenceRange = referenceRange;
    }

    public String getUnits() {
        return units;
    }
    public void setUnits(String units) {
        this.units = units;
    }

    public boolean isAbnormal() {
        return isAbnormal;
    }
    public void setAbnormal(boolean abnormal) {
        isAbnormal = abnormal;
    }

    public String getNatureOfAbnormalText() {
        return natureOfAbnormalText;
    }
    public void setNatureOfAbnormalText(String natureOfAbnormalText) {
        this.natureOfAbnormalText = natureOfAbnormalText;
    }

    public List<String> getComments() {
        return comments;
    }
    public void setComments(List<String> comments) {
        this.comments = comments;
    }

    public boolean isAttachment() {
        return isAttachment;
    }
    public void setIsAttachment(boolean attachment) {
        isAttachment = attachment;
    }

    public boolean isInvalid() {
        return isInvalid;
    }
    public void setInvalid(boolean invalid) {
        isInvalid = invalid;
    }

    public boolean isBlocked() {
        return isBlocked;
    }
    public void setBlocked(boolean blocked) {
        isBlocked = blocked;
    }

    public OlisLabResultSortable getResultSortable() {
        return resultSortable;
    }
    public void setResultSortable(OlisLabResultSortable resultSortable) {
        this.resultSortable = resultSortable;
    }

    /**
     * Compares two OlisMeasurementResultDisplay objects to order them to OLIS' specifications
     * 
     * The order and priority that is achieved is as follows: 
     * 1. Collection Date/Time
     * 2. Request Placer Group Number
     * 3. Request ZBR11 Sort Key
     * 4. Request Nomenclature Alternate Name 1
     * 5. Request Set Id
     * 
     * If the previous attributes are all the same, then it proceeds to sort the results using the OLIS_RESULT_COMPARATOR
     */
    static final Comparator<OlisMeasurementsResultDisplay> DEFAULT_OLIS_SORT_COMPARATOR = new Comparator<OlisMeasurementsResultDisplay>() {
        @Override
        public int compare(OlisMeasurementsResultDisplay o1, OlisMeasurementsResultDisplay o2) {
            // Compares the collection dates, using o2 as the basis in order to order it in reverse chronological
            // If They are the same value, continues comparing other elements to determine order
            int compared = o2.getParentLab().getCollectionDateAsDate().compareTo(o1.getParentLab().getCollectionDateAsDate());
            if (compared == 0) {
                // Compares placer group numbers, continuing to compare other attributes if they are the same
                compared = o1.getParentLab().getPlacerGroupNo().compareTo(o2.getParentLab().getPlacerGroupNo());
                if (compared == 0) {
                    // Compares the ZBR11 sort key, continuing to compare other attributes if they are the same
                    compared = o1.getParentLab().getTestRequestZbr11().compareTo(o2.getParentLab().getTestRequestZbr11());
                    if (compared == 0) {
                        // Compares the alternate names stored in the nomenclature, continuing to compare other attributes if they are the same
                        compared = o1.getParentLab().getNomenclature().getRequestAlternateName1().compareTo(o2.getParentLab().getNomenclature().getRequestAlternateName1());
                        if (compared == 0) {
                            // Compares the set ids to determine order
                            compared = Integer.compare(o1.getParentLab().getObrSetId(), o2.getParentLab().getObrSetId());
                        }
                    }
                }
            }

            // If the two measurements are under the same request, compares the results
            if (compared == 0) {
                compared = OlisLabResultSortable.OLIS_RESULT_COMPARATOR.compare(o1.getResultSortable(), o2.getResultSortable());
            }
            
            // Returns the value retrieved from comparing
            return compared;
        }
    };
}
