package org.oscarehr.olis.model;

import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class OlisLabResults {

    private List<OlisLabResultDisplay> resultList = new ArrayList<OlisLabResultDisplay>();
    private List<OLISHL7Handler.OLISError> errors =  new ArrayList<OLISHL7Handler.OLISError>();
    private boolean hasBlockedContent = false;
    private boolean hasRequestingProvider = false;
    private boolean display320Error = false;
    
    private String demographicName = "";
    private String demographicHin = "";
    private String demographicMrn = "";
    private String demographicSex = "";
    private String demographicDob = "";

    public OlisLabResults() { }

    public List<OlisLabResultDisplay> getResultList() {
        return resultList;
    }
    public void setResultList(List<OlisLabResultDisplay> resultList) {
        this.resultList = resultList;
    }

    public List<OlisMeasurementsResultDisplay> getAllMeasurements() {
        List<OlisMeasurementsResultDisplay> results = new ArrayList<OlisMeasurementsResultDisplay>();
        for (OlisLabResultDisplay olisLabResultDisplay : getResultList()) {
            results.addAll(olisLabResultDisplay.getMeasurements());
        }

        return results;
    }

    public List<OLISHL7Handler.OLISError> getErrors() {
        return errors;
    }
    public void setErrors(List<OLISHL7Handler.OLISError> errors) {
        this.errors = errors;
    }

    public boolean isHasBlockedContent() {
        return hasBlockedContent;
    }
    public void setHasBlockedContent(boolean hasBlockedContent) {
        this.hasBlockedContent = hasBlockedContent;
    }

    public boolean isHasRequestingProvider() {
        return hasRequestingProvider;
    }
    public void setHasRequestingProvider(boolean hasRequestingProvider) {
        this.hasRequestingProvider = hasRequestingProvider;
    }

    public boolean isDisplay320Error() {
        return display320Error;
    }
    public void setDisplay320Error(boolean display320Error) {
        this.display320Error = display320Error;
    }

    public String getDemographicName() {
        return demographicName;
    }
    public void setDemographicName(String demographicName) {
        this.demographicName = demographicName;
    }

    public String getDemographicHin() {
        return demographicHin;
    }
    public void setDemographicHin(String demographicHin) {
        this.demographicHin = demographicHin;
    }

    public String getDemographicMrn() {
        return demographicMrn;
    }
    public void setDemographicMrn(String demographicMrn) {
        this.demographicMrn = demographicMrn;
    }

    public String getDemographicSex() {
        return demographicSex;
    }
    public void setDemographicSex(String demographicSex) {
        this.demographicSex = demographicSex;
    }

    public String getDemographicDob() {
        return demographicDob;
    }
    public void setDemographicDob(String demographicDob) {
        this.demographicDob = demographicDob;
    }
    
    public void setDemographicInfo(OLISHL7Handler reportHandler) {
        this.setDemographicName(reportHandler.getPatientName());
        if (reportHandler.getPatientIdentifier("JHN") != null && reportHandler.getPatientIdentifier("JHN").length > 0) {
            this.setDemographicHin(reportHandler.getPatientIdentifier("JHN")[0]);
        }
        if (reportHandler.getPatientIdentifier("MR") != null && reportHandler.getPatientIdentifier("MR").length > 1) {
            String[] identifiers = reportHandler.getPatientIdentifier("MR");
            String hospital = reportHandler.getSourceOrganization(identifiers[1]);
            this.setDemographicMrn(identifiers[0] + " " + hospital + " (Lab " + identifiers[1] + ")");
        }
        this.setDemographicSex(reportHandler.getSex());
        this.setDemographicDob(reportHandler.getDOB());
    }
}
