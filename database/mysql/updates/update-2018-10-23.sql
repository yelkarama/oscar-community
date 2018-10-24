INSERT INTO `validations` (`name`, `regularExp`, `maxValue1`, `minValue`, `maxLength`, `minLength`, `isNumeric`, `isTrue`, `isDate`) VALUES
('Provided/Revised/Reviewed', 'Provided|Revised|Reviewed', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('Mild/Moderate/Severe/Very Severe', 'Mild|Moderate|Severe|Very Severe', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('Yes/Not Applicable', 'Yes|Not Applicable', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('Yes', 'Yes', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO measurementType (type, typeDisplayName, typeDescription, measuringInstruction, createDate, validation) values
( 'ASWAN', 'Asthma # of School Work Absence', 'Asthma # of School Work Absence', 'Numeric Value greater than or equal to 0', '2018-10-01 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSFT', 'Heart Failure Symptom: Fatigue', 'Heart Failure Symptom: Fatigue', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSDZ', 'Heart Failure Symptom: Dizziness', 'Heart Failure Symptom: Dizziness', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSSC', 'Heart Failure Symptom: Syncope', 'Heart Failure Symptom: Syncope', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSDE', 'Heart Failure Symptom: Dyspnea on Exertion', 'Heart Failure Symptom: Dyspnea on Exertion', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSDR', 'Heart Failure Symptom: Dyspnea at Rest', 'Heart Failure Symptom: Dyspnea at Rest', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSON', 'Heart Failure Symptom: Orthopnea', 'Heart Failure Symptom: Orthopnea', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'HFSDP', 'Heart Failure Symptom: Paroxysmal Nocturnal Dyspnea', 'Heart Failure Symptom: Paroxysmal Nocturnal Dyspnea', 'Frequency/week', '2018-10-18 00:00:00',
(select id from validations where name='Numeric Value greater than or equal to 0' limit 1)),
( 'SPIRT', 'Spirometry Test', 'Spirometry Test', 'Yes or none', '2018-10-18 00:00:00',
(select id from validations where name='Yes' limit 1)),
( 'COPDC', 'COPD Classification', 'COPD Classification', 'Mild/Moderate/Severe/Very Severe', '2018-10-18 00:00:00',
(select id from validations where name='Mild/Moderate/Severe/Very Severe' limit 1)),
( 'RABG2', 'Recommend ABG', 'Recommend ABG', 'Yes/Not Applicable', '2018-10-18 00:00:00',
(select id from validations where name='Yes/Not Applicable' limit 1)),
( 'EPR2', 'Exacerbation plan in place', 'Exacerbation plan in place', 'Provided/Revised/Reviewed', '2018-10-18 00:00:00',
(select id from validations where name='Provided/Revised/Reviewed' limit 1));

