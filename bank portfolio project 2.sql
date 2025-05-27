create database bank;
use bank;
select * from bank;

-- ---------------------------------------------------------Creating a backup for your data ------------------------------------------------------------------------------------
CREATE TABLE `bank2` (
  `age` int DEFAULT NULL,
  `job` text,
  `marital` text,
  `education` text,
  `default` text,
  `balance` int DEFAULT NULL,
  `housing` text,
  `loan` text,
  `contact` text,
  `day` int DEFAULT NULL,
  `month` text,
  `duration` int DEFAULT NULL,
  `campaign` int DEFAULT NULL,
  `pdays` int DEFAULT NULL,
  `previous` int DEFAULT NULL,
  `poutcome` text,
  `y` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from bank2;

insert into bank2
select *
from bank;

select * from bank2;

-- ----------------------------------------------------------Data Cleaning ----------------------------------------------------------------------------------------------------
Select COUNT(*) 
from bank2 
where job = 'unknown';
-- 38 rows of unknown

Select COUNT(*) 
from bank2 
where education = 'unknown';
-- 187 rows of unknown

Select COUNT(*) 
from bank2 
where contact = 'unknown';
-- 1324 rows of unknown

Select COUNT(*) 
from bank2 
where poutcome = 'unknown';
-- 3705 rows of unknown

Update bank2 
set job = NULL 
where job = 'unknown';

update bank2 
set education = NULL 
where education = 'unknown';

update bank2 
set contact = NULL 
where contact = 'unknown';

update bank2
set poutcome = NULL 
where poutcome = 'unknown';

select * from bank2;

alter table bank2 
add column id int auto_increment primary key;

select * from bank;

SELECT age, job, marital, education, `default`, balance, housing, loan, contact,
       day, month, duration, campaign, pdays, previous, poutcome, y,
       COUNT(*) AS occurrences
FROM bank2
GROUP BY age, job, marital, education, `default`, balance, housing, loan, contact,
         day, month, duration, campaign, pdays, previous, poutcome, y
HAVING COUNT(*) > 1;

DELETE FROM bank2
WHERE id NOT IN (
  SELECT * FROM (
    SELECT MIN(id)
    FROM bank2
    GROUP BY age, job, marital, education, `default`, balance, housing, loan, contact,
             day, month, duration, campaign, pdays, previous, poutcome, y
  ) AS keep_ids
);
select * from bank2;

alter table bank2 drop column id;

select * from bank2;

-- --------------------------------------------Data Analysis---------------------------------------------------------------------------------------------------------------
-- what is the overall conversion rate?
SELECT
  COUNT(*) AS total_contacted,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS conversion_rate_percent
FROM bank2;

-- Which job category has the highest term deposit subscription rate?
SELECT job,
       COUNT(*) AS total_clients,
       SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed_clients,
       ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank
WHERE job IS NOT NULL
GROUP BY job
ORDER BY subscription_rate_percent DESC;
-- LIMIT 1;

-- ---------------------------------------------------How does subscription rate vary by education level and marital status?---------------------------------------------------
SELECT 
  education,
  marital,
  COUNT(*) AS total_people,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY education, marital
ORDER BY subscription_rate_percent DESC;

-- select distinct education
-- from bank2;
-- ---Which contact method (cellular or telephone) is more effective?
SELECT 
  contact,
  COUNT(*) AS total_contacts,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY contact
ORDER BY subscription_rate_percent DESC;

-- --Which month had the highest number of successful subscriptions?
SELECT 
  month,
  COUNT(*) AS total_subscriptions
FROM bank2
WHERE y = 'yes'
GROUP BY month
ORDER BY total_subscriptions DESC;

-- --What is the average call duration for successful vs unsuccessful outcomes?
SELECT 
  y AS subscription_outcome,
  COUNT(*) AS total_calls,
  ROUND(AVG(duration), 2) AS avg_call_duration_seconds
FROM bank2
GROUP BY y;

-- --Do clients with housing or personal loans subscribe more or less often?
-- housing loan
SELECT 
  housing AS has_housing_loan,
  COUNT(*) AS total_clients,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY housing;
-- personal loans
SELECT 
  loan AS has_personal_loan,
  COUNT(*) AS total_clients,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY loan;

-- -----What is the relationship between account balance and subscription?
SELECT 
  CASE
    WHEN balance < 0 THEN 'Negative'
    WHEN balance BETWEEN 0 AND 500 THEN 'Low (0-500)'
    WHEN balance BETWEEN 501 AND 1500 THEN 'Medium (501-1500)'
    WHEN balance BETWEEN 1501 AND 3000 THEN 'High (1501-3000)'
    ELSE 'Very High (>3000)'
  END AS balance_range,
  COUNT(*) AS total_people,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY balance_range
ORDER BY subscription_rate_percent DESC;

-- ---which age group has the subscription rate?
SELECT 
  CASE
    WHEN age < 20 THEN 'Under 20'
    WHEN age BETWEEN 20 AND 29 THEN '20-29'
    WHEN age BETWEEN 30 AND 39 THEN '30-39'
    WHEN age BETWEEN 40 AND 49 THEN '40-49'
    WHEN age BETWEEN 50 AND 59 THEN '50-59'
    WHEN age BETWEEN 60 AND 69 THEN '60-69'
    ELSE '70+'
  END AS age_group,
  COUNT(*) AS total_people,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank
GROUP BY age_group
ORDER BY subscription_rate_percent DESC;

-- ---How many contacts were made per client, and how does that affect success?
SELECT 
  campaign AS contacts_made,
  COUNT(*) AS total_clients,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY campaign
ORDER BY contacts_made ASC;

