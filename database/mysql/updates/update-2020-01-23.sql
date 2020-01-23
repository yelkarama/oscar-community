ALTER TABLE ProviderPreference ADD COLUMN showAppointmentReason TINYINT(1) NULL DEFAULT NULL;
ALTER TABLE ProviderPreference ADD COLUMN ticklerDefaultAssignedProvider TINYINT(1) NULL DEFAULT NULL;
ALTER TABLE demographicQueryFavourites ADD COLUMN asOfDate VARCHAR(10) AFTER endYear;
ALTER TABLE billing_on_transaction MODIFY COLUMN service_code_num CHAR(10);
ALTER TABLE measurements MODIFY comments TEXT;

CREATE TABLE incomingLabRulesType (
    id int(10) NOT NULL AUTO_INCREMENT,
    forward_rule_id int(10),
    type VARCHAR(10) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT FOREIGN KEY (forward_rule_id) REFERENCES incomingLabRules (id) ON DELETE CASCADE ON UPDATE CASCADE
);

DELIMITER $$
DROP PROCEDURE IF EXISTS insertForwardTypes$$
CREATE PROCEDURE insertForwardTypes()
BEGIN
    DECLARE i INT;
    SET i = 1;
    WHILE i <= (SELECT MAX(id) FROM incomingLabRules) DO
            IF (SELECT id FROM incomingLabRules WHERE id = i) THEN
                INSERT INTO incomingLabRulesType (forward_rule_id, type) VALUES  (i, 'HL7'), (i, 'DOC'), (i, 'HRM');
            END IF;
            SET i = i + 1;
        END WHILE;
END$$
DELIMITER ;
CALL insertForwardTypes();
DROP PROCEDURE IF EXISTS insertForwardTypes;

ALTER TABLE site CHANGE short_name full_name VARCHAR(255) NOT NULL default '';





DROP PROCEDURE IF EXISTS addColumn;
DELIMITER //

CREATE PROCEDURE addColumn(IN tableName VARCHAR(100), IN columnName VARCHAR(100), IN definition VARCHAR(255))
BEGIN
    IF NOT EXISTS( (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME= tableName AND COLUMN_NAME= columnName) ) THEN
        SET @s = CONCAT('ALTER TABLE ', tableName, ' ADD COLUMN ', columnName, ' ', definition);
        PREPARE stmt FROM @s;
        EXECUTE stmt;
    END IF;
END //

DELIMITER ;


CALL addColumn('EyeformMacro', 'includeAdmissionDate', 'Boolean DEFAULT TRUE');

ALTER TABLE DemographicContact ADD best_contact VARCHAR(10) DEFAULT '';

CALL addColumn('flowsheet_customization', 'universal', 'BOOLEAN NOT NULL DEFAULT TRUE');

ALTER TABLE formType2Diabetes MODIFY meds1 tinytext;
ALTER TABLE formType2Diabetes MODIFY meds2 tinytext;
ALTER TABLE formType2Diabetes MODIFY meds3 tinytext;
ALTER TABLE formType2Diabetes MODIFY meds4 tinytext;
ALTER TABLE formType2Diabetes MODIFY meds5 tinytext;


ALTER TABLE clinic ADD COLUMN clinic_email VARCHAR(255) DEFAULT '';
ALTER TABLE clinic ADD COLUMN clinic_website VARCHAR(255) DEFAULT '';

ALTER TABLE consultationRequests ADD COLUMN letterhead_website VARCHAR(255) DEFAULT '';
ALTER TABLE consultationRequests ADD COLUMN letterhead_email VARCHAR(255) DEFAULT '';

ALTER TABLE drugs MODIFY COLUMN customName VARCHAR(255);

INSERT INTO ctl_doc_class (reportclass, subclass) VALUES ('Lab Report', '');

CREATE TABLE IF NOT EXISTS appointment_reminders
(
    id            INT AUTO_INCREMENT
        PRIMARY KEY,
    appointment_id INT                    NULL,
    reminder_email VARCHAR(50)            NULL,
    reminder_phone VARCHAR(20)            NULL,
    reminder_cell  VARCHAR(20)            NULL,
    confirmed     TINYINT(1) DEFAULT '0' NOT NULL,
    cancelled     TINYINT(1) DEFAULT '0' NOT NULL,
    unique_cancellation_key VARCHAR(40)    NULL,
    create_date DATETIME,
    last_update_date DATETIME,
    last_update_user VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS appointment_reminder_status
(
    id             INT AUTO_INCREMENT
        PRIMARY KEY,
    appt_reminder_id INT                    NOT NULL,
    provider_no     VARCHAR(10)            NULL,
    all_delivered   TINYINT(1) DEFAULT '0' NULL,
    reminders_sent  INT DEFAULT '0'        NULL,
    delivery_time   DATETIME               NULL
);


CREATE TABLE IF NOT EXISTS custom_healthcard_type (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(20) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_by varchar(9) NOT NULL,
  update_date datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id)
);

ALTER TABLE measurementType ADD parent_type varchar(50) DEFAULT NULL;

CALL addColumn('document', 'sent_date_time', 'DATETIME AFTER contentdatetime');

CALL addColumn('drugs', 'prescription_identifier', 'varchar(50)');
CALL addColumn('drugs', 'prior_rx_ref_id', 'varchar(20)');
CALL addColumn('drugs', 'protocol_id', 'varchar(20)');

ALTER TABLE drugs MODIFY route varchar(120) DEFAULT 'PO';


CREATE TABLE IF NOT EXISTS prescription_fax
(
    id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
    rx_id varchar(50) NOT NULL,
    pharmacy_id int(10) NOT NULL,
    provider_no varchar(6) NOT NULL,
    prescribe_it_fax boolean default false not null,
    date_faxed datetime NOT NULL
);

create table if not exists billing_service_schedule (
    id int(10) auto_increment primary key,
    service_code varchar(10) not null,
    billing_time time default '00:00:00',
    provider_no  varchar(6),
    deleted BOOLEAN default false
);

CALL addColumn('allergies', 'reaction_type', 'VARCHAR(2) NULL');
CALL addColumn('formGrowth0_36', 'chart_type', 'VARCHAR(3) DEFAULT "WHO"');

CREATE TABLE IF NOT EXISTS casemgmt_dx_link (
    note_id INT(10) NOT NULL,
    dx_type VARCHAR(10) NOT NULL,
    dx_code VARCHAR(10) NOT NULL,
    update_date DATETIME NOT NULL,
    PRIMARY KEY(note_id, dx_type, dx_code),
    FOREIGN KEY(note_id) REFERENCES casemgmt_note(note_id)
);

CALL addColumn('document', 'report_media', 'VARCHAR(20) AFTER sent_date_time');
CALL addColumn('HRMDocument', 'report_media', 'VARCHAR(20)');
CALL addColumn('HRMDocument', 'source_author', 'VARCHAR(120) AFTER reportLessDemographicInfoHash');
CALL addColumn('drugs', 'natural_product_number', 'VARCHAR(20) DEFAULT NULL AFTER regional_identifier');

CALL addColumn('billing_on_payment', 'active', 'boolean DEFAULT true');
UPDATE billing_on_payment SET billing_on_payment.active = false
where total_payment = 0.00 and total_discount = 0.00 and total_refund = 0.00 and total_credit = 0.00;

CALL addColumn('prescription', 'delivery_method', 'varchar(5)');

INSERT INTO demographicExt (demographic_no,provider_no,key_val,value,date_time,hidden)
SELECT
    d.demographic_no,'999998','enrollmentProvider',d.provider_no,NOW(),0
FROM
    demographic d
        LEFT JOIN
    demographicExt de ON d.demographic_no = de.demographic_no
        AND de.key_val = 'enrollmentProvider'
WHERE
        d.roster_status != '' and d.roster_status is not null and d.provider_no != '' AND d.provider_no IS NOT NULL
  AND de.key_val IS NULL;

CALL addColumn('allergies', 'atc', 'VARCHAR(10) AFTER regional_identifier');

UPDATE allergies a INNER JOIN drugref.cd_drug_search ds ON ds.name LIKE CONCAT(a.DESCRIPTION, '%') INNER JOIN drugref.cd_therapeutic_class tc ON tc.drug_code = ds.drug_code SET a.atc=tc.tc_atc_number WHERE a.drugref_id <> '0' AND SUBSTRING(ds.drug_code, 1, 1) IN ('0','1','2','3','4','5','6','7','8','9') AND ds.drug_code NOT LIKE '%:%' AND a.atc IS NULL;
UPDATE allergies a INNER JOIN drugref.cd_drug_search ds ON ds.name LIKE CONCAT(a.DESCRIPTION, '%') SET a.atc=ds.drug_code WHERE a.drugref_id<>'0' AND SUBSTRING(ds.drug_code, 1, 1) NOT IN ('0','1','2','3','4','5','6','7','8','9') AND a.atc IS NULL;
UPDATE allergies a INNER JOIN drugref.cd_drug_search ds ON ds.name LIKE CONCAT(a.DESCRIPTION, '%') INNER JOIN drugref.cd_therapeutic_class tc ON ds.drug_code = tc.tc_ahfs_number SET a.atc=tc.tc_atc_number WHERE a.drugref_id <> '0' AND ds.drug_code LIKE '%:%' AND a.atc IS NULL;

INSERT INTO secRole (role_name, description) VALUE ('Ophthalmologist', 'Opthalmologist');

CREATE TABLE IF NOT EXISTS referral_source
(
    id               int auto_increment
        primary key,
    referral_source  varchar(200) null,
    last_update_user int          null,
    last_update_date datetime     null,
    archived         tinyint(1)   null
);

ALTER TABLE appointment MODIFY status CHAR(2) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL DEFAULT 't';

CREATE TABLE IF NOT EXISTS ctl_document_metadata (
    id INT PRIMARY KEY AUTO_INCREMENT,
    document_no INT,
    appointment_no INT,
    status VARCHAR(1)
);

INSERT INTO SystemPreferences (name, value, updateDate) VALUE ('kai_username', 'Support', NOW());

INSERT IGNORE INTO secObjPrivilege (roleUserGroup, objectName, privilege, priority, provider_no) VALUES ('admin', '_createTaskList', 'x', 0, '999998');

INSERT INTO encounterForm VALUE ('Perinatal', '../form/formONPerinatalRecord1.jsp?demographic_no=', 'form_on_perinatal_2017', FALSE);

CALL addColumn('hl7TextInfo', 'last_updated_in_olis', 'varchar(255)');

ALTER TABLE measurementMap CHANGE lab_type lab_type VARCHAR(15);

CREATE TABLE patient_intake_letter_field (
                                             name VARCHAR(50) PRIMARY KEY,
                                             false_text VARCHAR(255),
                                             true_text VARCHAR(255)
);

INSERT INTO secRole (role_name, description) VALUE ('Patient Intake', 'Patient Intake');

INSERT INTO secObjPrivilege (roleUserGroup, objectName, privilege, priority, provider_no) VALUE
    ('Patient Intake', '_demographic', 'r', 0, '999998'),
    ('Patient Intake', '_eform', 'w', 0, '999998');

create table if not exists billing_rule
(
    id int auto_increment primary key,
    service_code varchar(5) unique not null,
    bill_region varchar(2) default '',
    enabled boolean default true
);

insert into billing_rule (service_code, bill_region, enabled) values ('K267A', 'ON', false),('K269A', 'ON', false);