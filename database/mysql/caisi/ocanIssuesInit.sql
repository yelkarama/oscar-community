-- Create OCAN ISSUES, some agencies which may already have ocan issues do not need to insert again.

INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10010','ACCOMMODATION','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10020','FOOD','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10030','LOOKING AFTER THE HOME','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10040','SELF-CARE','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10050','DAYTIME ACTIVITIES','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10060','PHYSICAL HEALTH','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10070','PSYCHOTIC SYMPTOMS','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10080','INFORMATION ON CONDITION AND TREATMENT','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10090','PSYCHOLOGICAL DISTRESS','counsellor','2012-06-12 15:21:30',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10100','SAFETY TO SELF','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10110','SAFETY TO OTHERS','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10120','ALCOHOL','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10130','DRUGS','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10140','OTHER ADDICTIONS','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10150','COMPANY','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10160','INTIMATE RELATIONSHIPS','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10170','SEXUAL EXPRESSION','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10180','CHILD CARE','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10190','OTHER DEPENDENTS','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10200','BASIC EDUCATION','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10210','TELEPHONE','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10220','TRANSPORT','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10230','MONEY','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10240','BENEFITS','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);
INSERT INTO `issue` ( code, description, role, update_date, priority, type, sortOrderId ) VALUES ('OCAN10241','LEGAL','counsellor','2012-06-12 15:21:31',NULL,'userDefined',0);

-- Create OCAN issue groups

insert into IssueGroupIssues select (select id from IssueGroup where name='Physical Health'),issue.issue_id from issue where issue.code='OCAN10060'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='Personal ID'),issue.issue_id from issue where issue.code='OCAN10002'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='Legal'),issue.issue_id from issue where issue.code='OCAN10241'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='Education'),issue.issue_id from issue where issue.code='OCAN10200'; 

insert into IssueGroup (name) values ("CARE COORDINATION");
insert into IssueGroup (name) values ("ACCOMMODATION");
insert into IssueGroup (name) values ("FOOD");
insert into IssueGroup (name) values ("LOOKING AFTER THE HOME");
insert into IssueGroup (name) values ("SELF-CARE");
insert into IssueGroup (name) values ("DAYTIME ACTIVITIES");
insert into IssueGroup (name) values ("PSYCHOTIC SYMPTOMS");
insert into IssueGroup (name) values ("MENTAL HEALTH NON-PSYCHOTIC");
insert into IssueGroup (name) values ("INFORMATION ON CONDITION AND TREATMENT");
insert into IssueGroup (name) values ("PSYCHOLOGICAL DISTRESS");
insert into IssueGroup (name) values ("SAFETY TO SELF");
insert into IssueGroup (name) values ("SAFETY TO OTHERS");
insert into IssueGroup (name) values ("ALCOHOL");
insert into IssueGroup (name) values ("DRUGS");
insert into IssueGroup (name) values ("OTHER ADDICTIONS");
insert into IssueGroup (name) values ("COMPANY");
insert into IssueGroup (name) values ("INTIMATE RELATIONSHIPS");
insert into IssueGroup (name) values ("SEXUAL EXPRESSION");
insert into IssueGroup (name) values ("CHILD CARE");
insert into IssueGroup (name) values ("OTHER DEPENDENTS");
insert into IssueGroup (name) values ("TELEPHONE");
insert into IssueGroup (name) values ("TRANSPORT");
insert into IssueGroup (name) values ("MONEY");
insert into IssueGroup (name) values ("BENEFITS");

insert into IssueGroupIssues select (select id from IssueGroup where name='CARE COORDINATION'),issue.issue_id from issue where issue.code='OCAN10001'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='ACCOMMODATION'),issue.issue_id from issue where issue.code='OCAN10010'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='FOOD'),issue.issue_id from issue where issue.code='OCAN10020'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='LOOKING AFTER THE HOME'),issue.issue_id from issue where issue.code='OCAN10030'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='SELF-CARE'),issue.issue_id from issue where issue.code='OCAN10040'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='DAYTIME ACTIVITIES'),issue.issue_id from issue where issue.code='OCAN10050'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='PSYCHOTIC SYMPTOMS'),issue.issue_id from issue where issue.code='OCAN10070'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='MENTAL HEALTH NON-PSYCHOTIC'),issue.issue_id from issue where issue.code='OCAN10072'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='INFORMATION ON CONDITION AND TREATMENT'),issue.issue_id from issue where issue.code='OCAN10080'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='PSYCHOLOGICAL DISTRESS'),issue.issue_id from issue where issue.code='OCAN10090'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='SAFETY TO SELF'),issue.issue_id from issue where issue.code='OCAN10100'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='SAFETY TO OTHERS'),issue.issue_id from issue where issue.code='OCAN10110'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='ALCOHOL'),issue.issue_id from issue where issue.code='OCAN10120'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='DRUGS'),issue.issue_id from issue where issue.code='OCAN10130'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='OTHER ADDICTIONS'),issue.issue_id from issue where issue.code='OCAN10140'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='COMPANY'),issue.issue_id from issue where issue.code='OCAN10150'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='INTIMATE RELATIONSHIPS'),issue.issue_id from issue where issue.code='OCAN10160'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='SEXUAL EXPRESSION'),issue.issue_id from issue where issue.code='OCAN10170'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='CHILD CARE'),issue.issue_id from issue where issue.code='OCAN10180'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='OTHER DEPENDENTS'),issue.issue_id from issue where issue.code='OCAN10190'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='TELEPHONE'),issue.issue_id from issue where issue.code='OCAN10210'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='TRANSPORT'),issue.issue_id from issue where issue.code='OCAN10220'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='MONEY'),issue.issue_id from issue where issue.code='OCAN10230'; 
insert into IssueGroupIssues select (select id from IssueGroup where name='BENEFITS'),issue.issue_id from issue where issue.code='OCAN10240'; 


