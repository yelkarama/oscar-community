# Create required tables for patient types

CREATE TABLE demographic_group (
  id int(11) NOT NULL auto_increment,
  name varchar(100) NOT NULL,
  description varchar(255) NOT NULL,
 	PRIMARY KEY  (id)
) ENGINE = InnoDB;

CREATE TABLE demographic_group_link (
  demographic_no int(10) NOT NULL,
  demographic_group_id int(11) NOT NULL,
  PRIMARY KEY  (demographic_no, demographic_group_id)
) ENGINE = InnoDB;


drop table patientType;
CREATE TABLE patientType (
  `type` varchar(45),
  `description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`type`),
  UNIQUE INDEX `type_UNIQUE` (`type` ASC),
  UNIQUE INDEX `description_UNIQUE` (`description` ASC));

insert into patientType values ('HPN', 'HP NonStudent');
insert into patientType values ('HPS', 'HP Student');
insert into patientType values ('HPV', 'HP Varsity');
insert into patientType values ('NS', 'NonStudent');
insert into patientType values ('S', 'Student');
insert into patientType values ('V', 'Varsity');

ALTER TABLE demographic ADD COLUMN `patient_type` VARCHAR(45)  NULL AFTER `lastUpdateDate`;


# MAybe not needed?
ALTER TABLE demographic ADD COLUMN `patient_id` VARCHAR(45) NULL AFTER `patient_type`;
CREATE TABLE `patientId` (
  `patient_id` varchar(45) NOT NULL,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `patient_id_UNIQUE` (`patient_id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB;