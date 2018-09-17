INSERT INTO `secObjPrivilege` VALUES('doctor', '_rx.editPharmacy', 'x', 0, '999998');

CREATE INDEX idx_billing_on_filename_htmlfilename_timestamp ON billing_on_filename (htmlfilename, timestamp);
CREATE INDEX idx_billing_on_diskname_ohipfilename_createdatetime  ON billing_on_diskname (ohipfilename, createdatetime);