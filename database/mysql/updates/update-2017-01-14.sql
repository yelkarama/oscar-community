ALTER TABLE mygroup CHANGE vieworder vieworder int(11) default 0;
UPDATE mygroup SET vieworder=0 WHERE vieworder IS null;
