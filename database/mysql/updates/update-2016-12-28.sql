CREATE TABLE IF NOT EXISTS `daysheet_configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field` varchar(55),
  `heading` varchar(255),
  `active` char(1) default '1',
  `pos` int(11),
  PRIMARY KEY (`id`)
);

DELETE FROM `daysheet_configuration`;

INSERT INTO `daysheet_configuration` VALUES ('1', 'Note', 'Note', '1', 1), ('2', 'Dx', 'Dx', '1', 2),
  ('3', 'Patient', 'Patient', '1', 3), ('4', 'Appointment Type', 'Appointment Type', '1', 4),
  ('5', 'Appointment Duration', 'Duration', '1', 5), ('6', 'Appointment Start Time', 'Time', '1', 6),
  ('7', 'Appointment Reason', 'Reason', '1', 7), ('8', 'Home Phone', 'Home Phone', '1', 8),
  ('9', 'Demographic Number', 'Demo #', '1', 9), ('10', 'Date of Birth', 'Date of Birth', '1', 10),
  ('11', 'Health Card Number', 'HIN', '1', 11);
