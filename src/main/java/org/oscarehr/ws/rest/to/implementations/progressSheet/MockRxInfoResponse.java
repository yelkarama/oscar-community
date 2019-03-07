package org.oscarehr.ws.rest.to.implementations.progressSheet;

import java.util.Date;
import java.util.Map;

public class MockRxInfoResponse {

    private long formId;
    private Long progressSheetId;
    private int demographicId;
    private String providerId;
    private int appointmentId;
    private int invoiceId;
    private Date encounterDate;
    private Map<String, String> fieldValueMap;

    public MockRxInfoResponse() {}

    public long getFormId() {
        return formId;
    }

    public void setFormId(long formId) {
        this.formId = formId;
    }

    public Long getProgressSheetId() {
        return progressSheetId;
    }

    public void setProgressSheetId(Long progressSheetId) {
        this.progressSheetId = progressSheetId;
    }

    public int getDemographicId() {
        return demographicId;
    }

    public void setDemographicId(int demographicId) {
        this.demographicId = demographicId;
    }

    public String getProviderId() {
        return providerId;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public Date getEncounterDate() {
        return encounterDate;
    }

    public void setEncounterDate(Date encounterDate) {
        this.encounterDate = encounterDate;
    }

    public Map<String, String> getFieldValueMap() {
        return fieldValueMap;
    }

    public void setFieldValueMap(Map<String, String> fieldValueMap) {
        this.fieldValueMap = fieldValueMap;
    }
}
