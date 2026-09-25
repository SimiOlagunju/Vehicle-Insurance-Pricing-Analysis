CREATE DATABASE InsurancePricing;
USE InsurancePricing;

CREATE TABLE pricing_data (
customer_id				INT,
    age                 INT,
    gender              VARCHAR(10),
    region              VARCHAR(50),
    vehicle_type        VARCHAR(20),
    policy_type         VARCHAR(20),
    tenure_years        FLOAT,
    base_price          FLOAT,
    discount_percent    FLOAT,
    final_price         FLOAT,
    competitor_price    FLOAT,
    price_difference    FLOAT,
    propensity_to_buy   FLOAT,
    churn_probability   FLOAT,
    claim_probability   FLOAT,
    purchased           INT,
    churned             INT,
    made_claim          INT,
    claim_cost          FLOAT,
    pricing_strategy    VARCHAR(20),
    discount_test_group VARCHAR(5),
    year                INT,
    month               INT,
    actual_revenue      FLOAT,
    forecast_revenue    FLOAT,
    variance            FLOAT
);


								   -- Data check & Validation
-- 1. Confirm row count
Select count(*) as total_rows 
From insurance_pricing_dataset;

-- 2. To check the data types
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'insurance_pricing_dataset'
ORDER BY ORDINAL_POSITION;

-- 3. To fix all incorrect data types permanently
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN customer_id INT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN tenure_years FLOAT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN discount_percent FLOAT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN propensity_to_buy FLOAT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN purchased INT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN churned INT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN made_claim INT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN claim_cost FLOAT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN month INT;
ALTER TABLE insurance_pricing_dataset
ALTER COLUMN actual_revenue FLOAT;

-- 4. To check for missing values / NULL (empty) values in key columns
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN final_price IS NULL THEN 1 ELSE 0 END) AS missing_final_price,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region
FROM insurance_pricing_dataset;

-- 5. Check for duplicates
SELECT customer_id, COUNT(*) AS occurrences
FROM insurance_pricing_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 6. Check reasonable value ranges
SELECT 
    MIN(age) AS youngest,
    MAX(age) AS oldest,
    MIN(final_price) AS lowest_price,
    MAX(final_price) AS highest_price
FROM insurance_pricing_dataset;

-- Revenue Overview
SELECT
    COUNT(*) AS total_customers,
    CAST(ROUND(SUM(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
    CAST(ROUND(AVG(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_revenue_per_customer
FROM insurance_pricing_dataset;

							--Business Question 1: Who Is Our Typical Customer?

-- Customer Age Groups
-- Q1: How are our customers distributed across age groups?
SELECT 
    age_group,
    COUNT(*) AS total_customers,
    CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)  AS DECIMAL(5,2)) AS percentage
FROM (
    SELECT 
        CASE 
            WHEN age BETWEEN 18 AND 30 THEN '18-30'					--label every customer with an age group
            WHEN age BETWEEN 31 AND 45 THEN '31-45'
            WHEN age BETWEEN 46 AND 60 THEN '46-60'
            WHEN age BETWEEN 61 AND 79 THEN '61-79'
        END AS age_group
    FROM insurance_pricing_dataset
) AS age_labels
GROUP BY age_group													-- group and count the labels
ORDER BY age_group asc;

-- Customer Gender
-- Q2: How many of our customers are Male vs Female and what percentage does each represent?
SELECT 
	gender, 
	count(*) as total_customers,
	CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS DECIMAL(5,2)) AS percentage
FROM insurance_pricing_dataset
GROUP BY gender
ORDER BY total_customers DESC;

-- Regional Breakdown
-- Q3: Which regions across the UK have the most customers?
SELECT 
	region, 
	count(*) as total_customers,
	CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS DECIMAL(5,2)) AS percentage
FROM insurance_pricing_dataset
GROUP BY region
ORDER BY total_customers DESC;

-- Vehicle Type:
-- Q4A: Which vehicle types are most common?
SELECT 
	vehicle_type, 
	count(*) as total_customers,
	CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS DECIMAL(5,2)) AS percentage
FROM insurance_pricing_dataset
GROUP BY vehicle_type
ORDER BY total_customers DESC;

-- Policy Type:
-- Q4B: Which policy types are most common?
SELECT 
	policy_type, 
	count(*) as total_customers,
	CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS DECIMAL(5,2)) AS percentage
FROM insurance_pricing_dataset
GROUP BY policy_type
ORDER BY total_customers DESC;



						--Business Question 2: Which pricing strategy earns the most revenue?
 -- Revenue by Pricing
 -- Q5: Which pricing strategy generates the most revenue?
 SELECT 
	pricing_strategy, 
	count(*) as total_customers,
	sum(purchased) as total_purchased,
	CAST(ROUND(sum(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
	CAST(ROUND(avg(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_revenue_per_customer,
	CAST(ROUND(sum(actual_revenue)* 100.0/sum(sum(actual_revenue)) over(), 2) AS DECIMAL(5,2)) AS revenue_percentage
FROM insurance_pricing_dataset
GROUP BY pricing_strategy
ORDER BY total_revenue DESC;

												
					   --Business Question 3: Which discount test group converts best?
-- Discount test group performance:
-- Q6: Which discount test group performed best? avg_discount_percent, purchased, discount_test_group, actual_revenue
 SELECT 
	discount_test_group, 
	count(*) as total_customers,
	sum(purchased) as total_purchased,
	CAST(ROUND(avg(discount_percent), 2) AS DECIMAL(18,2)) AS avg_discount_given,
	CAST(ROUND(sum(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
	CAST(ROUND(avg(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_revenue_per_customer,
	CAST(ROUND(sum(purchased)* 100.0/count(*), 2) AS DECIMAL(5,2)) AS conversion_rate
FROM insurance_pricing_dataset
GROUP BY discount_test_group
ORDER BY total_revenue DESC;



						--Business Question 4: Who is most at risk of churning?
--Churn by region
-- Q7A: Which regions have the highest churn rate?
SELECT 
	region, 
	count(*) as total_customers,
	sum(churned) as total_churned,
	CAST(ROUND(avg(churn_probability) * 100, 2) AS DECIMAL(5,2)) AS avg_churn_probability,
	CAST(ROUND(sum(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
	CAST(ROUND(sum(churned)* 100.0/count(*), 2) AS DECIMAL(5,2)) AS churned_rate
FROM insurance_pricing_dataset
GROUP BY region
ORDER BY churned_rate DESC;

--Churn by Age group
-- Q7B: Which age group has the highest churn rate?
SELECT 
	age_group, 
	count(*) as total_customers,
	sum(churned) as total_churned,
	count(*) - sum(churned) as total_customers_stayed,
	CAST(ROUND(avg(churn_probability) * 100, 2) AS DECIMAL(5,2)) AS avg_churn_probability,
	CAST(ROUND(sum(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
	CAST(ROUND(avg(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_revenue_per_customer,
	CAST(ROUND(sum(churned)* 100.0/count(*), 2) AS DECIMAL(5,2)) AS churned_rate
FROM (
SELECT 
        churned,
        churn_probability,
        actual_revenue,
        CASE 
            WHEN age BETWEEN 18 AND 30 THEN '18-30'
            WHEN age BETWEEN 31 AND 45 THEN '31-45'
            WHEN age BETWEEN 46 AND 60 THEN '46-60'
            WHEN age BETWEEN 61 AND 79 THEN '61-79'
        END AS age_group
FROM insurance_pricing_dataset
) as age_labels
GROUP BY age_group
ORDER BY churned_rate DESC;


--Churn By Policy Type And Pricing Strategy
--Query 7C - Does churn rate change depending on which pricing strategy is used for each policy type?"
SELECT 
	policy_type,
	pricing_strategy,
    count(*) as total_customers,
	sum(churned) as total_churned,
	cast(round(sum(churned) * 100.0 / count(*), 2) AS DECIMAL(5,2)) AS churned_rate
	from insurance_pricing_dataset
	group by policy_type, pricing_strategy
	order by policy_type ASC, pricing_strategy ASC;


								--Business Question 5: What are claims costing the business?
--Which vehicle type costs the company the most in claims?
--Query 8 - Vehicle type with the most claims
SELECT 
    vehicle_type,
    COUNT(*) AS total_customers,
	SUM(made_claim) AS total_claims_made,
	SUM(claim_cost) AS total_claim_cost,
    CAST(ROUND(AVG(claim_cost), 2) AS DECIMAL(10,2)) AS avg_claim_cost,
    CAST(ROUND(SUM(made_claim) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS claim_rate,
	CAST(ROUND(AVG(claim_probability) * 100, 2) AS DECIMAL(5,2)) AS avg_predicted_claim_rate
FROM insurance_pricing_dataset
GROUP BY vehicle_type
ORDER BY claim_rate DESC;

--Which policy type costs the company the most in claims?
--Query 8B - policy type with the most claims
SELECT 
    policy_type,
    COUNT(*) AS total_customers,
	SUM(made_claim) AS total_claims_made,
	SUM(claim_cost) AS total_claim_cost,
    CAST(ROUND(AVG(claim_cost), 2) AS DECIMAL(10,2)) AS avg_claim_cost,
    CAST(ROUND(SUM(made_claim) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS claim_rate,
	CAST(ROUND(AVG(claim_probability) * 100, 2) AS DECIMAL(5,2)) AS avg_predicted_claim_rate
FROM insurance_pricing_dataset
GROUP BY policy_type
ORDER BY claim_rate DESC;



						--Business Question 6: How is revenue tracking VS forecast?
--Revenue tracking VS forecast?
--Query 9A - How is actual revenue tracking against forecast revenue year by year?
SELECT 
    year,
    count(*) AS total_customers,
	cast(round(sum(actual_revenue), 2) as decimal(18,2)) as total_actual_revenue,
	cast(round(sum(forecast_revenue), 2) as decimal(10,2)) as total_forecast_revenue,
	cast(round(sum(actual_revenue) - sum(forecast_revenue), 2) AS DECIMAL(18,2)) AS total_variance,
	cast(round(avg(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_actual_revenue,
	cast(round(avg(forecast_revenue), 2) AS DECIMAL(10,2)) AS avg_forecast_revenue,
	cast(round((sum(actual_revenue) - sum(forecast_revenue)) / NULLIF(sum(forecast_revenue),0) * 100, 2) AS DECIMAL(10,2)) AS variance_percentage
FROM insurance_pricing_dataset
where purchased = 1
GROUP BY year
ORDER BY year ASC;


--Query 9B - How is actual revenue tracking against forecast revenue month each year?
SELECT 
    month, year,
    count(*) AS total_customers,
	cast(round(sum(actual_revenue), 2) as decimal(18,2)) as total_actual_revenue,
	cast(round(sum(forecast_revenue), 2) as decimal(10,2)) as total_forecast_revenue,
	cast(round(sum(actual_revenue) - sum(forecast_revenue), 2) AS DECIMAL(18,2)) AS total_variance,
	cast(round(avg(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_actual_revenue,
	cast(round(avg(forecast_revenue), 2) AS DECIMAL(10,2)) AS avg_forecast_revenue,
	cast(round((sum(actual_revenue) - sum(forecast_revenue)) / NULLIF(sum(forecast_revenue),0) * 100, 2) AS DECIMAL(10,2)) AS variance_percentage
FROM insurance_pricing_dataset
where purchased = 1
GROUP BY month, year
ORDER BY month ASC, Year ASC;


EXEC sp_rename 'insurance_pricing_dataset', 'insurance_pricing_dataset';
SELECT TOP 5 * FROM insurance_pricing_dataset;
