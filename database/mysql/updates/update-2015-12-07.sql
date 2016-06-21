-- ----------------------------
--  Table structure for `LookupList`
-- ----------------------------

CREATE TABLE `LookupList` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `listTitle` varchar(255),
  `name` varchar(50) NOT NULL,
  `description` varchar(255),
  `categoryId` int(11),
  `active` tinyint(1) NOT NULL,
  `createdBy` varchar(8) NOT NULL,
  `dateCreated` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

CREATE TABLE `LookupListItem` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lookupListId` int(11) NOT NULL,
  `value` varchar(50) NOT NULL,
  `label` varchar(255),
  `displayOrder` int(11) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `createdBy` varchar(8) NOT NULL,
  `dateCreated` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`,`value`)
);


INSERT INTO `LookupList` (`listTitle`,`name`, description, categoryId, active, createdBy, dateCreated) VALUES('Consultation Request Appointment Instructions List', 'consultApptInst', 'Select list for the consultation appointment instruction select list', NULL, '1', 'oscar', NOW() );
INSERT INTO `LookupListItem` (lookupListId, value, label, displayOrder, active, createdBy, dateCreated)( 
SELECT id, UUID(), 'Please reply to sending facility by fax or phone with appointment','1', '1','oscar', NOW() FROM `LookupList` WHERE `name` = "consultApptInst" );

ALTER TABLE consultationRequests ADD appointmentInstructions varchar (256) AFTER `urgency`;
