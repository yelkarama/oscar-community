update measurementType set measuringInstruction='Provided/Revised/Reviewed', validation=
(select id from validations where name='Provided/Revised/Reviewed' limit 1)
where type='AACP';

alter table validations modify regularExp varchar(250);
insert into `validations` (`name`, `regularExp`, `maxValue1`, `minValue`, `maxLength`, `minLength`, `isNumeric`, `isTrue`, `isDate`) values ('NYHA Class I-IV', 'Class I - no symptoms|Class II - symptoms with ordinary activity|Class III - symptoms with less than ordinary activity|Class IV - symptoms at rest', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

update measurementType set measuringInstruction='NYHA Class I-IV', validation=
(select id from validations where name='NYHA Class I-IV' limit 1)
where type='NYHA';

