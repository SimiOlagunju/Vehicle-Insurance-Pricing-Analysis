# Vehicle Insurance Pricing Analysis
SQL + Power BI Project | Pricing Strategy, Churn Analysis, Claims Intelligence & Revenue Forecasting

### Table of Contents
* [Project Overview](#project-overview)
* [Tools Used](#tools-used)
* [Dataset Overview](#dataset-overview)
* [Data Cleaning & Validation](#data-cleaning--validation)
* [Exploratory Analysis](#exploratory-analysis)
* [Power BI Dashboard](#power-bi-dashboard)
* [Key Metrics](#key-metrics)
* [Key Insights](#key-insights)
* [Recommendations](#recommendations)
* [Dataset Source](#dataset-source)

---

### Project Overview
This project analyses vehicle insurance pricing and customer behaviour data for a fictional UK-based insurance company to uncover pricing strategy performance, customer churn patterns, claims costs and revenue forecast accuracy.

> The goal is to:
> - Understand who the typical customer is across age, gender, region, vehicle type and policy type
> - Evaluate which pricing strategy and discount test group generates the most revenue and converts best
> - Identify which customer segments are most at risk of churning and quantify the revenue impact
> - Analyse claims costs by vehicle type, policy type and region to assess profitability risk
> - Compare actual revenue against forecast targets to evaluate business forecasting accuracy

---

### Tools Used
- **Microsoft SQL Server (SSMS)** — Data validation, cleaning and exploratory analysis
- **Power BI Desktop** — Data modelling, DAX measure development and interactive dashboard

---

### Dataset Overview
The dataset contains vehicle insurance pricing and customer behaviour data for a UK insurance company spanning 4 years (2022–2025).

> - Customer demographics (age, gender, region)
> - Policy information (vehicle type, policy type, tenure)
> - Pricing data (base price, discount, final price, competitor price)
> - Behavioural predictions (propensity to buy, churn probability, claim probability)
> - Business outcomes (purchased, churned, made claim, claim cost)
> - Revenue tracking (actual revenue, forecast revenue, variance)

- **Total Records:** 28,712 rows
- **Total Columns:** 26
- **Time Period:** 2022 – 2025
- **UK Regions Covered:** 12
- **Vehicle Types:** Car, Van, Motorbike
- **Policy Types:** Basic, Standard, Premium
- **Pricing Strategies:** Aggressive, Conservative, Balanced
- **Discount Test Groups:** A, B, C

**Dataset Sample Preview**

| customer_id | age | gender | region | vehicle_type | policy_type | final_price | pricing_strategy | purchased | churned | made_claim |
|-------------|-----|--------|--------|-------------|-------------|-------------|-----------------|-----------|---------|------------|
| 1001 | 34 | Male | London | Car | Premium | £112.50 | Balanced | 1 | 0 | 0 |
| 1002 | 67 | Female | Scotland | Van | Basic | £89.20 | Aggressive | 1 | 1 | 1 |
| 1003 | 22 | Male | Wales | Motorbike | Standard | £95.75 | Conservative | 0 | 0 | 0 |

---

### Data Cleaning & Validation
All data cleaning and validation was performed in **Microsoft SQL Server (SSMS)** before connecting to Power BI.

**Step 1 — Row Count Verification**
```sql
SELECT COUNT(*) AS total_rows 
FROM insurance_pricing_dataset;
-- Result: 28,712 rows confirmed
```

**Step 2 — Data Type Validation & Correction**

Several columns were incorrectly imported as nvarchar (text) instead of numeric types and were corrected:
```sql
ALTER TABLE insurance_pricing_dataset ALTER COLUMN purchased INT;
ALTER TABLE insurance_pricing_dataset ALTER COLUMN churned INT;
ALTER TABLE insurance_pricing_dataset ALTER COLUMN made_claim INT;
ALTER TABLE insurance_pricing_dataset ALTER COLUMN claim_cost FLOAT;
ALTER TABLE insurance_pricing_dataset ALTER COLUMN actual_revenue FLOAT;
ALTER TABLE insurance_pricing_dataset ALTER COLUMN month INT;
-- Plus 4 additional columns corrected
```

**Step 3 — NULL Value Check**
```sql
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN final_price IS NULL THEN 1 ELSE 0 END) AS missing_final_price,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region
FROM insurance_pricing_dataset;
-- Result: 0 NULL values across all key columns
```

**Step 4 — Duplicate Check**
```sql
SELECT customer_id, COUNT(*) AS occurrences
FROM insurance_pricing_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Result: No duplicates found
```

**Step 5 — Value Range Validation**
```sql
SELECT 
    MIN(age) AS youngest, MAX(age) AS oldest,
    MIN(final_price) AS lowest_price, MAX(final_price) AS highest_price
FROM insurance_pricing_dataset;
-- Result: Ages 18-79, Prices within expected range
```

**Additional transformations in Power BI using DAX:**
- Created **Age Band** calculated column grouping ages into: 18-30, 31-45, 46-60, 61-79
- Created **Tenure Band** calculated column grouping tenure into: <1 Year, 1-3 Years, 3-5 Years, 5-9 Years, 10+ Years
- Created **Price Position** calculated column: Much Cheaper, Cheaper, Slightly Pricier, Much Pricier
- Created **1 DAX Measures table** containing 15 measures organised by business area

---

### Exploratory Analysis
All exploratory analysis was first performed using **SQL queries in SSMS** to answer 6 core business questions, then visualised in Power BI.

**Business Question 1 — Who is our typical customer?**
```sql
-- Age group distribution
SELECT age_group, COUNT(*) AS total_customers,
    CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS DECIMAL(5,2)) AS percentage
FROM (
    SELECT CASE 
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 45 THEN '31-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        WHEN age BETWEEN 61 AND 79 THEN '61-79'
    END AS age_group
    FROM insurance_pricing_dataset
) AS age_labels
GROUP BY age_group ORDER BY age_group ASC;
```

**Business Question 2 — Which pricing strategy earns the most revenue?**
```sql
SELECT pricing_strategy, COUNT(*) AS total_customers,
    CAST(ROUND(SUM(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
    CAST(ROUND(AVG(actual_revenue), 2) AS DECIMAL(18,2)) AS avg_revenue_per_customer,
    CAST(ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS conversion_rate
FROM insurance_pricing_dataset
GROUP BY pricing_strategy ORDER BY total_revenue DESC;
```

**Business Question 3 — Which discount test group converts best?**
```sql
SELECT discount_test_group, COUNT(*) AS total_customers,
    CAST(ROUND(AVG(discount_percent), 2) AS DECIMAL(18,2)) AS avg_discount_given,
    CAST(ROUND(SUM(actual_revenue), 2) AS DECIMAL(18,2)) AS total_revenue,
    CAST(ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS conversion_rate
FROM insurance_pricing_dataset
GROUP BY discount_test_group ORDER BY total_revenue DESC;
```

**Business Question 4 — Who is most at risk of churning?**
```sql
-- Churn by region
SELECT region, COUNT(*) AS total_customers, SUM(churned) AS total_churned,
    CAST(ROUND(AVG(churn_probability) * 100, 2) AS DECIMAL(5,2)) AS avg_churn_probability,
    CAST(ROUND(SUM(churned) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS churn_rate
FROM insurance_pricing_dataset
GROUP BY region ORDER BY churn_rate DESC;
```

**Business Question 5 — What are claims costing the business?**
```sql
SELECT vehicle_type, COUNT(*) AS total_customers,
    SUM(made_claim) AS total_claims_made,
    CAST(ROUND(SUM(claim_cost), 2) AS DECIMAL(18,2)) AS total_claim_cost,
    CAST(ROUND(AVG(claim_cost), 2) AS DECIMAL(10,2)) AS avg_claim_cost,
    CAST(ROUND(SUM(made_claim) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS claim_rate
FROM insurance_pricing_dataset
GROUP BY vehicle_type ORDER BY claim_rate DESC;
```

**Business Question 6 — How is revenue tracking vs forecast?**
```sql
SELECT year, COUNT(*) AS total_customers,
    CAST(ROUND(SUM(actual_revenue), 2) AS DECIMAL(18,2)) AS total_actual_revenue,
    CAST(ROUND(SUM(forecast_revenue), 2) AS DECIMAL(18,2)) AS total_forecast_revenue,
    CAST(ROUND(SUM(actual_revenue) - SUM(forecast_revenue), 2) AS DECIMAL(18,2)) AS total_variance,
    CAST(ROUND((SUM(actual_revenue) - SUM(forecast_revenue)) / NULLIF(SUM(forecast_revenue), 0) * 100, 2) AS DECIMAL(10,2)) AS variance_percentage
FROM insurance_pricing_dataset
WHERE purchased = 1
GROUP BY year ORDER BY year ASC;
```

**Key DAX Measures Created:**
```
Total Actual Revenue = SUM(insurance_pricing_dataset[actual_revenue])
Total Forecast Revenue = SUM(insurance_pricing_dataset[forecast_revenue])
Total Claim Cost = SUM(insurance_pricing_dataset[claim_cost])
Revenue Variance = [Total Actual Revenue] - [Total Forecast Revenue]
Revenue Variance % = DIVIDE([Revenue Variance], [Total Forecast Revenue], 0) * 100
Net Margin = [Total Actual Revenue] - [Total Claim Cost]
Net Margin % = DIVIDE([Net Margin], [Total Actual Revenue], 0) * 100
Conversion Rate % = DIVIDE(SUM(purchased), COUNTROWS(insurance_pricing_dataset), 0) * 100
Churn Rate % = DIVIDE(SUM(churned), COUNTROWS(insurance_pricing_dataset), 0) * 100
Revenue At Risk = SUMX(table, final_price * churn_probability)
Claim Rate % = DIVIDE(SUM(made_claim), COUNTROWS(insurance_pricing_dataset), 0) * 100
Avg Churn Probability = AVERAGE(churn_probability) * 100
Avg Final Price = AVERAGE(final_price)
Avg Discount % = AVERAGE(discount_percent)
Claims to Revenue Ratio = DIVIDE([Total Claim Cost], [Total Actual Revenue], 0)
```

---

### Power BI Dashboard
The dashboard provides an interactive 5-page view of customer behaviour, pricing performance, churn analysis, claims intelligence and revenue forecasting.

**Dashboard Features**

> **KPI Cards:**
> - Total Actual Revenue
> - Total Customers
> - Avg Age
> - Conversion Rate %
> - Churn Rate %
> - Total Churned
> - Customers Retained
> - Avg Churn Probability
> - Total Claim Cost
> - Average Claim Cost
> - Claim Rate %
> - Claims to Revenue Ratio
> - Net Margin
> - Total Forecast Revenue
> - Revenue Variance
> - Revenue Variance %

> **Filters / Slicers:**
> - Year (2022, 2023, 2024, 2025)
> - Region (12 UK regions)
> - Age Distribution
> - Pricing Strategy
> - Vehicle Type

**Visuals — Page 1: Customer Overview**

<img width="988" height="555" alt="IP1" src="https://github.com/user-attachments/assets/a185fced-0883-4e46-ae77-d8482d7fdda5" />


1. Revenue by Year and Month (Area Chart)
2. Gender Split (Donut Chart)
3. Policy Type Distribution (Donut Chart)
4. Age Band Distribution (Donut Chart)
5. Vehicle Type Split (Bar Chart)
6. Tenure Band by Customer (Bar Chart)
7. Pricing Strategy by Customer (Bar Chart)
8. Discount Test Group by Customer (Bar Chart)

**Visuals — Page 2: Revenue & Pricing**

<img width="991" height="556" alt="IP2" src="https://github.com/user-attachments/assets/2af80b9f-1a96-4dad-8c26-8cf7e2fb063e" />


1. Revenue by Policy Type (Bar Chart)
2. Avg Discount by Test Group (Bar Chart)
3. Revenue by Month (Area Chart)
4. Conversion Rate by Pricing Strategy (Bar Chart)
5. Revenue by Pricing Strategy (Bar Chart)
6. Conversion Rate by Vehicle Type (Bar Chart)
7. Conversion Rate by Discount Group (Bar Chart)

**Visuals — Page 3: Churn Analysis**

<img width="990" height="551" alt="IP3" src="https://github.com/user-attachments/assets/b6dfd071-7fd0-4e22-960e-a654c2173f65" />


1. Churn Rate by Age Group (Bar Chart)
2. Churn Trend by Year (Area Chart)
3. Churn by Policy Type (Bar Chart)
4. Churn Rate by Region (Bar Chart)
5. Churn by Pricing Strategy (Bar Chart)
6. Revenue At Risk by Region (Bar Chart)

**Visuals — Page 4: Claims Analysis**

<img width="990" height="552" alt="IP4jpg" src="https://github.com/user-attachments/assets/941b80b2-282e-46ad-b1aa-e4967f97567b" />


1. Claims by Policy & Vehicle Type (Stacked Bar Chart)
2. Claim Rate by Policy & Vehicle Type (Clustered Bar Chart)
3. Claims Trend by Year (Area Chart)
4. Claim Rate by Region (Bar Chart)
5. Claims Cost by Policy & Vehicle Type (Stacked Bar Chart)

**Visuals — Page 5: Revenue vs Forecast**

<img width="994" height="555" alt="IP5jpg" src="https://github.com/user-attachments/assets/bd30caf4-e884-4b0a-add2-4298a9fc12c1" />


1. Actual vs Forecast Revenue by Pricing Strategy (Clustered Bar Chart)
2. Variance by Region (Bar Chart)
3. Revenue Variance by Year (Bar Chart)
4. Actual Revenue by Year (Bar Chart)
5. Total Actual vs Forecast Revenue by Year (Clustered Bar Chart)

---

### Key Metrics

| Metric | Value |
|--------|-------|
| Total Actual Revenue | £1,523,101 |
| Total Customers | 28,712 |
| Conversion Rate | 50.03% |
| Churn Rate | 40.05% |
| Total Churned | 11,498 |
| Total Claim Cost | £4,716,929 |
| Claim Rate | 29.81% |
| Average Claim Cost | £551 |
| Claims to Revenue Ratio | 3.10x |
| Net Margin | -£3,193,829 |
| Revenue Variance | -£286 |
| Revenue Variance % | -0.02% |
| Avg Discount % | 14.98% |
| Avg Final Price | £106.19 |

---

### Key Insights

**1. The business is highly unprofitable at the claims level**
- The company collects £1.52M in revenue but pays out £4.72M in claims — a claims to revenue ratio of 3.10x. For every £1 collected the company pays out £3.10 in claims. This makes accurate pricing and risk assessment critical to the company's survival.

**2. 2023 was the most challenging year across every metric**
- Claims costs peaked at £1.24M, churn rate spiked to 40.6% and revenue missed forecast by £584 — all in the same year. The business recovered strongly in 2024 with peak revenue of £389,902 and improving claims costs — suggesting management interventions in late 2023 were effective.

**3. Pricing strategy has minimal impact on revenue but significant impact on conversion**
- All three pricing strategies generate similar total revenue (within £17,000 of each other) but Aggressive strategy achieves the highest conversion rate at 50.3% while Conservative achieves the lowest at 49.6%. This suggests price sensitivity among customers — lower prices convert better without significantly improving total revenue.

**4. Discount test groups receive identical discounts but perform differently**
- Groups A, B and C all receive approximately 15% average discount yet Group A achieves the highest conversion rate at 51% and the highest total revenue at £511,267. This suggests customer characteristics — not discount level — are the primary driver of conversion performance.

**5. Churn is a company-wide problem not a segment specific one**
- Churn rate sits between 39% and 42% across all regions, age groups and policy types — a spread of only 3 percentage points. Scotland has the highest churn at 42% and East Midlands the lowest at 39%. The consistency suggests systemic issues such as pricing competitiveness or service quality rather than segment specific problems.

**6. Basic policy holders generate the highest claims cost despite lowest coverage**
- Basic policies — which offer the least coverage — generate the highest total claim cost at £1.59M compared to Premium at £1.58M and Standard at £1.55M. This counterintuitive finding suggests Basic policy customers may be inherently higher risk individuals who chose the cheapest option available.

**7. Revenue forecasting is exceptionally accurate**
- Across all 4 years the company missed its revenue forecast by just £286 — a variance of only 0.02%. No single month deviated more than 0.70% from forecast. This demonstrates exceptional financial planning and forecast modelling capability.

**8. North East region has the highest claim rate**
- North East customers claim at 31.19% — the highest of all 12 regions — compared to East Midlands at the lowest 28.83%. This regional claims variation should inform region-specific pricing adjustments.

---

### Recommendations

**1. Urgently review pricing relative to claims risk**
- A 3.10x claims to revenue ratio is unsustainable long term. The company should conduct an actuarial review to ensure premiums reflect true claims risk — particularly for Basic policy holders who generate the highest claims cost despite lowest coverage.

**2. Invest in churn retention strategies**
- With 40% of customers churning annually the business is losing significant future revenue. Targeted retention campaigns for Scotland and Northern Ireland — the highest churning regions — should be prioritised. Even a 5% reduction in churn would retain approximately 575 additional customers annually.

**3. Investigate the root cause of the 2023 spike**
- The simultaneous spike in claims costs and churn rate in 2023 suggests a specific event or systemic failure. A detailed root cause analysis of 2023 data should be conducted to prevent recurrence.

**4. Optimise the Aggressive pricing strategy**
- Aggressive pricing achieves the highest conversion rate but not the highest revenue — suggesting it attracts customers but may attract higher risk profiles. A more nuanced risk based pricing approach could improve both conversion and profitability.

**5. Investigate Group A discount performance**
- Discount Group A consistently outperforms B and C on conversion and revenue despite receiving the same discount. Understanding the customer profile differences between groups could allow the company to target Group A type customers more effectively.

**6. Address North East regional claims**
- The North East's 31.19% claim rate — highest of all regions — warrants a region specific pricing review. Slightly higher premiums for North East customers could help offset the elevated claims risk without losing customers to competitors.

**7. Leverage exceptional forecasting capability**
- The company's near perfect revenue forecasting accuracy (+/- 0.02%) is a significant operational strength. This capability should be extended to claims forecasting — where accuracy appears much weaker — to better predict and price for risk.

---

### Dataset Source
The dataset was created as a simulated fictional dataset for portfolio and analytical purposes, representing a UK vehicle insurance company's customer pricing, behaviour and revenue data across 2022–2025. It contains no real customer data.

---

*Project by Similoluwa Olagunju | MSc Business Analytics*
*Tools: Microsoft SQL Server (SSMS) | Power BI Desktop*
*Connect on LinkedIn: [Your LinkedIn URL]*
*GitHub: [Your GitHub URL]*
