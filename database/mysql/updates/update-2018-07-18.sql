
ALTER TABLE consultationRequests ADD COLUMN locked BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE consultation_requests_archive ADD COLUMN locked BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE document ADD COLUMN report_media varchar(20) NULL;
ALTER TABLE HRMDocument ADD COLUMN report_media varchar(20) NULL;
ALTER TABLE HRMDocument ADD COLUMN source_author varchar(120) NULL;

ALTER TABLE document MODIFY COLUMN report_media varchar(20) AFTER contentdatetime;
ALTER TABLE HRMDocument MODIFY COLUMN source_author varchar(120) AFTER reportLessDemographicInfoHash;