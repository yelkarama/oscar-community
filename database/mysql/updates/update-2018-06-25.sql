ALTER TABLE drugs ADD prescription_identifier varchar(50);
ALTER TABLE drugs ADD prior_rx_ref_id varchar(20);
ALTER TABLE drugs ADD protocol_id varchar(20);
UPDATE drugs SET prescription_identifier = script_no;
ALTER TABLE drugs MODIFY route varchar(120) DEFAULT 'PO';