-- Proyecto SQL 
-- Limpieza de datos

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

CREATE DATABASE layoffs_world;

SELECT * FROM layoffs;

-- LIMPIEZA DE LA BASE DE DATOS

--  Entender de que se trata la base de datos, cuales son sus columnas, sus tipos de datos y crear una segunda tabla con los mismos datos sin procesar.

DESCRIBE layoffs;

SELECT * FROM layoffs LIMIT 10;

SELECT COUNT(*) FROM layoffs; -- 2361 registros

CREATE TABLE layoffs_staging
LIKE layoffs; -- ACÁ la estructura de la tabla de backup

INSERT layoffs_staging
SELECT *
FROM layoffs; -- Se insertan los mismos datos


-- Cuando estamos haciendo una limpieza de datos, se deben seguir una serie de pasos:
-- 1. Verificar la existencia de duplicados y eliminarlos
-- 2. Estandarizar los datos y corregir errores
-- 3. Ver los valores nulos y su tratamiento
-- 4. Eliminar columnas y registros que no son necesiarios para el posterior análisis


-- 1. DUPLICADOS

# Chequeamos si existen duplicados 

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs;


WITH duplicate_cte AS(
	SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Para poder eliminarlo
-- 1 Creamos una tabla con la misma estructura y agregamos la columnna row_num
CREATE TABLE `layoffs2` (
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

-- Insertamos los datos con la columna agregada row_num(que es la que necesitamos para poder eliminar los duplicados)
INSERT INTO layoffs2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs;

-- Eliminamos los registros duplicados
DELETE 
FROM layoffs2
WHERE row_num > 1; 

-- Corroboramos que esten eliminados
SELECT * 
FROM layoffs2
WHERE row_num > 1; 



-- 2. Estandarización de los datos

SELECT * FROM layoffs2;

-- Sacamos los espacios en blanco de la columnna company
UPDATE layoffs2
SET company = TRIM(company); -- Recorta los espacios en blaco tanto a la derecha como a la izquierda 

-- Estandarizamos el nombre de la industria de las criptomonedas, ya que aparecen con 3 nombres distintos y de la columna country 

SELECT *
FROM layoffs2
WHERE industry LIKE 'Crypto%'; -- Como hay 3 industries llamadas "Crypto" vamos a actualizar a que tengan el mismo nombre 

UPDATE layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT distinct(country)
FROM layoffs2
ORDER BY 1;

UPDATE layoffs2
SET country = 'United States'
WHERE country LIKE 'United States%';

UPDATE layoffs2
SET location = 'Washington D.C'
WHERE location LIKE 'Washington D.C%';

UPDATE layoffs2
SET location = 'Non-U.S'
WHERE location LIKE 'Non-U.S%';

UPDATE layoffs2
SET company = 'E Inc'
WHERE company LIKE 'E Inc%';


-- Cambiar el tipo de dato de la columna 'date' y además, cambiar su formato.

SELECT  `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs2;

UPDATE layoffs2
SET `date` = str_to_date(`date`, '%m/%d/%Y'); -- Cambiamos el formato de la columnna 

ALTER TABLE layoffs2
MODIFY COLUMN  `date` DATE; -- Cambiamos el tipo de dato

--  Tratar los caracteres especiales --->  columna location= 'MalmÃ¶''FlorianÃ³polis'


UPDATE layoffs2
SET location = 'Malmö'
WHERE location = 'MalmÃ¶';

UPDATE layoffs2
SET location = 'Florianópolis'
WHERE location = 'FlorianÃ³polis';


-- 4- Valores nulos y en blanco

select * from layoffs2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

select * from layoffs2 WHERE company = 'Airbnb';    

select * from layoffs2 WHERE company = 'Carvana'; 

select * from layoffs2 WHERE company = 'Juul'; 


UPDATE layoffs2
SET industry = 'Consumer'
WHERE industry = '' AND company = 'Juul';

UPDATE layoffs2
SET industry = 'Transportation'
WHERE industry = '' AND company = 'Carvana';

UPDATE layoffs2
SET industry = 'Travel'
WHERE industry = '' AND company = 'Airbnb';


-- Estos registros se cree que no tienen una información completa y útil , por eso se procede a eliminarlos
select  COUNT(*)
from layoffs2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; -- 361

DELETE 
from layoffs2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


-- 5. Eliminar columnas 
-- Eliminamos las columnnas que no vamos a necesitar para nuestro análisis

ALTER TABLE layoffs2
DROP COLUMN row_num;

