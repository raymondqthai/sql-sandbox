# World Layoffs Exploratory Data Analysis

SQL exploratory data analysis project for the world layoffs dataset. Identifies layoff patterns across companies, industries, countries, and time periods. Covers early 2020 to early 2023.

## Features

- Finds the largest layoff events and highest percentages of workforce reduction
- Ranks companies by total headcount cuts across the entire period
- Identifies which industries and countries had the heaviest concentration of layoffs
- Tracks layoff momentum by year and month with monthly rolling totals
- Shows cumulative job cuts over time using window functions
- Ranks top five companies by layoffs within each calendar year
- Uses Common Table Expressions (CTEs) for complex multi-step analysis

## How to Run

1. Clone or download the repository
   ```
   git clone https://github.com/yourusername/world-layoffs-eda.git
   cd world-layoffs-eda
   ```

2. Install DuckDB
   ```
   pip install duckdb
   ```

3. Load and run the analysis in DuckDB

   Option A: Using the DBeaver GUI (recommended for beginners)
   - Open DBeaver
   - Create a new DuckDB connection
   - Right-click and select "SQL Editor"
   - Open `world_layoffs_exploratory.sql`
   - Run each query section individually to explore results

   Option B: Using the command line
   ```
   duckdb
   ```
   Then paste SQL queries from `world_layoffs_exploratory.sql`

4. Review results in the output. No data is modified in the analysis phase.

## Requirements

- DuckDB (embedded SQL database)
- Cleaned layoff dataset from `layoffs_staging2` table
- DBeaver (optional GUI, makes query execution and visualization easier)
- Python 3.7 or later (if using DuckDB Python package)

No external API keys or registration required. The tool works with local files.

## Usage

The analysis runs through four main exploration phases:

**Phase 1: Explore Scale and Scope**
Establishes data boundaries by finding the largest single layoff event and the highest percentage of workforce reduction. Shows which companies completely shut down and ranks them by headcount and capital loss.

**Phase 2: Explore by Dimension**
Isolates one variable at a time to find concentration. Answers: Which companies cut the most? Which industries were hit hardest? Which countries saw the most layoffs? Which funding stages (pre-IPO, post-IPO, Series C+) felt the most pressure?

**Phase 3: Explore Layoffs Over Time**
Tracks layoff momentum month by month using STRFTIME to format dates. Creates a rolling total showing cumulative job cuts from start to finish. Window functions calculate running sums across months.

**Phase 4: Explore Top Companies by Year**
Ranks the top five companies by layoffs within each calendar year. Uses multiple CTEs to aggregate, partition, and rank data. Shows which companies dominated layoff activity each year.

## About DuckDB vs PostgreSQL vs MySQL

You used DuckDB syntax. DuckDB and PostgreSQL are similar, but have key differences. DuckDB uses `strftime()` for date formatting (like SQLite), while PostgreSQL uses `to_char()`. DuckDB supports both `=` and `==` for equality. Your script uses `STRFTIME()` and window functions like `ROW_NUMBER()`, both of which are DuckDB-native. MySQL syntax (noted in your comments) differs more significantly. PostgreSQL would require converting `STRFTIME()` to `to_char()` and `RANK_DENSE()` to `dense_rank()`.

One note: Your script uses `RANK_DENSE()`, which is PostgreSQL syntax. DuckDB uses lowercase `dense_rank()`. If running in DuckDB, change `RANK_DENSE()` to `dense_rank()` in the final query section.

## What I Learned

- How to use aggregate functions (SUM, MAX, MIN) to establish data boundaries
- How to isolate single dimensions with GROUP BY to find patterns
- How to format dates and extract parts (year, month) using STRFTIME
- How to build rolling totals and cumulative sums with window functions and CTEs
- How CTEs break complex queries into readable, reusable steps
- How PARTITION BY and ORDER BY clauses control window function calculations
- The difference between RANK and DENSE_RANK in ranking scenarios

## Credits

Based on a tutorial by Alex The Analyst
Link: https://www.youtube.com/watch?v=QYd-RtK58VQ

Adapted for DuckDB syntax and DBeaver GUI on Mac OS.
