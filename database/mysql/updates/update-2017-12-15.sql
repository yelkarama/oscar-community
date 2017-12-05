CREATE INDEX `idx_hl7TextMessage_created`  ON `kai15`.`hl7TextMessage` (created);

CREATE TABLE IF NOT EXISTS systempreferences
(
  id         INT AUTO_INCREMENT
    PRIMARY KEY,
  name       VARCHAR(40) NULL,
  value      VARCHAR(40) NULL,
  updateDate DATETIME    NULL
);