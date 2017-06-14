create table if not exists freshbooksAppointmentInfo
(
  id int auto_increment
    primary key,
  appointment_no int not null,
  appointment_provider varchar(30) not null,
  freshbooks_invoice_id varchar(10) not null,
  provider_freshbooks_id varchar(6) not null
);

create table if not exists freshbooksAuthorization
(
  id int auto_increment
    primary key,
  bearer_token varchar(80) null,
  refresh_token varchar(80) null,
  expiry_time int(6) null,
  client_id varchar(80) null,
  client_secret varchar(80) null
);

create table if not exists freshbooksInsuranceCompanies
(
  id int auto_increment
    primary key,
  company_id int not null,
  provider_no varchar(10) not null,
  freshbooks_id varchar(7) not null
);

ALTER TABLE billing_on_cheader1 ADD COLUMN freshbooksId varchar(10) null;

ALTER TABLE billing_on_payment ADD COLUMN freshbooksId varchar(10) null;