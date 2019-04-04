INSERT INTO secRole (role_name, description) VALUE ('Patient Intake', 'Patient Intake');

INSERT INTO secObjPrivilege (roleUserGroup, objectName, privilege, priority, provider_no) VALUE
  ('Patient Intake', '_demographic', 'r', 0, '999998'),
  ('Patient Intake', '_eform', 'w', 0, '999998');

CREATE TABLE patient_intake_letter_field (
  name VARCHAR(50) PRIMARY KEY,
  false_text VARCHAR(255),
  true_text VARCHAR(255)
);