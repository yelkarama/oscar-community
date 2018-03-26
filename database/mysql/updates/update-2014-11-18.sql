create table functionalCentreAdmission
(
        id int(11) NOT NULL auto_increment,
        demographicNo int(11) NOT NULL,
        functionalCentreId varchar(64) NOT NULL,
        referralDate date ,
        admissionDate date ,
        serviceInitiationDate date,
        dischargeDate date,
        discharged tinyint(1) NOT NULL,
        providerNo varchar(6) NOT NULL,
        updateDate datetime NOT NULL,
        PRIMARY KEY  (id)
);

