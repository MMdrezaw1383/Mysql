-- Exploratory data analysis 

SELECT *
FROM layoffs_staging2;


SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


SELECT company , SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY company
ORDER BY laid_offs DESC;


SELECT industry , SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY industry
ORDER BY laid_offs DESC;


SELECT country , SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY country
ORDER BY laid_offs DESC;


SELECT YEAR(`date`) , SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT MIN(`date`), MAX(`date`) 
FROM layoffs_staging2;


SELECT SUBSTRING(`date`,1,7) AS `MONTH` ,SUM(total_laid_off) 
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1 ;


WITH Rolling_Total AS (
SELECT SUBSTRING(`date`,1,7) AS `MONTH` ,SUM(total_laid_off) AS laid_offs
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1 
) 
SELECT `MONTH` , laid_offs, SUM(laid_offs) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


SELECT company , YEAR(`date`) AS Year,  SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY company , Year
ORDER BY 3 DESC;


WITH Company_cte AS(
SELECT company , YEAR(`date`) AS Year,  SUM(total_laid_off) as laid_offs
FROM layoffs_staging2
GROUP BY company , Year
), Company_year_rank AS (
SELECT company,
DENSE_RANK() OVER(PARTITION BY Year ORDER BY laid_offs DESC) AS Ranking
FROM Company_cte
WHERE Year AND laid_offs IS NOT NULL)
SELECT * FROM Company_year_rank
WHERE Ranking <= 5;



