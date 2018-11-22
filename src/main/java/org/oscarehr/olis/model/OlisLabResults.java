package org.oscarehr.olis.model;

import oscar.oscarLab.ca.all.parsers.OLISHL7Handler;

import java.util.ArrayList;
import java.util.List;

public class OlisLabResults {

    private List<OlisLabResultListDisplay> resultList = new ArrayList<OlisLabResultListDisplay>();
    private List<OLISHL7Handler.OLISError> errors =  new ArrayList<OLISHL7Handler.OLISError>();
    private boolean hasBlockedContent = false;

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
}
