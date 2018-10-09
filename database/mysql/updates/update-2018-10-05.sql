alter table allergies add nonDrug tinyint(1);
update allergies set nonDrug=0;

