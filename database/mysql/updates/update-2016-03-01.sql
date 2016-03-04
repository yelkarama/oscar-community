/* ALTERS */
ALTER TABLE document ADD COLUMN abnormal boolean DEFAULT false;

/* INSERTS */
INSERT INTO secObjectName (objectName, description, orgapplicable) VALUES ('_unlink_demographic_from_document', 'Document - Unlink Demographic', 0);
INSERT INTO secObjPrivilege (roleUserGroup, objectName, privilege, priority, provider_no) VALUES ('doctor', '_unlink_demographic_from_document', 'x', 0, '999998');