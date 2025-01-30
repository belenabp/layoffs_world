-- Análisis de los datos


select MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs2; -- 12.000 despidos y 100%

#Que compañías tienen el 1, es basicamente el 100% 
select *
from layoffs2
where percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off) AS total
FROM layoffs2
GROUP BY  company
ORDER BY total DESC;

SELECT industry, SUM(total_laid_off) AS total
FROM layoffs2
GROUP BY industry
ORDER BY total DESC;

SELECT country, SUM(total_laid_off) AS total
FROM layoffs2
GROUP BY country
ORDER BY total DESC;

-- Cual es la fecha mínima y máxima del dataset
SELECT MIN(`date`) AS min_date, MAX(`date`) AS max_date
FROM layoffs2;

SELECT YEAR(`date`)as year_date, SUM(total_laid_off) AS total
FROM layoffs2
GROUP BY year_date
ORDER BY 1 DESC;

-- Sacar el acumulado de la suma de los despidos por meses
SELECT substring(`date`, 6, 2) AS `Month`, SUM(total_laid_off) AS sum_total
FROM layoffs2
GROUP BY `Month`
ORDER BY `Month` ASC;

SELECT substring(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS sum_total
FROM layoffs2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ASC;


WITH Rolling_Total AS(
	SELECT substring(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS sum_total
	FROM layoffs2
	WHERE substring(`date`, 1, 7) IS NOT NULL
	GROUP BY `Month`
	ORDER BY `Month` ASC
)
SELECT  `Month`, sum_total,
SUM(sum_total) OVER(ORDER BY  `Month`) AS total_acumulado
FROM Rolling_Total;

-- Hacer un Ranking de las 5 compañías con mas despidos en relación a los años.

SELECT company, YEAR(`date`) AS year_total, SUM(total_laid_off) AS total
FROM layoffs2
GROUP BY  company, year_total
ORDER BY 3 DESC;


WITH Company_Year AS(
SELECT company, YEAR(`date`) AS year_total, SUM(total_laid_off) AS total
FROM layoffs2
GROUP BY  company, year_total
),
Company_Year_Rank AS (
	SELECT *,
    DENSE_RANK() OVER(PARTITION BY year_total ORDER BY total DESC) AS Ranking
	FROM Company_Year
	WHERE year_total IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

