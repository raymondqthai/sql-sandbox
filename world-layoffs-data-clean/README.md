# World Layoffs Data Cleaning

SQL data cleaning project for the world layoffs dataset. Removes duplicates, standardizes values, handles missing data, and prepares the dataset for analysis.

## Features

- Removes duplicate records across all columns
- Standardizes company names, industries, and countries with consistent formatting
- Converts date strings into proper DATE data types
- Standardizes numeric columns with appropriate data types (INTEGER, DOUBLE)
- Fills missing industry values by matching company data across rows
- Removes rows with no measurable layoff data
- Handles empty strings and converts them to NULL values

## How to Run

1. Clone or download the repository
   ```
   git clone https://github.com/yourusername/world-layoffs-cleaning.git
   cd world-layoffs-cleaning
   ```

2. Install DuckDB
   ```
   pip install duckdb
   ```

3. Load the CSV file and run the cleaning script in DuckDB

   Option A: Using the DBeaver GUI (recommended for beginners)
   - Open DBeaver
   - Create a new DuckDB connection
   - Right-click and select "SQL Editor"
   - Open and execute `world_layoffs_clean.sql` line by line or section by section

   Option B: Using the command line
   ```
   duckdb
   ```
   Then paste the SQL queries from `world_layoffs_clean.sql`

4. The cleaned data will be stored in the `layoffs_staging2` table

## Requirements

- DuckDB (embedded SQL database)
- DBeaver (optional GUI, makes running queries easier)
- Python 3.7 or later (if using DuckDB Python package)

No external API keys or registration required. The tool works with local files.

## Usage

The script runs through four main cleaning phases:

**Phase 1: Remove Duplicates**
Identifies and deletes rows with identical values across all columns to prevent inflated metrics.

**Phase 2: Standardize the Data**
Trims whitespace from company names, consolidates industry categories (e.g., all crypto variants become "Crypto"), removes trailing periods from countries, and converts date strings to DATE format.

**Phase 3: Handle Null Values**
Converts empty strings to NULL for consistency. Fills missing industry data by cross-referencing other rows from the same company.

**Phase 4: Remove Unmeasurable Rows**
Deletes rows where both total_laid_off and percentage_laid_off are NULL. Removes the duplicate indicator column.

## About DuckDB vs PostgreSQL

You used DuckDB syntax. DuckDB and PostgreSQL are similar in many ways, but differ in key areas. DuckDB supports both = and == for equality comparison, while PostgreSQL only supports =. DuckDB does not support the to_date PostgreSQL date formatting function. Instead, use the strptime function. Your script correctly uses `TRY_STRPTIME`, which is DuckDB-specific. PostgreSQL would use `STR_TO_DATE` instead (as noted in your MySQL comments). Window functions like ROW_NUMBER() work in both databases, so that syntax transfers well.

## What I Learned

- How to stage data safely in a copy before making changes
- How to use window functions like ROW_NUMBER() to identify duplicates
- How to join tables to fill missing values from related records
- How to convert string data types to proper DATE and numeric types
- How SQL NULL handling differs from empty strings and matters for data quality
- The importance of data standardization before analysis

## Credits

Based on a tutorial by Alex The Analyst
Link: https://www.youtube.com/watch?v=4UltKCnnnTA

Adapted for DuckDB syntax and DBeaver GUI on Mac OS.
