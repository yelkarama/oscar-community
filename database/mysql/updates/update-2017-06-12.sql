create table `rxmanage`
(
	id int not null auto_increment
		primary key,
	provider_no varchar(6) not null,
	mrpOnRx tinyint(1) default '0' not null
);