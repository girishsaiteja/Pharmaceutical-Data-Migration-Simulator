
UPDATE clean_data
SET
    MigrationStatus = 'ERROR',
    ValidationRemarks = 'Missing Telephone values'
WHERE TELEPHONE = 'UNKNOWN';



UPDATE clean_data
SET
    MigrationStatus = 'ERROR',
    ValidationRemarks = 'Missing NPI values'
WHERE NPI IS NULL;

SELECT * FROM clean_data
WHERE NPI IS NULL