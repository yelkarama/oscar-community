insert into `secObjectName` (`objectName`) values ('_dashboardManager');
insert into `secObjectName` (`objectName`) values ('_dashboardDisplay');
insert into `secObjectName` (`objectName`) values ('_dashboardDrilldown');

ALTER TABLE billing_on_premium ADD COLUMN premium_type varchar(255) after providerohip_no;
