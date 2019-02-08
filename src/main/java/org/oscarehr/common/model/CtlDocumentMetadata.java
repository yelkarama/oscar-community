package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "ctl_document_metadata")
public class CtlDocumentMetadata extends AbstractModel<Integer> {
    public enum Status {
        NEW("N"),
        FAXED("F");
        
        private final String code;
        
        Status(String code) {
            this.code = code;
        }
        
        public String getCode() {
            return this.code;
        }
    }
    
    
    @Id
    @GeneratedValue
    @Column(name = "id")
    private Integer id;
    @Column(name = "document_no")
    private Integer documentNo;
    @Column(name = "appointment_no")
    private Integer appointmentNo;
    @Column(name = "status")
    private String status;

    public CtlDocumentMetadata(){}

    public CtlDocumentMetadata(Integer documentNo, Integer appointmentNo) {
        this.documentNo = documentNo;
        this.appointmentNo = appointmentNo;
        this.status = Status.NEW.getCode();
    }

    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getDocumentNo() {
        return documentNo;
    }
    public void setDocumentNo(Integer documentNo) {
        this.documentNo = documentNo;
    }

    public Integer getAppointmentNo() {
        return appointmentNo;
    }
    public void setAppointmentNo(Integer appointmentNo) {
        this.appointmentNo = appointmentNo;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
}
