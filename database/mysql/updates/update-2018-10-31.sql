INSERT INTO `validations` (`name`, `regularExp`, `maxValue1`, `minValue`, `maxLength`, `minLength`, `isNumeric`, `isTrue`, `isDate`) VALUES ('Integer: 0 to 7', NULL, 7, 0, 1, NULL, NULL, NULL, NULL);

INSERT INTO measurementType (type, typeDisplayName, typeDescription, measuringInstruction, createDate, validation) values
( 'CODPW', 'Cough (days/week)', 'Cough (days/week)', '', '2018-10-31 00:00:00',
(select id from validations where name='Integer: 0 to 7' limit 1)),
( 'CTDPW', 'Chest tightness (days/week)', 'Chest tightness (days/week)', '', '2018-10-31 00:00:00',
(select id from validations where name='Integer: 0 to 7' limit 1)),
( 'DYDPW', 'Dyspnea (days/week)', 'Dyspnea (days/week)', '', '2018-10-31 00:00:00',
(select id from validations where name='Integer: 0 to 7' limit 1)),
( 'WHDPW', 'Wheeze (days/week)', 'Wheeze (days/week)', '', '2018-10-31 00:00:00',
(select id from validations where name='Integer: 0 to 7' limit 1));

