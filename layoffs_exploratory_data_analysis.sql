-- =============================================
-- EXPLORATORY DATA ANALYSIS (EDA): WORLD LAYOFFS
-- =============================================

-- 1. Initial Data Overview
SELECT * 
FROM layoffs_staging2;

-- 2. Total Layoffs by Country (Highest to Lowest)
SELECT 
    country, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country 
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY total_layoffs DESC;

-- 3. Total Layoffs by Industry (Highest to Lowest)
SELECT 
    industry, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry 
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY total_layoffs DESC;

-- 4. Overall Timeline of the Data (Date Range)
SELECT 
    MIN(`date`) AS starting_date,
    MAX(`date`) AS ending_date
FROM layoffs_staging2;

-- 5. Country with the Single Largest Layoff Event in a Single Day
SELECT 
    country,
    MAX(total_laid_off) AS max_single_layoff
FROM layoffs_staging2
GROUP BY country
HAVING MAX(total_laid_off) IS NOT NULL
ORDER BY max_single_layoff DESC
LIMIT 1;

-- 6. Industry with the Single Largest Layoff Event in a Single Day
SELECT 
    industry,
    MAX(total_laid_off) AS max_single_layoff
FROM layoffs_staging2
GROUP BY industry
HAVING MAX(total_laid_off) IS NOT NULL
ORDER BY max_single_layoff DESC
LIMIT 1;

-- 7. Total Number of Layoffs per Year
SELECT 
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY layoff_year DESC;

-- 8. Total Number of Layoffs per Month and Year
SELECT 
    SUBSTRING(`date`, 1, 7) AS month_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY month_year
ORDER BY month_year ASC;

-- 9. Monthly Rolling Total (Cumulative Sum) of Layoffs Over Time
WITH Rolling_Total AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) AS month_year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY month_year
)
SELECT 
    month_year, 
    total_layoffs,
    SUM(total_layoffs) OVER (ORDER BY month_year ASC) AS cumulative_total
FROM Rolling_Total;

-- 10. Top 5 Companies with the Highest Layoffs for Each Individual Year
WITH Company_Year AS (
    SELECT 
        company,
        YEAR(`date`) AS layoff_year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),
Ranking_By_Year AS (
    SELECT 
        company,
        layoff_year,
        total_layoffs,
        DENSE_RANK() OVER (PARTITION BY layoff_year ORDER BY total_layoffs DESC) AS ranking
    FROM Company_Year
    WHERE layoff_year IS NOT NULL
)
SELECT 
    company,
    layoff_year,
    total_layoffs,
    ranking
FROM Ranking_By_Year
WHERE ranking <= 5;