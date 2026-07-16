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


SELECT FID,
       NAME,
       NPI,
       ENT_TYPE,
       ORGAN_NAME
FROM raw_data
where NPI IS NULL
OR NPI = '';



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

SELECT
    state,
    count(*)
FROM raw_data
WHERE
    ZIP IS NOT NULL
    AND ZIP <> ''
    AND LEN(ZIP) = 4
group by state;


SELECT
    state,
    count(*)
FROM raw_data
WHERE
    ZIP IS NOT NULL
    AND ZIP <> ''
    AND LEN(ZIP) = 5
group by state;



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
-- Overall summary of important quality issues (NULLS).

SELECT

COUNT(*) AS Total_Records,

SUM(CASE WHEN FID IS NULL THEN 1 ELSE 0 END) AS Missing_FID,

SUM(CASE WHEN ID IS NULL OR ID = '' THEN 1 ELSE 0 END) AS Missing_ID,

SUM(CASE WHEN SECCLASS IS NULL OR SECCLASS = '' THEN 1 ELSE 0 END) AS Missing_SECCLASS,

SUM(CASE WHEN NAME IS NULL OR NAME = '' THEN 1 ELSE 0 END) AS Missing_NAME,

SUM(CASE WHEN TELEPHONE IS NULL OR TELEPHONE = '' THEN 1 ELSE 0 END) AS Missing_TELEPHONE,

SUM(CASE WHEN ADDRESS IS NULL OR ADDRESS = '' THEN 1 ELSE 0 END) AS Missing_ADDRESS,

SUM(CASE WHEN ADDRESS2 IS NULL OR ADDRESS2 = '' THEN 1 ELSE 0 END) AS Missing_ADDRESS2,

SUM(CASE WHEN CITY IS NULL OR CITY = '' THEN 1 ELSE 0 END) AS Missing_CITY,

SUM(CASE WHEN STATE IS NULL OR STATE = '' THEN 1 ELSE 0 END) AS Missing_STATE,

SUM(CASE WHEN ZIP IS NULL OR ZIP = '' THEN 1 ELSE 0 END) AS Missing_ZIP,

SUM(CASE WHEN ZIPP4 IS NULL OR ZIPP4 = '' THEN 1 ELSE 0 END) AS Missing_ZIPP4,

SUM(CASE WHEN COUNTY IS NULL OR COUNTY = '' THEN 1 ELSE 0 END) AS Missing_COUNTY,

SUM(CASE WHEN FIPS IS NULL OR FIPS = '' THEN 1 ELSE 0 END) AS Missing_FIPS,

SUM(CASE WHEN DIRECTIONS IS NULL OR DIRECTIONS = '' THEN 1 ELSE 0 END) AS Missing_DIRECTIONS,

SUM(CASE WHEN EMERGTITLE IS NULL OR EMERGTITLE = '' THEN 1 ELSE 0 END) AS Missing_EMERGTITLE,

SUM(CASE WHEN EMERGTEL IS NULL OR EMERGTEL = '' THEN 1 ELSE 0 END) AS Missing_EMERGTEL,

SUM(CASE WHEN EMERGEXT IS NULL OR EMERGEXT = '' THEN 1 ELSE 0 END) AS Missing_EMERGEXT,

SUM(CASE WHEN CONTDATE IS NULL OR CONTDATE = '' THEN 1 ELSE 0 END) AS Missing_CONTDATE,

SUM(CASE WHEN CONTHOW IS NULL OR CONTHOW = '' THEN 1 ELSE 0 END) AS Missing_CONTHOW,

SUM(CASE WHEN GEODATE IS NULL OR GEODATE = '' THEN 1 ELSE 0 END) AS Missing_GEODATE,

SUM(CASE WHEN GEOHOW IS NULL OR GEOHOW = '' THEN 1 ELSE 0 END) AS Missing_GEOHOW,

SUM(CASE WHEN HSIPTHEMES IS NULL OR HSIPTHEMES = '' THEN 1 ELSE 0 END) AS Missing_HSIPTHEMES,

SUM(CASE WHEN NAICSCODE IS NULL OR NAICSCODE = '' THEN 1 ELSE 0 END) AS Missing_NAICSCODE,

SUM(CASE WHEN NAICSDESCR IS NULL OR NAICSDESCR = '' THEN 1 ELSE 0 END) AS Missing_NAICSDESCR,

SUM(CASE WHEN GEOLINKID IS NULL THEN 1 ELSE 0 END) AS Missing_GEOLINKID,

SUM(CASE WHEN X IS NULL THEN 1 ELSE 0 END) AS Missing_X,

SUM(CASE WHEN Y IS NULL THEN 1 ELSE 0 END) AS Missing_Y,

SUM(CASE WHEN ST_VENDOR IS NULL OR ST_VENDOR = '' THEN 1 ELSE 0 END) AS Missing_ST_VENDOR,

SUM(CASE WHEN ST_VERSION IS NULL OR ST_VERSION = '' THEN 1 ELSE 0 END) AS Missing_ST_VERSION,

SUM(CASE WHEN GEOPREC IS NULL OR GEOPREC = '' THEN 1 ELSE 0 END) AS Missing_GEOPREC,

SUM(CASE WHEN PHONELOC IS NULL OR PHONELOC = '' THEN 1 ELSE 0 END) AS Missing_PHONELOC,

SUM(CASE WHEN QC_QA IS NULL OR QC_QA = '' THEN 1 ELSE 0 END) AS Missing_QC_QA,

SUM(CASE WHEN WEBSITE IS NULL OR WEBSITE = '' THEN 1 ELSE 0 END) AS Missing_WEBSITE,

SUM(CASE WHEN NPI IS NULL OR NPI = '' THEN 1 ELSE 0 END) AS Missing_NPI,

SUM(CASE WHEN ENT_TYPE IS NULL OR ENT_TYPE = '' THEN 1 ELSE 0 END) AS Missing_ENT_TYPE,

SUM(CASE WHEN ORGAN_NAME IS NULL OR ORGAN_NAME = '' THEN 1 ELSE 0 END) AS Missing_ORGAN_NAME

FROM raw_data;



--==============================================================
-- 15. DATA QUALITY SUMMARY
--==============================================================
-- Overall summary of important quality issues (DUPLICATES).


SELECT

-- Duplicate FID
(
    SELECT COUNT(*)
    FROM
    (
        SELECT FID
        FROM raw_data
        GROUP BY FID
        HAVING COUNT(*) > 1
    ) d
) AS Duplicate_FID,

-- Duplicate ID
(
    SELECT COUNT(*)
    FROM
    (
        SELECT ID
        FROM raw_data
        GROUP BY ID
        HAVING COUNT(*) > 1
    ) d
) AS Duplicate_ID,

-- Duplicate NPI
(
    SELECT COUNT(*)
    FROM
    (
        SELECT NPI
        FROM raw_data
        WHERE NPI IS NOT NULL
          AND NPI <> ''
        GROUP BY NPI
        HAVING COUNT(*) > 1
    ) d
) AS Duplicate_NPI,

-- Duplicate GEOLINKID
(
    SELECT COUNT(*)
    FROM
    (
        SELECT GEOLINKID
        FROM raw_data
        WHERE GEOLINKID IS NOT NULL
        GROUP BY GEOLINKID
        HAVING COUNT(*) > 1
    ) d
) AS Duplicate_GEOLINKID;