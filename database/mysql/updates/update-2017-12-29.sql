CALL addColumn('flowsheet_drug', 'name', 'VARCHAR(50) AFTER atc_code');

CALL addColumn('flowsheet_drug', 'last_update_user', 'VARCHAR(6)');
CALL addColumn('flowsheet_drug', 'last_update_date', 'DATETIME');

UPDATE flowsheet_drug SET last_update_user = provider_no, last_update_date = create_date;

CREATE TABLE IF NOT EXISTS userAcceptance
(
  id           INT AUTO_INCREMENT
    PRIMARY KEY,
  accepted     TINYINT(1) DEFAULT '0' NOT NULL,
  providerNo   VARCHAR(10)            NULL,
  timeAccepted DATETIME               NULL
);