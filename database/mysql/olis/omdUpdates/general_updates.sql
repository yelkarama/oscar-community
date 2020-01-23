CREATE TABLE IF NOT EXISTS olis_removed_lab_request (
    id INT AUTO_INCREMENT PRIMARY KEY,
    emr_transaction_id VARCHAR(50),
    removing_provider VARCHAR(6),
    removal_date DATETIME,
    removal_reason VARCHAR(255),
    removal_type VARCHAR(6),
    download_from VARCHAR(4),
    accession_number VARCHAR(30),
    test_request VARCHAR(100),
    collection_date DATETIME,
    last_updated DATETIME
);

CREATE TABLE IF NOT EXISTS olis_query_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_sent TIMESTAMP,
    query_code VARCHAR(3),
    type VARCHAR(50),
    initiating_provider_no VARCHAR(6),
    requesting_hic VARCHAR(10),
    external_system VARCHAR(10) DEFAULT 'OLIS',
    emr_transaction_id VARCHAR(100),
    olis_transaction_id VARCHAR(100),
    file_name VARCHAR(50) DEFAULT ''
);