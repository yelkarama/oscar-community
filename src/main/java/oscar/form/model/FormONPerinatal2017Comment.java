package oscar.form.model;

import com.sun.istack.NotNull;
import org.oscarehr.common.model.AbstractModel;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "form_on_perinatal_2017_comment")
public class FormONPerinatal2017Comment extends AbstractModel<Integer> implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotNull
    @Column(name = "form_id")
    Integer formId;

    @NotNull
    @Column(name = "field")
    String field;

    @Column(name = "val")
    String value = "";

    public FormONPerinatal2017Comment() {
    }

    public FormONPerinatal2017Comment(FormONPerinatal2017 record) {
        this.id = record.getId();
        this.formId = record.getFormId();
        this.field = record.getField();
        this.value = record.getValue();
    }

    public FormONPerinatal2017Comment(Integer id, Integer formId, String field, String value) {
        this.formId = formId;
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
}
