# World Layoffs Data Cleaning

A SQL data cleaning project built in DuckDB. It takes a raw dataset of global tech layoffs and transforms it into analysis-ready data by removing duplicates, standardizing values, handling nulls, and dropping irrelevant rows.

---

## Features

- Creates a staging table to preserve the original raw data
- Detects and removes duplicate rows using window functions
- Trims whitespace from company names
- Standardizes inconsistent industry labels (e.g., multiple Crypto variations become one)
- Strips trailing punctuation from country names
- Converts date strings into proper DATE format
- Fills in missing industry values using data from matching company rows
- Drops rows where both layoff columns are null (no measurable data)
- Removes the helper column after cleaning is complete

---

## Requirements

- [DuckDB](https://duckdb.org/docs/installation/) — free, no account or API key needed
- [DBeaver](https://dbeaver.io/download/) — free SQL GUI to run the script visually

No Python. No API keys. No registration required. Both tools install in minutes.

---

## How to Run

1. Download or clone this repository
2. Open DBeaver and connect to a new DuckDB database file
3. Import `layoffs.csv` into a table named `layoffs`
4. Open `world_layoffs.sql` in DBeaver's SQL editor
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
  Creates layoffs_staging and layoffs_staging2.
  Assigns row numbers to find exact duplicate rows.
  Deletes all rows where row_num > 1.

Step 2 — Standardize the Data
  Trims spaces from company names.
  Collapses Crypto, Crypto Currency, CryptoCurrency → Crypto.
  Removes trailing period from "United States."
  Converts date column from VARCHAR to DATE type.

Step 3 — Handle Null and Empty Values
  Converts empty strings in industry to 'NULL'.
  Fills missing industry values using a self-join on company name.
  Leaves rows with no match (e.g., Bally's Interactive) as NULL.

Step 4 — Remove Unhelpful Rows
  Deletes rows where total_laid_off and percentage_laid_off are both NULL.
  Drops the row_num helper column.
```

---

## What I Learned

- How to use `ROW_NUMBER()` with `PARTITION BY` to identify exact duplicate rows
- How staging tables protect raw data during iterative cleaning
- How to fill missing values with a self-join on the same table
- How DuckDB's `TRY_STRPTIME` and `TRY_CAST` handle date conversion safely without crashing on bad values
- How to use `ALTER TABLE ... ALTER COLUMN ... TYPE` to change a column's data type in DuckDB

---

## Credits

Based on the MySQL Data Cleaning tutorial by Alex the Analyst.
Original tutorial: https://www.youtube.com/watch?v=4UltKCnnnTA

**Personal modifications:**
- Rewrote all SQL in DuckDB syntax instead of MySQL
- Used `TRY_STRPTIME` and `TRY_CAST` for safer date conversion
- Used `CREATE TABLE AS SELECT` syntax for staging table creation
- Used DBeaver as the SQL GUI instead of MySQL Workbench
