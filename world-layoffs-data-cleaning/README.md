# World Layoffs Data Cleaning

A SQL data cleaning project built in DuckDB. It takes a raw dataset of global tech layoffs and transforms it into analysis-ready data by removing duplicates, standardizing values, handling nulls, and dropping irrelevant rows.

---

## Features

- Creates a staging table to preserve the original raw data
- Converts `'NULL'` strings to proper `NULL` values on insert using `NULLIF`
- Detects and removes duplicate rows using window functions
- Trims whitespace from company names
- Standardizes inconsistent industry labels (e.g., multiple Crypto variations become one)
- Strips trailing punctuation from country names
- Converts date strings into proper `DATE` format using `TRY_STRPTIME`
- Fills in missing industry values using data from matching company rows
- Drops rows where both layoff columns are `NULL` (no measurable data)
- Removes the helper column after cleaning is complete

---

## Requirements

- [DuckDB](https://duckdb.org/docs/installation/) — free, no account or API key needed
- [DBeaver](https://dbeaver.io/download/) — free SQL GUI to run the script visually

No API keys. No registration required. Both tools install in minutes.

---

## How to Run

1. Download or clone this repository
2. Open DBeaver and connect to a new DuckDB database file
3. Import `layoffs.csv` into a table named `layoffs`
4. Open `world_layoffs_clean.sql` in DBeaver's SQL editor
5. Run the script from top to bottom
6. Query `layoffs_staging2` to view the cleaned dataset

```sql
SELECT *
FROM layoffs_staging2;
```

---

## Usage

The script runs in four sequential steps. Each step builds on the last.

```
Step 1 — Remove Duplicates
  Creates layoffs_staging from the raw layoffs table.
  Creates layoffs_staging2 with an added row_num column.
  Converts 'NULL' strings to proper NULL values on insert using NULLIF.
  Assigns row numbers with ROW_NUMBER() to find exact duplicates.
  Deletes all rows where row_num > 1.

Step 2 — Standardize the Data
  Trims spaces from company names.
  Collapses Crypto, Crypto Currency, CryptoCurrency → Crypto.
  Removes trailing period from "United States."
  Converts the date column from VARCHAR to DATE using TRY_STRPTIME.
  Alters the column type from VARCHAR to DATE.

Step 3 — Handle Null and Empty Values
  Converts remaining empty strings in industry to NULL.
  Fills missing industry values using a self-join on company name.
  Leaves rows with no match (e.g., Bally's Interactive) as NULL.

Step 4 — Remove Unhelpful Rows
  Deletes rows where total_laid_off and percentage_laid_off are both NULL.
  Drops the row_num helper column.
```

---

## What I Learned

- How to use `ROW_NUMBER()` with `PARTITION BY` to detect exact duplicate rows
- How `NULLIF` converts string literals like `'NULL'` into proper `NULL` values at insert time
- How staging tables protect raw data during iterative cleaning
- How to fill missing values with a self-join on the same table
- How DuckDB's `TRY_STRPTIME` and `TRY_CAST` handle date conversion without crashing on bad values
- How to alter a column's data type in DuckDB using `ALTER COLUMN ... TYPE`

---

## Credits

Based on the MySQL Data Cleaning tutorial by Alex the Analyst.  
Original tutorial: https://www.youtube.com/watch?v=4UltKCnnnTA

**Personal modifications:**
- Rewrote all SQL in DuckDB syntax instead of MySQL
- Used `NULLIF` to handle `'NULL'` strings at insert time rather than patching them later
- Used `IS NULL` and `IS NOT NULL` throughout instead of string comparisons
- Used `TRY_STRPTIME` and `TRY_CAST` for safer date conversion
- Used `CREATE TABLE AS SELECT` syntax for staging table creation
- Used DBeaver as the SQL GUI instead of MySQL Workbench
