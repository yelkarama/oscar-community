
INSERT INTO LookupList VALUES (\N,'apptCancellationReasons', 'Appointment Cancellation Reason List', 'Select list of appointment cancellation reasons',NULL,1, 'oscar',now());
SET @lid = LAST_INSERT_ID();
INSERT INTO LookupListItem values (\N,@lid,'PA','Physician Absent', 1, 1, 'oscar', now());
INSERT INTO LookupListItem values (\N,@lid,'CC', 'Clinic Closure', 2, 1, 'oscar', now());
INSERT INTO LookupListItem values (\N,@lid,'WD', 'Weather Disturbance', 3, 1, 'oscar', now());
INSERT INTO LookupListItem values (\N,@lid,'RA', 'Rescheduled Appointment', 4, 1, 'oscar', now());
INSERT INTO LookupListItem values (\N,@lid,'PR', 'Patient Requested', 5, 1, 'oscar', now());
