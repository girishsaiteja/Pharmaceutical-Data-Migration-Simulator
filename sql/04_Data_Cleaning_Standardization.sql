/*
Objective:
Clean and standardize raw pharmacy data before validation and migration.

Cleaning Activities Performed:
1. Create a working copy of the raw dataset
2. Standardize schema
3. Remove unwanted spaces
4. Validate business rules
5. Handle missing values
6. Standardize ZIP Codes
7. Standardize ZIP+4 Codes
8. Clean optional text fields
9. Standardize NULL values
10. Clean hidden whitespace/control characters
11. Dynamically clean Provider and Health columns

Note:
The original raw_data table is never modified.
All transformations are performed on clean_data.
===========================================================================*/


/*===========================================================================
STEP 1 : Create Working Copy
Purpose:
- Preserve the original source data.
- Perform all cleaning operations on a separate table.
===========================================================================*/

SELECT *
INTO clean_data
FROM raw_data;


/*===========================================================================
STEP 2 : Rename Incorrect Column
Purpose:
- Improve schema consistency.
===========================================================================*/

EXEC sp_rename 'clean_data.COUNTY', 'COUNTRY', 'COLUMN';


/*===========================================================================
STEP 3 : Remove Leading and Trailing Spaces
Purpose:
- Remove unwanted spaces from pharmacy names.
- Prevent duplicate values caused by inconsistent spacing.
===========================================================================*/

UPDATE clean_data
SET NAME = LTRIM(RTRIM(NAME));


/*===========================================================================
STEP 4 : Business Rule Analysis
Purpose:
- Understand the relationship between Contact Method and Geocoding.
- This is an analysis step only.
===========================================================================*/

SELECT
    CONTHOW,
    GEOHOW,
    COUNT(*) AS Total
FROM raw_data
GROUP BY CONTHOW, GEOHOW
ORDER BY COUNT(*) DESC;


/*
===========================================================================
Business Rule Observation

1565 Records

CONTDATE = NULL
CONTHOW  = NULL
GEOHOW   = AUTO

Interpretation:
Records were automatically geocoded.
No manual contact was performed.

Decision:
No update required.
===========================================================================
*/


/*===========================================================================
STEP 5 : Handle Missing Telephone Numbers
Purpose:
Replace missing telephone numbers with 'UNKNOWN'.
===========================================================================*/

UPDATE clean_data
SET TELEPHONE = 'UNKNOWN'
WHERE TELEPHONE IS NULL
   OR TELEPHONE = '';


/*===========================================================================
STEP 6 : Standardize Optional Address Field
Purpose:
Convert blank Address2 values into NULL.
===========================================================================*/

UPDATE clean_data
SET ADDRESS2 = NULL
WHERE ADDRESS2 = '';


/*===========================================================================
STEP 7 : Standardize ZIP Codes
Purpose:
Restore missing leading zeros.
===========================================================================*/

UPDATE clean_data
SET ZIP = RIGHT('00000' + ZIP,5)
WHERE LEN(ZIP)=4;

UPDATE clean_data
SET ZIP = RIGHT('00000' + ZIP,5)
WHERE LEN(ZIP)=3;


/*===========================================================================
STEP 8 : Standardize ZIP+4
Purpose:
Ensure ZIP+4 always contains four digits.
===========================================================================*/

UPDATE clean_data
SET ZIPP4 = RIGHT('0000'+ZIPP4,4)
WHERE LEN(ZIPP4)<4;


/*===========================================================================
STEP 9 : Remove Invalid ZIP+4 Values
Purpose:
Replace placeholder ZIP+4 values with NULL.
===========================================================================*/

UPDATE clean_data
SET ZIPP4=NULL
WHERE LTRIM(RTRIM(ZIPP4))='000';


/*===========================================================================
STEP 10 : Clean Directions Field
Purpose:
Convert blank directions into NULL.
===========================================================================*/

UPDATE clean_data
SET DIRECTIONS=NULL
WHERE NULLIF(LTRIM(RTRIM(DIRECTIONS)),'') IS NULL;


/*===========================================================================
STEP 11 : Clean Emergency Contact Information
Purpose:
Standardize blank emergency information.
===========================================================================*/

UPDATE clean_data
SET
EMERGTITLE=NULL,
EMERGTEL=NULL,
EMERGEXT=NULL
WHERE
LTRIM(RTRIM(ISNULL(EMERGTITLE,'')))=''
OR LTRIM(RTRIM(ISNULL(EMERGTEL,'')))=''
OR LTRIM(RTRIM(ISNULL(EMERGEXT,'')))='';


/*===========================================================================
STEP 12 : Clean Contact Method
===========================================================================*/

UPDATE clean_data
SET CONTHOW=NULL
WHERE NULLIF(LTRIM(RTRIM(CONTHOW)),'') IS NULL;


/*===========================================================================
STEP 13 : Clean Phone Location
===========================================================================*/

UPDATE clean_data
SET PHONELOC=NULL
WHERE NULLIF(LTRIM(RTRIM(PHONELOC)),'') IS NULL;


/*===========================================================================
STEP 14 : Clean Geographic Link ID
===========================================================================*/

UPDATE clean_data
SET GEOLINKID=NULL
WHERE NULLIF(LTRIM(RTRIM(GEOLINKID)),'') IS NULL;


/*===========================================================================
STEP 15 : Clean QC_QA Field
===========================================================================*/

UPDATE clean_data
SET QC_QA=NULL
WHERE NULLIF(LTRIM(RTRIM(QC_QA)),'') IS NULL;


/*===========================================================================
STEP 16 : Clean Website Information
===========================================================================*/

UPDATE clean_data
SET WEBSITE=NULL
WHERE NULLIF(LTRIM(RTRIM(WEBSITE)),'') IS NULL;


/*===========================================================================
STEP 17 : Handle Incomplete Provider Records
Purpose:
Standardize records where all provider identifiers are missing.
===========================================================================*/

UPDATE clean_data
SET
NPI=NULL,
ENT_TYPE=NULL,
ORGAN_NAME=NULL
WHERE
NULLIF(LTRIM(RTRIM(NPI)),'') IS NULL
AND NULLIF(LTRIM(RTRIM(ENT_TYPE)),'') IS NULL
AND NULLIF(LTRIM(RTRIM(ORGAN_NAME)),'') IS NULL;

/*===========================================================================
STEP 18 : Data Quality Assessment - Missing Value Analysis

Purpose:
- Automatically identify all PROVID_*, HEALTH_* and LASTUP_* columns.
- Count NULL and blank values in each column.
- Generate a data quality report without manually writing
  individual SUM(CASE...) statements.

Benefits:
✓ Automatically adapts to schema changes.
✓ Eliminates repetitive code.
✓ Easy to maintain.
✓ Commonly used in enterprise ETL/Data Migration projects.
===========================================================================*/

DECLARE @SQL NVARCHAR(MAX) = N'SELECT ';

SELECT @SQL +=
'
SUM(
    CASE
        WHEN NULLIF(LTRIM(RTRIM(CAST(' + QUOTENAME(COLUMN_NAME) + ' AS VARCHAR(MAX)))), '''') IS NULL
        THEN 1
        ELSE 0
    END
) AS ' + QUOTENAME(COLUMN_NAME + '_EmptyOrNull') + ','

FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_data'
AND
(
       COLUMN_NAME LIKE 'PROVID[_]%'
    OR COLUMN_NAME LIKE 'HEALTH[_]%'
    OR COLUMN_NAME LIKE 'LASTUP[_]%'
);

-- Remove the trailing comma
SET @SQL = LEFT(@SQL, LEN(@SQL)-1);

-- Append table name
SET @SQL += ' FROM raw_data;';

-- Review the generated query (optional)
PRINT @SQL;

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;


/*===========================================================================
STEP 19 : Data Quality Assessment
Purpose:
Measure missing values including hidden whitespace characters.
===========================================================================*/
SELECT  PROVID_105,COUNT(*) from raw_data
WHERE LEN(PROVID_105) = 2
GROUP BY PROVID_105;


SELECT TOP 20
    '[' + PROVID_105 + ']' AS Value,
    LEN(PROVID_105) AS LenValue,
    DATALENGTH(PROVID_105) AS DataLength
FROM raw_data;


/*===========================================================================
STEP 20 : Clean Hidden Whitespace Characters
Purpose:
Convert values containing only spaces, tabs,
carriage returns and line feeds into NULL.
===========================================================================*/

UPDATE clean_data
SET PROVID_105=NULL
WHERE LEN(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
CAST(PROVID_105 AS VARCHAR(MAX)),
CHAR(13),''),
CHAR(10),''),
CHAR(9),''),
' ','')
)=0;


/*===========================================================================
STEP 21 : Dynamic Cleaning of Provider & Health Columns
Purpose:
Automatically identify all PROVID_*,
HEALTH_* and LASTUP_* columns.

Cleaning Performed:
- Remove Spaces
- Remove Tabs
- Remove Carriage Returns
- Remove Line Feeds
- Convert Blank Values into NULL

This approach eliminates repetitive UPDATE statements and
is commonly used in enterprise ETL/Data Migration projects.
===========================================================================*/

DECLARE @SQL NVARCHAR(MAX)=N'UPDATE clean_data SET ';

SELECT @SQL+=
QUOTENAME(COLUMN_NAME)+' = NULLIF(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
CAST('+QUOTENAME(COLUMN_NAME)+' AS VARCHAR(MAX)),
CHAR(13),''''),
CHAR(10),''''),
CHAR(9),''''),
'' '',''''),
''''),'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='clean_data'
AND
(
COLUMN_NAME LIKE 'PROVID[_]%'
OR COLUMN_NAME LIKE 'HEALTH[_]%'
OR COLUMN_NAME LIKE 'LASTUP[_]%'
);

SET @SQL=LEFT(@SQL,LEN(@SQL)-1);

PRINT @SQL;

EXEC sp_executesql @SQL;


/*===========================================================================
END OF DATA CLEANING STAGE

Output:
✓ Standardized dataset
✓ Missing values handled
✓ Hidden whitespace removed
✓ ZIP Codes standardized
✓ Optional fields normalized
✓ Provider & Health columns cleaned

Next Stage:
DATA VALIDATION
===========================================================================*/