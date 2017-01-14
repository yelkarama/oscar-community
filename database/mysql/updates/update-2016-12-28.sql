CREATE TABLE IF NOT EXISTS `daysheet_configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field` varchar(55),
  `heading` varchar(255),
  `active` char(1) default '1',
  `pos` int(11),
  PRIMARY KEY (`id`)
);

DELETE FROM `daysheet_configuration`;

INSERT INTO `daysheet_configuration` VALUES ('1', 'Note', 'Note', '1', 12), ('2', 'Dx', 'Dx', '1', 11),
  ('3', 'Patient', 'Patient', '1', 4), ('4', 'Appointment Type', 'Appointment Type', '1', 7),
  ('5', 'Appointment Duration', 'Duration', '1', 2), ('6', 'Appointment Start Time', 'Time', '1', 1),
  ('7', 'Appointment Reason', 'Reason', '1', 8), ('8', 'Home Phone', 'Home Phone', '1', 9),
  ('9', 'Demographic Number', 'Demo #', '1', 3), ('10', 'Date of Birth', 'Date of Birth', '1', 5),
  ('11', 'Health Card Number', 'HIN', '1', 6), ('12', 'Visit Code', 'Visit Code', '1',10);

