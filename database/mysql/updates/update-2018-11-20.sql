CREATE TABLE OLISQueryLog (
    id int(11) auto_increment,
    initiatingProviderNo varchar(30),
    queryType varchar(20),
    queryExecutionDate datetime,
    uuid varchar(255),
    requestingHIC varchar(30),
    demographicNo integer,
    PRIMARY KEY(id)
);

