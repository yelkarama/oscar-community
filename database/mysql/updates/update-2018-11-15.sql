insert into `validations` (`name`, `regularExp`, `maxValue1`, `minValue`, `maxLength`, `minLength`, `isNumeric`, `isTrue`, `isDate`) values ('COPD Classification', 'Mild: FEV1 >= 80% predicted|Moderate:50% <= FEV1 < 80% predicted|Severe:30% <= FEV1 < 50% predicted|Very Severe : FEV1 < 30% predicted', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

update measurementType set measuringInstruction='COPD Classification', validation=
(select id from validations where name='COPD Classification' limit 1)
where type='COPDC';

update measurementType set type='ACOSY', typeDisplayName='Cough', typeDescription='Cough', measuringInstruction='frequency/week',
validation=(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)
where type='CODPW';

update measurementType set type='ACTSY', typeDisplayName='Chest tightness', typeDescription='Chest tightness',
measuringInstruction='frequency/week', 
validation=(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)
where type='CTDPW';

update measurementType set type='ADYSY', typeDisplayName='Dyspnea', typeDescription='Dyspnea',
measuringInstruction='frequency/week', 
validation=(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)
where type='DYDPW';

update measurementType set type='AWHSY', typeDisplayName='Wheeze', typeDescription='Wheeze', measuringInstruction='frequency/week', 
validation=(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)
where type='WHDPW';

