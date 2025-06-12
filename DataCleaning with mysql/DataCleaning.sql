-- 1.Remove Duplicates
-- 2.Standardizing
-- 3.Null Values or Blank Values
-- 4.Remove any Columns or Rows

USE layoffs;

-- import layoffs table 
DESCRIBE layoffs;
SELECT * FROM layoffs;

-- CREATE TABLE `layoffs_staging` (
--   `company` text,
--   `location` text,
--   `industry` text,
--   `total_laid_off` int DEFAULT NULL,
--   `percentage_laid_off` text,
--   `date` text,
--   `stage` text,
--   `country` text,
--   `funds_raised_millions` int DEFAULT NULL,
-- );



CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/ali/Downloads/layoffs.csv'
INTO TABLE layoffs_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- Use this if your CSV has a header row

WITH lay_cte AS (

SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off , `date`, stage , country , funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT * FROM lay_cte 
WHERE row_num > 1;


SELECT * FROM layoffs_staging 
WHERE company = "Casper";


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Remove duplicates
INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off , `date`, stage , country , funds_raised_millions) as row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2 
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2 ;

-- standardizing

SELECT company, TRIM(company)
from layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT * FROM layoffs_staging2
WHERE industry LIKE '%crypto%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM layoffs_staging2;


SELECT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country =  TRIM(TRAILING '.' FROM country);


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Null values 
SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = "";

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry , t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company and t1.location = t2.location 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 as t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company and t1.location = t2.location 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL; 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove column row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2;
