package org.oscarehr.common.model;


import javax.persistence.*;

@Entity
@Table(name="freshbooksAppointmentInfo")
public class FreshbooksAppointmentInfo extends AbstractModel<Integer>
{
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    @Column(name = "appointment_no", nullable = false)
    private Integer appointmentNo;

    @Column(name = "appointment_provider", nullable = false)
    private String appointmentProvider;

    @Column(name = "freshbooks_invoice_id", nullable = false)
    private String freshbooksInvoiceId;

    @Column(name = "provider_freshbooks_id", nullable = false)
    private String providerFreshbooksId;

    @Override
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getAppointmentNo() {return appointmentNo;}

    public void setAppointmentNo(Integer appointmentNo) {this.appointmentNo = appointmentNo;}

    public String getAppointmentProvider() {return appointmentProvider;}

    public void setAppointmentProvider(String appointmentProvider) {this.appointmentProvider = appointmentProvider;}

    public String getFreshbooksInvoiceId() {return freshbooksInvoiceId;}

    public void setFreshbooksInvoiceId(String freshbooksInvoiceId) {this.freshbooksInvoiceId = freshbooksInvoiceId;}

    public String getProviderFreshbooksId() {return providerFreshbooksId;}

    public void setProviderFreshbooksId(String providerFreshbooksId) {this.providerFreshbooksId = providerFreshbooksId;}
}
