
ALTER TABLE casemgmt_dx_link ADD COLUMN co_morbid_dx_type VARCHAR(10) DEFAULT NULL AFTER dx_code;
ALTER TABLE casemgmt_dx_link ADD COLUMN co_morbid_dx_code VARCHAR(10) DEFAULT NULL AFTER co_morbid_dx_type;
