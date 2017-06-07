CREATE TABLE messageFolder
(
  folderID int(10) PRIMARY KEY  NOT NULL auto_increment,
  name varchar(25) NOT NULL default '',
  providerNo varchar(6) default null,
  displayOrder int(10),
  deleted boolean NOT NULL DEFAULT false
);

ALTER TABLE messagelisttbl ADD folderid INT(10) DEFAULT 0 NULL;