CREATE TABLE `UAO` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `started` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `providerNo` varchar(25) DEFAULT NULL,
  `friendlyName` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `demographicNo` int(10) DEFAULT NULL,
  `resultCode` int(10) DEFAULT NULL,
  `defaultUAO` tinyint(1) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `addedBy` varchar(25) DEFAULT NULL,
  `dateCreated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateUpdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
  );
  
  alter table CVCImmunization add column shelfStatus varchar(255);
  
  