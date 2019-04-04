package org.oscarehr.common.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "patient_intake_letter_field")
public class PatientIntakeLetterField extends AbstractModel<String> {
    @Id
    @Column(name = "name")
    private String name;
    @Column(name = "false_text")
    private String falseText;
    @Column(name = "true_text")
    private String trueText;

    public String getId() {
        return name;
    }
    
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public String getFalseText() {
        return falseText;
    }
    public void setFalseText(String falseText) {
        this.falseText = falseText;
    }

    public String getTrueText() {
        return trueText;
    }
    public void setTrueText(String trueText) {
        this.trueText = trueText;
    }
}