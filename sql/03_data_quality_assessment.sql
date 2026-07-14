/*==============================================================
 Project : Pharmaceutical Data Migration Simulator
 Stage   : 02 - Data Quality Assessment

 Objective:
 Identify records that may cause issues during migration.
 No data is modified in this stage.
 Only bad-quality records are identified.

==============================================================*/


--==============================================================
-- 1. CHECK DUPLICATE PRIMARY KEYS
--==============================================================
-- Every FID should be unique.
-- If duplicate FIDs exist, migration should stop.

SELECT
    FID,
    COUNT(*) AS Duplicate_Count
FROM raw_data
GROUP BY FID
HAVING COUNT(*) > 1;



--==============================================================
-- 2. CHECK DUPLICATE NPI NUMBERS
--==============================================================
-- NPI (National Provider Identifier) should normally be unique.
-- Duplicate NPIs indicate duplicate provider records.

SELECT
    NPI,
    COUNT(*) AS Duplicate_Count
FROM raw_data
WHERE NPI IS NOT NULL
AND NPI <> ''
GROUP BY NPI
HAVING COUNT(*) > 1;



--==============================================================
-- 3. CHECK DUPLICATE PHARMACY RECORDS
--==============================================================
-- Same pharmacy at the same address appearing multiple times.

SELECT
    NAME,
    ADDRESS,
    CITY,
    STATE,
    COUNT(*) AS Duplicate_Count
FROM raw_data
GROUP BY
    NAME,
    ADDRESS,
    CITY,
    STATE
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;



--==============================================================
-- 4. CHECK INVALID PHONE NUMBERS
--==============================================================
-- Valid phone numbers should contain exactly 10 digits
-- after removing formatting characters.

SELECT
    FID,
    NAME,
    TELEPHONE
FROM raw_data
WHERE
    TELEPHONE IS NOT NULL
AND TELEPHONE <> ''
AND LEN(
        REPLACE(
        REPLACE(
        REPLACE(
        TELEPHONE,'-',''),
        '(',''),
        ')','')
    ) <> 10;



--==============================================================
-- 5. CHECK INVALID ZIP CODES
--==============================================================
-- US ZIP codes should contain either
-- 5 digits or 9 digits.

SELECT
    FID,
    NAME,
    ZIP
FROM raw_data
WHERE
    ZIP IS NOT NULL
AND ZIP <> ''
AND LEN(ZIP) NOT IN (5,9);



--==============================================================
-- 6. CHECK INVALID STATE CODES
--==============================================================
-- State codes should contain exactly 2 characters.

SELECT
    FID,
    NAME,
    STATE
FROM raw_data
WHERE
    STATE IS NOT NULL
AND STATE <> ''
AND LEN(STATE) <> 2;



--==============================================================
-- 7. CHECK INVALID WEBSITE FORMAT
--==============================================================
-- Website should start with http or https.

SELECT
    FID,
    NAME,
    WEBSITE
FROM raw_data
WHERE
    WEBSITE IS NOT NULL
AND WEBSITE <> ''
AND WEBSITE NOT LIKE 'http%';



--==============================================================
-- 8. CHECK MISSING MANDATORY FIELDS
--==============================================================
-- These columns are mandatory for migration.

SELECT *
FROM raw_data
WHERE

NAME IS NULL OR NAME=''

OR ADDRESS IS NULL OR ADDRESS=''

OR CITY IS NULL OR CITY=''

OR STATE IS NULL OR STATE=''

OR ZIP IS NULL OR ZIP='';



--==============================================================
-- 9. CHECK INVALID COORDINATES
--==============================================================
-- Coordinates should not be zero.

SELECT
    FID,
    NAME,
    X,
    Y
FROM raw_data
WHERE
    X='0'
OR Y='0';



--==============================================================
-- 10. CHECK MISSING TELEPHONE
--==============================================================
-- Telephone is important for pharmacy contact.

SELECT
    FID,
    NAME,
    TELEPHONE,
    count(*) as missing_telephone
FROM raw_data
WHERE
    TELEPHONE IS NULL
OR TELEPHONE=''
group by FID,NAME,TELEPHONE;



--==============================================================
-- 11. CHECK MISSING ORGANIZATION NAME
--==============================================================

SELECT
    FID,
    NAME,
    ORGAN_NAME
FROM raw_data
WHERE
    ORGAN_NAME IS NULL
OR ORGAN_NAME='';



--==============================================================
-- 12. CHECK MISSING NPI
--==============================================================
-- NPI is an important healthcare identifier.

SELECT
    FID,
    NAME,
    NPI
FROM raw_data
WHERE
    NPI IS NULL
    OR NPI='';



--==============================================================
-- 13. CHECK FIPS CODE LENGTH
--==============================================================
-- FIPS codes should contain exactly 5 digits.

SELECT
    FID,
    NAME,
    FIPS
FROM raw_data
WHERE
    FIPS IS NOT NULL
AND FIPS <> ''
AND LEN(FIPS) <> 5;



--==============================================================
-- 14. DATA QUALITY SUMMARY
--==============================================================
-- Overall summary of important quality issues.

SELECT

COUNT(*) AS Total_Records,

SUM(CASE
WHEN TELEPHONE='' OR TELEPHONE IS NULL
THEN 1 ELSE 0
END) AS Missing_Telephone,

SUM(CASE
WHEN WEBSITE='' OR WEBSITE IS NULL
THEN 1 ELSE 0
END) AS Missing_Website,

SUM(CASE
WHEN NPI='' OR NPI IS NULL
THEN 1 ELSE 0
END) AS Missing_NPI,

SUM(CASE
WHEN ORGAN_NAME='' OR ORGAN_NAME IS NULL
THEN 1 ELSE 0
END) AS Missing_Organization,

SUM(CASE
WHEN ZIP='' OR ZIP IS NULL
THEN 1 ELSE 0
END) AS Missing_ZIP,

SUM(CASE
WHEN STATE='' OR STATE IS NULL
THEN 1 ELSE 0
END) AS Missing_State

FROM raw_data;