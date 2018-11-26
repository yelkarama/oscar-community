package oscar.form.model;

import com.sun.istack.NotNull;
import org.oscarehr.common.model.AbstractModel;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.PrePersist;
import javax.persistence.Table;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "form_on_perinatal_2017")
public class FormONPerinatal2017 extends AbstractModel<Integer> implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull
    @Column(name = "form_id")
    Integer formId;
    
    @NotNull
    @Column(name = "demographic_no")
    Integer demographicNo;

    @NotNull
    @Column(name = "provider_no")
    String providerNo;

    @Column(name = "page_no")
    Integer pageNo;

    @NotNull
    @Column(name = "field")
    String field;
    
    @Column(name = "val")
    String value = "";
    
    @Column(name = "create_date")
    Date formCreated;

    @Column(name = "active")
    Boolean active = true;

    public FormONPerinatal2017() {
    }
    
    public FormONPerinatal2017(FormONPerinatal2017Comment comment) {
        this.id = comment.getId();
        this.formId = comment.getFormId();
        this.field = comment.getField();
        this.value = comment.getValue();
    }
    
    
    public FormONPerinatal2017(String field, String value) {
        this.field = field;
        this.value = value;
    }
    
    public FormONPerinatal2017(Integer formId, String field, String value) {
        this.formId = formId;
        this.field = field;
        this.value = value;
    }

    public FormONPerinatal2017(Integer formId, Integer demographicNo, String providerNo, Integer pageNo, String field, String value) { 
        this.formId = formId;
        this.demographicNo = demographicNo;
        this.providerNo = providerNo;
        this.pageNo = pageNo;
        this.field = field;
        this.value = value;
    }

    @Override
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getFormId() {
        return formId;
    }

    public void setFormId(Integer formId) {
        this.formId = formId;
    }

    public Integer getDemographicNo() {
        return demographicNo;
    }

    public void setDemographicNo(Integer demographicNo) {
        this.demographicNo = demographicNo;
    }

    public String getProviderNo() {
        return providerNo;
    }

    public void setProviderNo(String providerNo) {
        this.providerNo = providerNo;
    }

    public Integer getPageNo() {
        return pageNo;
    }

    public void setPageNo(Integer pageNo) {
        this.pageNo = pageNo;
    }

    public String getField() {
        return field;
    }

    public void setField(String field) {
        this.field = field;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Date getFormCreated() {
        return formCreated;
    }

    public void setFormCreated(Date formCreated) {
        this.formCreated = formCreated;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
    
    @PrePersist
    public void prePersist() {
        if (formCreated == null){
            setFormCreated(new Date());
        }
    }
    
}
