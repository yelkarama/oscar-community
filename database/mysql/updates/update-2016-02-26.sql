/* Alters and new tables for Kai OSCAR12 Pilot */
ALTER TABLE ProviderPreference ADD COLUMN twelveHourFormat boolean DEFAULT true AFTER everyMin;
ALTER TABLE ProviderPreference ADD COLUMN labelShortcutEnabled boolean DEFAULT false AFTER twelveHourFormat;
ALTER TABLE ProviderPreference ADD COLUMN defaultDoctor varchar(6) AFTER myGroupNo;