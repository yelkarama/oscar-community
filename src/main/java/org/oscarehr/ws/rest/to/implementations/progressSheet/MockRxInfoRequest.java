package org.oscarehr.ws.rest.to.implementations.progressSheet;

import java.util.ArrayList;
import java.util.List;

public class MockRxInfoRequest {
    private List<Integer> appointmentIds = new ArrayList<Integer>();
    private List<String> fieldKeys = new ArrayList<String>();

    public List<Integer> getAppointmentIds() {
        return appointmentIds;
    }

    public void setAppointmentIds(List<Integer> appointmentIds) {
        this.appointmentIds = appointmentIds;
    }

    public List<String> getFieldKeys() {
        return fieldKeys;
    }

    public void setFieldKeys(List<String> fieldKeys) {
        this.fieldKeys = fieldKeys;
    }
}
