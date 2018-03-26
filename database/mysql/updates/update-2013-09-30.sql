ALTER TABLE OcanStaffForm ADD COLUMN referralDate date;
ALTER TABLE OcanStaffForm ADD COLUMN admissionDate date;
ALTER TABLE OcanStaffForm ADD COLUMN serviceInitDate date;
ALTER TABLE OcanStaffForm ADD COLUMN dischargeDate date;
create index submitDateIndex on OcanSubmissionLog (submitDateTime);
create index submissionTypeIndex on OcanSubmissionLog (submissionType);
