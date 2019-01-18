CREATE TABLE DocumentExtraReviewer (
  `id` int(11) NOT NULL auto_increment,
  `documentNo` integer,
  `reviewerProviderNo` varchar(40),
  `reviewDateTime` timestamp,
  PRIMARY KEY  (`id`)
);


