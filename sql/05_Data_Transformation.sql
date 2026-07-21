/*
Objective:
Prepare the cleaned dataset for migration into the target system by
standardizing data formats and adding migration audit metadata.
===========================================================================*/


/*===========================================================================
STEP 1 : Standardize Text Fields
-------------------------------------------------------------------------------
Purpose:
Standardize location-related fields by converting text to uppercase.
===========================================================================*/

UPDATE clean_data
SET
    CITY = UPPER(CITY),
    COUNTRY = UPPER(COUNTRY),
    STATE = UPPER(STATE);

/*===========================================================================
STEP 2 : Add Migration Status
-------------------------------------------------------------------------------
Purpose:
Add a column to track the migration status of each record.
===========================================================================*/

ALTER TABLE clean_data
ADD MigrationStatus VARCHAR(20);

UPDATE clean_data
SET MigrationStatus = 'PENDING';


/*===========================================================================
STEP 3 : Add Migration Date
-------------------------------------------------------------------------------
Purpose:
Add a timestamp indicating when each record was prepared for migration.
===========================================================================*/

ALTER TABLE clean_data
ADD MigrationDate DATETIME;

UPDATE clean_data
SET MigrationDate = GETDATE();


/*===========================================================================
STEP 4 : Add Record Source
-------------------------------------------------------------------------------
Purpose:
Add a column to identify the source system of each record.
===========================================================================*/

ALTER TABLE clean_data
ADD RecordSource VARCHAR(50);

UPDATE clean_data
SET RecordSource = 'Legacy System';


/*===========================================================================
END OF DATA TRANSFORMATION STAGE

Purpose:
Prepare the dataset for the data validation stage before migration.
===========================================================================*/