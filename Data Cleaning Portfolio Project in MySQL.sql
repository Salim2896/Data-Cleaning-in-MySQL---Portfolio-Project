-- Data Cleaning In MySQL Portfolio Project --

-- select database(); (to see which schema you are currently using)
-- use database_name (world_layoffs); (to use the database you want)

select *
from world_layoffs.layoffs ;

-- Step 1 . Remove Duplicates
-- Step 2 . Standardize the Data
-- Step 3 . Null Values or Blank Values 
-- Step 4 . Remove Any Irrelevant Columns or rows


-- Step 1 . Remove Duplicates

create table layoffs_staging
like world_layoffs.layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

select *,
row_number() over(
	partition by company,location, industry, total_laid_off, percentage_laid_off, `date`,
    stage, country,funds_raised_millions) as row_num
from layoffs_staging;

with duplicate_cte as 
(
select *,
row_number() over(
	partition by company,location, industry, total_laid_off, percentage_laid_off, `date`,
    stage, country,funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;


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

select *
from layoffs_staging2
where row_num > 1;

insert into layoffs_staging2
select *,
row_number() over(
	partition by company,location, industry, total_laid_off, percentage_laid_off, `date`,
    stage, country,funds_raised_millions) as row_num
from layoffs_staging ;



DELETE
FROM layoffs_staging2
WHERE row_num > 1;


select *
from layoffs_staging2;

-- Step 2 . Standardize the Data;

Select company, (trim(company))
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

Select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select  distinct country , trim(Trailing '.' from country)
from layoffs_staging2
order by 1;

update  layoffs_staging2
set country = trim(Trailing '.' from country)
where country like 'United States%';

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

Alter table layoffs_staging2
modify column `date` date;


 -- Step 3 . Null Values or Blank Values 

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null 
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select *
from layoffs_staging2
where company  like 'bally%';

select t1.industry, t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	 on t1.company = t2.company
     and t1.location = t2.location
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null;

update layoffs_staging2 as t1 
join layoffs_staging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry
where  t1.industry is null 
and t2.industry is not null;


-- Step 4 . Remove Any Irrelevant Columns or rows

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;























