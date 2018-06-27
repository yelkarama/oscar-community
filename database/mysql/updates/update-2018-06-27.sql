CREATE TABLE prescription_fax
(
    id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
    rx_id varchar(50) NOT NULL,
    pharmacy_id int(10) NOT NULL,
    provider_no varchar(6) NOT NULL,
    prescribe_it_fax boolean default false not null,
    date_faxed datetime NOT NULL
);