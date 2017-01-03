CREATE TABLE IF NOT EXISTS `daysheet_configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field` varchar(55),
  `heading` varchar(255),
  `active` bit(1),
  `order` int(11),
  PRIMARY KEY (`id`)
);

DELETE FROM `daysheet_configuration`;

INSERT INTO `daysheet_configuration` VALUES ('1', 'Note', 'Note', b'1', 1), ('2', 'Dx', 'Dx', b'1', 2),
  ('3', 'Patient', 'Patient', b'1', 3), ('4', 'Appointment Type', 'Appointment Type', b'1', 4),
  ('5', 'Appointment Duration', 'Duration', b'1', 5), ('6', 'Appointment Start Time', 'Time', b'1', 6),
  ('7', 'Appointment Reason', 'Reason', b'1', 7), ('8', 'Home Phone', 'Home Phone', b'1', 8),
  ('9', 'Demographic Number', 'Demo #', b'1', 9), ('10', 'Date of Birth', 'Date of Birth', b'1', 10),
  ('11', 'Health Card Number', 'HIN', b'1', 11);
