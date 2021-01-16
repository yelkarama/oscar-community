package org.oscarehr.ws.rest.to.model;

import java.util.Date;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "measurement")
public class MeasurementTo1 {

    private Integer id;
    private String type;
    private Integer demographicId;
    private String providerNo;
    private String dataField = "";
    private String measuringInstruction = "";
    private String comments = "";
    private Date dateObserved;
    private Integer appointmentNo;
    private Date createDate = new Date();

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Integer getDemographicId() {
        return demographicId;
    }

    public void setDemographicId(Integer demographicId) {
        this.demographicId = demographicId;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public String getDataField() {
        return dataField;
    }

    public void setDataField(String dataField) {
        this.dataField = dataField;
    }

    public String getMeasuringInstruction() {
        return measuringInstruction;
    }

    public void setMeasuringInstruction(String measuringInstruction) {
        this.measuringInstruction = measuringInstruction;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public Date getDateObserved() {
        return dateObserved;
    }

    public void setDateObserved(Date dateObserved) {
        this.dateObserved = dateObserved;
    }

    public Integer getAppointmentNo() {
        return appointmentNo;
    }

    public void setAppointmentNo(Integer appointmentNo) {
        this.appointmentNo = appointmentNo;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }
}