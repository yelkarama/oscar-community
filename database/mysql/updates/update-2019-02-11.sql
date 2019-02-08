CALL addColumn('eform_data', 'appointment_no', 'INT');
CREATE TABLE IF NOT EXISTS ctl_document_metadata (
  id INT PRIMARY KEY AUTO_INCREMENT,
  document_no INT,
  appointment_no INT,
  status VARCHAR(1)
);