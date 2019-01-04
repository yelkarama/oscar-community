package org.oscarehr.ws.rest.to.model;
import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;

public class BillingExtensionTo1 implements Serializable {

    private String keyVal;
    private String value;
    private Date dateTime = new Timestamp(System.currentTimeMillis());
    private char status = '1';
    private Integer paymentId = 0;

    public String getKeyVal() {
        return keyVal;
    }

    public void setKeyVal(String keyVal) {
        this.keyVal = keyVal;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Date getDateTime() {
        return dateTime;
    }

    public void setDateTime(Date dateTime) {
        this.dateTime = dateTime;
    }

    public char getStatus() {
        return status;
    }

    public void setStatus(char status) {
        this.status = status;
    }

    public Integer getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Integer paymentId) {
        this.paymentId = paymentId;
    }
}
