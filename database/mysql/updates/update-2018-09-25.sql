alter table allergies add intolerance tinyint(1);
update allergies set intolerance='';
