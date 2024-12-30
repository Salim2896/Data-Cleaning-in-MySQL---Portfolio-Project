
# Data Cleaning in MySQL Portfolio Project

This project demonstrates a comprehensive data cleaning process in MySQL using the `world_layoffs` dataset. Below is a step-by-step explanation of the tasks performed.

## Prerequisites
Ensure that you have access to a MySQL database and the necessary privileges to execute SQL commands such as `CREATE`, `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.

---

## Step 1: Remove Duplicates
### Objective:
Eliminate duplicate rows based on specific columns.

1. **Create a staging table:**
   ```sql
   CREATE TABLE layoffs_staging
   LIKE world_layoffs.layoffs;
   ```

2. **Insert data into the staging table:**
   ```sql
   INSERT INTO layoffs_staging
   SELECT *
   FROM layoffs;
   ```

3. **Identify duplicates using `ROW_NUMBER()`:**
   ```sql
   SELECT *,
   ROW_NUMBER() OVER (
     PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
   ) AS row_num
   FROM layoffs_staging;
   ```

4. **Create a second staging table to store cleaned data:**
   ```sql
   CREATE TABLE layoffs_staging2 (
     `company` TEXT,
     `location` TEXT,
     `industry` TEXT,
     `total_laid_off` INT DEFAULT NULL,
     `percentage_laid_off` TEXT,
     `date` TEXT,
     `stage` TEXT,
     `country` TEXT,
     `funds_raised_millions` INT DEFAULT NULL,
     `row_num` INT
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
   ```

5. **Insert data without duplicates:**
   ```sql
   INSERT INTO layoffs_staging2
   SELECT *,
   ROW_NUMBER() OVER (
     PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
   ) AS row_num
   FROM layoffs_staging;
   ```

6. **Remove duplicate rows:**
   ```sql
   DELETE
   FROM layoffs_staging2
   WHERE row_num > 1;
   ```

---

## Step 2: Standardize the Data
### Objective:
Ensure consistency in the data by trimming spaces, standardizing formats, and correcting inconsistencies.

1. **Trim leading and trailing spaces:**
   ```sql
   UPDATE layoffs_staging2
   SET company = TRIM(company);
   ```

2. **Standardize industry names:**
   ```sql
   UPDATE layoffs_staging2
   SET industry = 'Crypto'
   WHERE industry LIKE 'crypto%';
   ```

3. **Clean up country names:**
   ```sql
   UPDATE layoffs_staging2
   SET country = TRIM(TRAILING '.' FROM country)
   WHERE country LIKE 'United States%';
   ```

4. **Convert date to a standardized format:**
   ```sql
   UPDATE layoffs_staging2
   SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

   ALTER TABLE layoffs_staging2
   MODIFY COLUMN `date` DATE;
   ```

---

## Step 3: Handle Null or Blank Values
### Objective:
Address missing or blank values in critical columns.

1. **Identify rows with null values:**
   ```sql
   SELECT *
   FROM layoffs_staging2
   WHERE total_laid_off IS NULL
   AND percentage_laid_off IS NULL;
   ```

2. **Update blank values to NULL:**
   ```sql
   UPDATE layoffs_staging2
   SET industry = NULL
   WHERE industry = '';
   ```

3. **Fill null values using other rows with matching data:**
   ```sql
   UPDATE layoffs_staging2 AS t1
   JOIN layoffs_staging2 AS t2
     ON t1.company = t2.company
   SET t1.industry = t2.industry
   WHERE t1.industry IS NULL
   AND t2.industry IS NOT NULL;
   ```

---

## Step 4: Remove Irrelevant Data
### Objective:
Delete unnecessary rows and drop irrelevant columns.

1. **Identify irrelevant rows:**
   ```sql
   SELECT *
   FROM layoffs_staging2
   WHERE total_laid_off IS NULL
   AND percentage_laid_off IS NULL;
   ```

2. **Delete irrelevant rows:**
   ```sql
   DELETE
   FROM layoffs_staging2
   WHERE total_laid_off IS NULL
   AND percentage_laid_off IS NULL;
   ```

3. **Drop the `row_num` column:**
   ```sql
   ALTER TABLE layoffs_staging2
   DROP COLUMN row_num;
   ```

---

## Final Verification
### Objective:
Verify the cleaned data.

1. **Preview the cleaned data:**
   ```sql
   SELECT *
   FROM layoffs_staging2;
   ```

---

## Summary
The data cleaning process included:
- Removing duplicate rows.
- Standardizing text data.
- Handling null or blank values.
- Removing irrelevant data.
- Ensuring the data is ready for further analysis or reporting.



---

