CREATE TABLE `billing_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_no` varchar(16),
  `viewer_no` varchar(16),
  `permission` varchar(50),
  `allow` int(1),
  PRIMARY KEY (`id`)
);
