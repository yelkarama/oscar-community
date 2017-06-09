ALTER TABLE PreventionsLotNrs ADD COLUMN expiryDate date null;

ALTER TABLE ProviderPreference ADD COLUMN defaultBillingLocation VARCHAR(4) DEFAULT 'no';