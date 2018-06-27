ALTER TABLE measurementType ADD parent_type varchar(50) DEFAULT NULL;

INSERT INTO validations (name, regularExp) SELECT * FROM (SELECT 'Provided/Revised/Reviewed','PROVIDED|provided|Provided|REVISED|revised|Revised|REVIEWED|reviewed|Reviewed') AS tmp 
WHERE NOT EXISTS (SELECT id FROM validations WHERE name='Provided/Revised/Reviewed');

UPDATE measurementType SET typeDisplayName = 'Neurological Exam', typeDescription = 'Neurological Exam Loss of Sensation (Foot)' WHERE type = 'FTLS';
UPDATE measurementType SET measuringInstruction = 'Completed' WHERE type = 'DMME';
UPDATE measurementType SET typeDisplayName = 'Motivation Counselling Completed Nutrition', typeDescription = 'Motivation Counselling Completed Nutrition' WHERE type = 'MCCN';
UPDATE measurementType SET typeDisplayName = 'Motivation Counselling Completed Exercise', typeDescription = 'Motivation Counselling Completed Exercise' WHERE type = 'MCCE';
UPDATE measurementType SET typeDisplayName = 'Motivation Counselling Completed Smoking Cessation', typeDescription = 'Motivation Counselling Completed Smoking Cessation' WHERE type = 'MCCS';
UPDATE measurementType SET typeDisplayName = 'Motivation Counselling Completed Other', typeDescription = 'Motivation Counselling Completed Other' WHERE type = 'MCCO';
UPDATE measurementType SET typeDisplayName = 'Asthma Night Time Symptoms', typeDescription = 'Asthma Night Time Symptoms', parent_type = 'ASYM' WHERE type = 'ANSY';
UPDATE measurementType SET measuringInstruction = 'Provided/Revised/Reviewed', validation = (SELECT id FROM validations WHERE name='Provided/Revised/Reviewed') WHERE type = 'AACP';


INSERT INTO measurementType (type, typeDisplayName, typeDescription, measuringInstruction, validation, createDate, parent_type) VALUES
('ADYS', 'Asthma Dyspnea Symptoms', 'Asthma Dyspnea Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'ASYM'),
('ACHS', 'Asthma Cough Symptoms', 'Asthma Cough Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'ASYM'),
('AWHS', 'Asthma Wheeze Symptoms', 'Asthma Wheeze Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'ASYM'),
('ACTS', 'Asthma Chest Tightness Symptoms', 'Asthma Chest Tightness Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'ASYM'),
('HFFA', 'HF Fatigue Symptoms', 'HF Fatigue Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF'),
('HFDI', 'HF Dizziness Symptoms', 'HF Dizziness Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF'),
('HFSY', 'HF Syncope Symptoms', 'HF Syncope Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF'),
('HFDE', 'HF Dyspnea on Exertion Symptoms', 'HF Dyspnea on Exertion Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF'),
('HFDR', 'HF Dyspnea at Rest Symptoms', 'HF Dyspnea at Rest Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF'),
('HFOR', 'HF Orthopnea Symptoms', 'HF Orthopnea Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF'),
('HFPN', 'HF Paroxysmal Nocturnal Dyspnea Symptoms', 'HF Paroxysmal Nocturnal Dyspnea Symptoms', 'frequency per week', '14', '2018-06-11 00:00:00', 'SOHF');
