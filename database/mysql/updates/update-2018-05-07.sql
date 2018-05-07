CREATE TABLE IF NOT EXISTS online_booking_info
(
  id                INT AUTO_INCREMENT PRIMARY KEY,
  `key`             VARCHAR(50) NOT NULL,
  value             TEXT        NOT NULL,
  provider_no       VARCHAR(10) NULL,
  last_updated_user VARCHAR(10) NOT NULL
)