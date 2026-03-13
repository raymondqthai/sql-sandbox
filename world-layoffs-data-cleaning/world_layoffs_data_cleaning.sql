-- Data Cleaning --


-- 0. Create a Copy of Database to Work On --
-- Create Staging Table to Test and Iterate Safely
SELECT *
FROM layoffs;


-- mySQL syntax
/*
CREATE TABLE layoffs_staging
LIKE layoffs;
 */

-- Create Staging Table Similar Structure to Original
CREATE TABLE layoffs_staging AS
SELECT *
FROM layoffs
WHERE 0;


-- mySQL syntax
/*
INSERT layoffs_staging
SELECT *
FROM layoffs;
*/

-- Copy All Original Data into Staging Table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


SELECT *
FROM layoffs_staging;




-- 1. Remove Duplicates --
-- Removing Duplicates Reduces Inflated Metrics and Skew Analysis

-- Create a Column to Indicate for Duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, "location", industry, 
total_laid_off, percentage_laid_off, "date", 
stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- View Duplicates Rows
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, "location", industry, 
total_laid_off, percentage_laid_off, "date", 
stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Check for Duplicates from Casper
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


-- Create a Second Copy Table that Includes row_num Column
CREATE TABLE layoffs_staging2 (
company VARCHAR, 
"location" VARCHAR, 
industry VARCHAR, 
total_laid_off VARCHAR, 
percentage_laid_off VARCHAR, 
date VARCHAR, 
stage VARCHAR, 
country VARCHAR, 
funds_raised_millions VARCHAR,
row_num INTEGER);


-- Copy All Data From First Copy to Second
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, "location", industry, 
total_laid_off, percentage_laid_off, "date", 
stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- View Duplicates Based on row_num Column
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Remove Duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;




-- 2. Standardize the Data --
-- Keep Format Consistent to Produce Accurate Data

-- Checking Company Column
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY company;

-- Test Modification to Remove the Empty Space in Front
SELECT company, TRIM(company)
FROM layoffs_staging2
ORDER BY company;

-- Standardized Company Name to Keep Values Consistent
UPDATE layoffs_staging2
SET company = TRIM(company);


-- Checking Industry Column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Standardized Similar Values in Industry One Category
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Checking Location Column
SELECT DISTINCT "location"
FROM layoffs_staging2
ORDER BY 1;


-- Checking Country Column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

-- Test Modification to Remove the Period at the End
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Standardized Country Name to Keep Values Consistent
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Checking Date Column
SELECT "date"
FROM layoffs_staging2;

-- mySQL syntax
/*
SELECT "date",
STRING_TO_DATE("date", '%m/%d/%Y')
FROM layoffs_staging2;
*/

-- Test Modification to Convert String into Proper Date Format
-- TRY_STRPTIME function converts string to timestamp 
-- and Includes NULL when conversion fails
-- CAST function converts data type in this case timestamp to date
SELECT "date", 
CAST(TRY_STRPTIME("date", '%m/%d/%Y') AS DATE)
FROM layoffs_staging2;

-- Standardized Proper Date Format
-- TRY_CAST FUNCTION converts data type 
-- and Includes NULL When Conversion Fails
UPDATE layoffs_staging2
SET "date" = CAST(TRY_STRPTIME("date", '%m/%d/%Y') AS DATE)
WHERE TRY_CAST("date" AS DATE) IS NULL;

-- Check Date Type
SELECT typeof("date")
FROM layoffs_staging2

-- mySQL syntax
/*
ALTER TABLE layoffs_staging2
MODIFY COLUMN "date" DATE;
*/

-- Standardized Column to be Date Type
ALTER TABLE layoffs_staging2
ALTER COLUMN "date" TYPE DATE USING TRY_CAST("date" AS DATE);




-- 3. Null Values / Empty Values
-- Reduce Query Failures and Reduce Incomplete Results/Data

-- Check Laid Off Values for NULL
-- Rows Provide No Value to Measure Layoffs
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';


-- Checking industry
SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry = 'NULL'
OR industry = '';

-- Checking Airbnb for Additional Industry Values
-- To Provide Context to Industry 'NULL'Values
SELECT company, industry
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Standardized Empty Values with 'NULL' string
UPDATE layoffs_staging2
SET industry = 'NULL'
WHERE industry = '';

-- Test Modification Join Logic
-- Fill in Incomplete Industry Data with Known Data from the Same Company
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry = 'NULL')
AND t2.industry != 'NULL'
ORDER BY t1.company;

-- mySQL Syntax
/*
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry = 'NULL')
AND t2.industry != 'NULL';
*/

-- Standardized Columns Join Logic
-- Fill in Incomplete Industry Data with Known Data from the Same Company
UPDATE layoffs_staging2 t1
SET industry = t2.industry
FROM layoffs_staging2 t2
WHERE t1.company = t2.company
AND t1.industry = 'NULL'
AND t2.industry != 'NULL';


-- Check Bally's Interactive Industry 'NULL' value
-- No Additional Row to Provide Context
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'




-- 4. Remove Any Columns


-- Remove Rows with No Metrics Proof of Layoffs
DELETE 
FROM layoffs_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL';

-- Remove Duplicate Indicator Column After Removing All Duplicates
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- View Cleaned DataSet
SELECT *
FROM layoffs_staging2;
