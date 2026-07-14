--==============================================================
-- 1. DATASET OVERVIEW
--==============================================================

-- Total Records
SELECT COUNT(*) AS Total_Records
FROM raw_data;


-- Total Columns
SELECT COUNT(*) AS Total_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_data';


-- View Table Structure
EXEC sp_help raw_data;


-- Preview Data
SELECT TOP (10) *
FROM raw_data;



--==============================================================
-- 2. MISSING VALUE ANALYSIS
--==============================================================

SELECT
COUNT(*) AS Missing_Name
FROM raw_data
WHERE NAME IS NULL
OR NAME='';


SELECT
COUNT(*) AS Missing_Address
FROM raw_data
WHERE ADDRESS IS NULL
OR ADDRESS='';
 

SELECT
COUNT(*) AS Missing_City
FROM raw_data
WHERE CITY IS NULL
OR CITY='';


SELECT
COUNT(*) AS Missing_State
FROM raw_data
WHERE STATE IS NULL
OR STATE='';


SELECT
COUNT(*) AS Missing_Zip
FROM raw_data
WHERE ZIP IS NULL
OR ZIP='';


SELECT
COUNT(*) AS Missing_Telephone
FROM raw_data
WHERE TELEPHONE IS NULL
OR TELEPHONE='';


SELECT
COUNT(*) AS Missing_Website
FROM raw_data
WHERE WEBSITE IS NULL
OR WEBSITE='';


SELECT
COUNT(*) AS Missing_NPI
FROM raw_data
WHERE NPI IS NULL
OR NPI='';



--==============================================================
-- 3. DUPLICATE ANALYSIS
--==============================================================

-- Duplicate Pharmacy IDs

SELECT
FID,
COUNT(*) AS Duplicate_Count
FROM raw_data
GROUP BY FID
HAVING COUNT(*) > 1;



-- Duplicate NPI Numbers

SELECT
NPI,
COUNT(*) AS Duplicate_Count
FROM raw_data
WHERE NPI<>''
GROUP BY NPI
HAVING COUNT(*)>1;



-- Duplicate Pharmacy Names

SELECT
NAME,
COUNT(*) AS Duplicate_Count
FROM raw_data
GROUP BY NAME
HAVING COUNT(*)>1
ORDER BY Duplicate_Count DESC;



--==============================================================
-- 4. DATA DISTRIBUTION
--==============================================================

-- Pharmacies by State

SELECT
STATE,
COUNT(*) AS Pharmacy_Count
FROM raw_data
GROUP BY STATE
ORDER BY Pharmacy_Count DESC;



-- Top 10 Counties

SELECT TOP (10)
COUNTY,
COUNT(*) AS Pharmacy_Count
FROM raw_data
GROUP BY COUNTY
ORDER BY Pharmacy_Count DESC;



-- Organization Distribution

SELECT TOP (20)
ORGAN_NAME,
COUNT(*) AS Total
FROM raw_data
GROUP BY ORGAN_NAME
ORDER BY Total DESC;



-- Pharmacy Category Distribution

SELECT
NAICSDESCR,
COUNT(*) AS Total
FROM raw_data
GROUP BY NAICSDESCR
ORDER BY Total DESC;



-- HSIP Theme Distribution

SELECT
HSIPTHEMES,
COUNT(*) AS Total
FROM raw_data
GROUP BY HSIPTHEMES
ORDER BY Total DESC;



--==============================================================
-- 5. DATA COMPLETENESS
--==============================================================

SELECT

COUNT(*) AS Total_Records,

SUM(CASE
WHEN WEBSITE='' OR WEBSITE IS NULL
THEN 1
ELSE 0
END) AS Missing_Website,

SUM(CASE
WHEN TELEPHONE='' OR TELEPHONE IS NULL
THEN 1
ELSE 0
END) AS Missing_Telephone,

SUM(CASE
WHEN ADDRESS='' OR ADDRESS IS NULL
THEN 1
ELSE 0
END) AS Missing_Address,

SUM(CASE
WHEN CITY='' OR CITY IS NULL
THEN 1
ELSE 0
END) AS Missing_City,

SUM(CASE
WHEN STATE='' OR STATE IS NULL
THEN 1
ELSE 0
END) AS Missing_State,

SUM(CASE
WHEN ZIP='' OR ZIP IS NULL
THEN 1
ELSE 0
END) AS Missing_Zip,

SUM(CASE
WHEN NPI='' OR NPI IS NULL
THEN 1
ELSE 0
END) AS Missing_NPI

FROM raw_data;



--==============================================================
-- 6. DATA QUALITY SUMMARY
--==============================================================

-- Website Availability

SELECT

CASE

WHEN WEBSITE='' OR WEBSITE IS NULL
THEN 'Missing'

ELSE 'Available'

END AS Website_Status,

COUNT(*) AS Total

FROM raw_data

GROUP BY

CASE

WHEN WEBSITE='' OR WEBSITE IS NULL
THEN 'Missing'

ELSE 'Available'

END;



-- Telephone Availability

SELECT

CASE

WHEN TELEPHONE='' OR TELEPHONE IS NULL
THEN 'Missing'

ELSE 'Available'

END AS Phone_Status,

COUNT(*) AS Total

FROM raw_data

GROUP BY

CASE

WHEN TELEPHONE='' OR TELEPHONE IS NULL
THEN 'Missing'

ELSE 'Available'

END;



-- Distinct States

SELECT DISTINCT STATE
FROM raw_data
ORDER BY STATE;



-- Blank Critical Records

SELECT *
FROM raw_data
WHERE
(NAME='' OR NAME IS NULL)
AND
(ADDRESS='' OR ADDRESS IS NULL)
AND
(CITY='' OR CITY IS NULL);



--Missing Values of all columns

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL +
'
SELECT
    ''' + COLUMN_NAME + ''' AS Column_Name,
    COUNT(*) AS Missing_Values
FROM raw_data
WHERE [' + COLUMN_NAME + '] IS NULL
      OR CAST([' + COLUMN_NAME + '] AS NVARCHAR(MAX)) = ''''
UNION ALL'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_data';

-- Remove the last UNION ALL
SET @SQL = LEFT(@SQL, LEN(@SQL) - LEN('UNION ALL'));

-- Execute the generated SQL
EXEC sp_executesql @SQL;


