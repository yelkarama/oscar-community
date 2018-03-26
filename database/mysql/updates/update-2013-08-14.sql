ALTER TABLE Facility ADD COLUMN enableCbiForm tinyint(1) not null;
ALTER TABLE OcanStaffForm ADD COLUMN lastNameAtBirth varchar(100);
ALTER TABLE OcanStaffForm ADD COLUMN estimatedAge varchar(3);
ALTER TABLE OcanSubmissionLog ADD COLUMN submissionType varchar(30) not null;
