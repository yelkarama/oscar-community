package org.oscarehr.common.dao;

import org.oscarehr.common.model.PatientIntakeLetterField;
import org.springframework.stereotype.Repository;

@Repository
public class PatientIntakeLetterFieldDao extends AbstractDao<PatientIntakeLetterField> {
    public PatientIntakeLetterFieldDao() {
        super(PatientIntakeLetterField.class);
    }
}
