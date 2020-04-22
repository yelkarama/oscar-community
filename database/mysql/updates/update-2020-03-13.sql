ALTER TABLE LookupList ADD CONSTRAINT unique_list UNIQUE IF NOT EXISTS (name, listTitle);
ALTER TABLE LookupListItem ADD CONSTRAINT unique_list_items UNIQUE IF NOT EXISTS (lookupListId, value, label);


INSERT INTO LookupList (name, listTitle, description, active, createdBy)
  VALUES ('apptCancellationReasons', 'Appointment Cancellation Reason List', 'Select list of appointment cancellation reasons',1, 'oscar') ON DUPLICATE KEY UPDATE name = name;


INSERT INTO LookupListItem (lookupListId, value, label, displayOrder, active, createdBy)
  SELECT LookupList.id, 'PA', 'Physician Absent', 1, 1, 'oscar'
  FROM LookupList WHERE LookupList.name = 'apptCancellationReasons'
  ON DUPLICATE KEY UPDATE lookupListId = lookupListId;

INSERT INTO LookupListItem (lookupListId, value, label, displayOrder, active, createdBy)
  SELECT LookupList.id, 'CC', 'Clinic Closure', 2, 1, 'oscar'
  FROM LookupList WHERE LookupList.name = 'apptCancellationReasons'
  ON DUPLICATE KEY UPDATE  lookupListId = lookupListId;

INSERT INTO LookupListItem (lookupListId, value, label, displayOrder, active, createdBy)
  SELECT LookupList.id, 'WD', 'Weather Disturbance', 3, 1, 'oscar'
  FROM LookupList WHERE LookupList.name = 'apptCancellationReasons'
  ON DUPLICATE KEY UPDATE  lookupListId = lookupListId;

INSERT INTO LookupListItem (lookupListId, value, label, displayOrder, active, createdBy)
  SELECT LookupList.id, 'RA', 'Rescheduled Appointment', 4, 1, 'oscar'
  FROM LookupList WHERE LookupList.name = 'apptCancellationReasons'
  ON DUPLICATE KEY UPDATE  lookupListId = lookupListId;

INSERT INTO LookupListItem (lookupListId, value, label, displayOrder, active, createdBy)
  SELECT LookupList.id, 'PR', 'Patient Requested', 5, 1, 'oscar'
  FROM LookupList WHERE LookupList.name = 'apptCancellationReasons'
  ON DUPLICATE KEY UPDATE  lookupListId = lookupListId;
