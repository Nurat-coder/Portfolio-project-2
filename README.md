# Bank Term Deposit Subscription Analysis

This project is a SQL-based analysis of a marketing dataset for a Portuguese bank, which aims to understand the behavior of clients towards subscribing to term deposits. The dataset contains details of 4,521 marketing campaigns.

## Table of Contents

- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [Data Cleaning](#data-cleaning)
- [Insights](#insights)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [Tools Used](#tools-used)



## Project Overview
The project investigates client data to uncover factors that contribute to term deposit subscription. It makes use of MySQL to perform analysis on demographics, financial status, contact methods, and previous campaign outcomes. By answering key business questions, the insights gained help optimize marketing strategies and improve subscription rates.

## Objectives

The aim of the project is to answer the following business questions using SQL:

1) What is the overall conversion rate (subscribed vs. not subscribed)?

2) Which job category has the highest term deposit subscription rate?

3) How does subscription rate vary by education level and marital status?

4) Which contact method (cellular or telephone) is more effective?

5) Which month had the highest number of successful subscriptions?

6) What is the average call duration for successful vs unsuccessful outcomes?

7) Do clients with housing or personal loans subscribe more or less often?

8) What is the relationship between account balance and subscription?

9) Which age group has the highest subscription rate?

10) How many contacts were made per client, and how does that affect success?

## Data Cleaning

I replaced 'unknown' values in categorical columns (job, marital, education, contact, poutcome) with NULL to reflect missing data and I also removed duplicate value.

```sql
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
```
## Insights
## 1. What is the overall conversion rate (subscribed vs. not subscribed)?
```sql
SELECT
  COUNT(*) AS total_contacted,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS conversion_rate_percent
FROM bank2;
```
Insight: The conversion rate (yes) is about 11.5%, while the majority did not subscribe.

## 2. Which job category has the highest term deposit subscription rate?
```sql
SELECT job,
       COUNT(*) AS total_clients,
       SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS subscribed_clients,
       ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank
WHERE job IS NOT NULL
GROUP BY job
ORDER BY subscription_rate_percent DESC;
```
Insight: The retired clients have the highest subscription rate among all job categories.

## 3. How does subscription rate vary by education level and marital status?
```sql
SELECT 
  education,
  marital,
  COUNT(*) AS total_people,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY education, marital
ORDER BY subscription_rate_percent DESC;
```
Insight:Individuals with primary education and divorced status have higher subscription rates.

## 4. Which contact method (cellular or telephone) is more effective?
```sql
SELECT 
  contact,
  COUNT(*) AS total_contacts,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY contact
ORDER BY subscription_rate_percent DESC;
```
Insight:Telephone contact method yields a better success rate than cellular.

## 5. Which month had the highest number of successful subscriptions?
```sql
SELECT 
  month,
  COUNT(*) AS total_subscriptions
FROM bank2
WHERE y = 'yes'
GROUP BY month
ORDER BY total_subscriptions DESC;
```
Insights:May had the highest number of successful subscriptions.

## 6. What is the average call duration for successful vs unsuccessful outcomes?
```
SELECT 
  y AS subscription_outcome,
  COUNT(*) AS total_calls,
  ROUND(AVG(duration), 2) AS avg_call_duration_seconds
FROM bank2
GROUP BY y;
```
Insights:Successful calls (yes) tend to have significantly longer durations of 552 minutes.

## 7. Do clients with housing or personal loans subscribe more or less often?
housing loan
```sql
SELECT 
  housing AS has_housing_loan,
  COUNT(*) AS total_clients,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY housing;
```
personal loans
```sql
SELECT 
  loan AS has_personal_loan,
  COUNT(*) AS total_clients,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY loan;
```
Insight:Clients without housing or personal loans subscribe more often.

## 8. What is the relationship between account balance and subscription?
```sql
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
```
Insight:Clients who subscribed had significantly higher balances between $1501 and $3000

## 9. Which age group has the subscription rate?
```sql
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
```
Insight:Clients under the age of 20 have the highest subscription rate.

## 10. How many contacts were made per client, and how does that affect success?
```sql
SELECT 
  campaign AS contacts_made,
  COUNT(*) AS total_clients,
  SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS total_subscribed,
  ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS subscription_rate_percent
FROM bank2
GROUP BY campaign
ORDER BY contacts_made ASC;
```
Insight:Most subscriptions happen within after contacting the client once. Too many contacts reduce success rates.

## Recommendations
The following actions should be taken to incresase subscription rate;
1. Focus marketing efforts on retired clients and those with higher education.

2. Use telephones phones instead of cellular for outreach.

3. Concentrate campaigns in May for higher conversions.

4. Prioritize clients without housing/personal loans.

5. Target individuals with higher balances and older age groups.

6. Limit campaign contact attempts to 2–3 to avoid diminishing returns.

## Limitations
The following limitations were encountered while using this dataset;
1. The dataset is historical and may not reflect current client behavior.

2. Missing data ('unknown') was replaced with NULL, which may lead to bias insights.

## Tools Used
1. MySQL for data cleaning and analysis

2. GitHub for documentation
