package org.oscarehr.olis.model;

import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

import java.util.ArrayList;
import java.util.List;

public class OlisLabResults {

    private List<OlisLabResultListDisplay> resultList = new ArrayList<OlisLabResultListDisplay>();
    private List<OLISHL7Handler.OLISError> errors =  new ArrayList<OLISHL7Handler.OLISError>();
    private boolean hasBlockedContent = false;
    
    private String demographicName = "";
    private String demographicHin = "";
    private String demographicMrn = "";
    private String demographicSex = "";
    private String demographicDob = "";

    public OlisLabResults() { }

    public List<OlisLabResultListDisplay> getResultList() {
        return resultList;
    }
    public void setResultList(List<OlisLabResultListDisplay> resultList) {
        this.resultList = resultList;
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
}
