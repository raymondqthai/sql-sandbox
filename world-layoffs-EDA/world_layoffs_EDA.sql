-- World Layoffs Exploratory Data Analysis --


-- Dataset: Early 2020 to Early 2023 Layoffs from Global Tech and Startups
-- Goal: Identify the Largest Layoffs from Companies, Industries, Countries, and Time Periods
-- Track Total Layoffs Accumulation Over Time


-- Exploring the Data

SELECT *
FROM layoffs_staging2;




-- Explore Scale and Scope
-- Establish the data's boundaries before GROUPING or AGGREGATING

-- Find the LARGEST LAYOFF EVENT and HIGHEST PERCENTAGE of LAYOFF
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Ranking FULL SHUTDOWN COMPANIES by HEADCOUNT from LARGE COMPANY COLLAPSE to SMALL CLOSURE 
SELECT company, total_laid_off, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Ranking FULL SHUTDOWN COMPANIES by FUND RAISED to find SERVERITY of CAPITOAL LOSS
SELECT company, percentage_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;




-- Explore by Dimension
-- Find CONCENTRATION of LAYOFFS by ISOLATING ONE DIMENSION in query

-- Confirm dataset's FULL DATE RANGE
SELECT MIN("date"), MAX("date")
FROM layoffs_staging2;

-- Identify the COMPANIES with the MOST CUTS ACROSS the ENTIRE PERIOD
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Identify the SECTORS with the HARDEST CUTS ACROSS the ENTIRE PERIOD 
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Identify the COUNTRIES with the HEAVY CONCENTRATION OF CUTS 
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- SHOWS where the WAVE of LAYOFFS GROW, PEAK, OR DECLINE ACROSS the ENTIRE PERIOD 
SELECT YEAR("date"), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR("date")
ORDER BY 1 DESC;

-- Identify LATE STAGES (post-IPO, series C+) with HIGH CUTS for MARKET CORRECTION PRESSURE
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;




-- Explore Layoffs Over Time
-- Track MOMENTUM of LAYOFFS by MONTHS

-- mySQL syntax
-- SUBSTRING(COLUMN Label, COLUMN Number, VALUE Length)
/*
SELECT SUBSTRING("date", 1, 7) AS MONTH
FROM layoffs_staging2
WHERE SUBSTRING("date", 1, 7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC;
*/

-- View TOTAL LAYOFFS per MONTH in YYYY-MM format
SELECT STRFTIME("date", '%Y-%m') AS "month", SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE "month" IS NOT NULL
GROUP BY "month"
ORDER BY 1 ASC;

-- Create COMMON TABLE EXPRESSION (CTE) to produce ROLLING TOTAL of LAYOFFS by MONTHS
-- Shows COMMULATIVE JOB CUTS ACROSS the FULL PERIOD
-- CTE produces MONTHLY TOTALS
WITH ROLLING_TOTAL AS (
	SELECT STRFTIME("date", '%Y-%m') AS "month", SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE "month" IS NOT NULL
	GROUP BY "month"
	ORDER BY 1 ASC
)
-- Outer Query produces a RUNNING SUM
SELECT "month", total_off, SUM(total_off) OVER(ORDER BY "month") AS rolling_total
FROM ROLLING_TOTAL;




-- Explore Top Companies by Year
-- Rank COMPANIES with the MOST LAYOFFS by CALENDAR YEAR

-- Create Base for Ranking CTE
-- Displays TOTAL LAYOFFS per COMPANY per YEAR
SELECT company, YEAR("date"), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR("date")
ORDER BY 3 DESC;

-- Create Ranking CTE to rank COMPANIES by LAYOFFS within EACH YEAR
-- CTE 1. AGGREGATE TOTAL LAYOFFS per COMPANY per YEAR
WITH COMPANY_YEAR (company, "years", total_laid_off) AS (
	SELECT company, YEAR("date"), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR("date")
),
-- CTE 2. Apply DENSE_RANK function within EACH YEAR
COMPANY_YEAR_RANK AS ( 
	SELECT *, RANK_DENSE() OVER (PARTITION BY "years" ORDER BY total_laid_off DESC) AS ranking
	FROM COMPANY_YEAR
	WHERE "years" IS NOT NULL
)
-- Outer Query list TOP 5 COMPANIES per YEAR
SELECT *
FROM COMPANY_YEAR_RANK
WHERE ranking <= 5
ORDER BY "years";




-- Analysis covers four dimensions: company, industry, country, and time
