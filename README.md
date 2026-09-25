# Vehicle-Insurance-Pricing-Customer-Behaviour-Analysis
SQL + Power BI Project | Insurance Revenue, Pricing, Churn & Claims Analysis

## Table of Contents

* [Project Overview](#project-overview)
* [Business Questions](#business-questions)
* [Tools Used](#tools-used)
* [Dataset Overview](#dataset-overview)
* [Data Preparation](#data-preparation)
* [Exploratory Analysis](#exploratory-analysis)
* [Power BI Dashboard](#power-bi-dashboard)
* [Key Metrics](#key-metrics)
* [Key Insights](#key-insights)
* [Recommendations](#recommendations)
* [Project Structure](#project-structure)


## Project Overview

This project analyses vehicle insurance customer, pricing, revenue, churn and claims data to understand customer behaviour, insurance performance and potential revenue risk.

The analysis combines SQL data analysis with an interactive Power BI dashboard to transform raw insurance data into business-focused insights.

> The goal was to:

> - Analyse insurance revenue and pricing performance
> - Understand customer conversion and purchasing behaviour
> - Identify patterns in customer churn
> - Analyse claims volume and claims costs
> - Evaluate revenue at risk from customers with high churn probability
> - Compare performance across policy types, vehicle types, regions and customer segments
> - Analyse the relationship between pricing strategies, discounts and conversion
> - Compare actual revenue against forecast revenue
> - Provide actionable insights that could support customer retention, pricing and revenue decisions


## Business Questions

The project was designed to answer the following business questions:

### Revenue & Pricing

- How much revenue is being generated?
- How does revenue vary by policy type and vehicle type?
- Which pricing strategies generate the most revenue?
- How does discounting affect customer conversion?
- How does revenue vary across months and years?

### Customer Behaviour

- What proportion of customers convert?
- Which customer groups have the highest churn rates?
- How does churn vary by age group?
- How does churn vary across regions?
- Does pricing strategy appear to influence churn?

### Claims

- What is the total cost of claims?
- How does claim cost vary by policy type and vehicle type?
- How does the number of claims change over time?
- Which regions have higher claim rates?

### Revenue Risk & Forecasting

- How much revenue is currently at risk from potential churn?
- Which regions have the highest revenue at risk?
- How closely does actual revenue track forecast revenue?
- Which years show the largest revenue variance?


## Tools Used

- **Microsoft SQL Server / SSMS** – Data exploration, cleaning, transformation and analysis
- **SQL** – Aggregations, filtering, segmentation and business analysis
- **Microsoft Power BI** – Data modelling, DAX measures and dashboard development
- **DAX** – KPI calculations, churn analysis, revenue-at-risk calculations and performance metrics
- **Power BI Visualisations** – Interactive charts, cards, slicers and analytical dashboards


## Dataset Overview

The dataset contains vehicle insurance customer and policy information covering customer demographics, insurance products, pricing, discounts, purchasing behaviour, claims and churn-related variables.

The analysis contains:

- Customer demographic information
- Policy information
- Vehicle type
- Policy type
- Pricing strategy
- Discount/test group
- Final insurance price
- Purchase/conversion status
- Churn status
- Churn probability
- Claim information
- Claim costs
- Region
- Customer age group
- Insurance revenue
- Forecast revenue

### Customer Segmentation

Customers were analysed across several dimensions including:

- Age group
- Region
- Policy type
- Vehicle type
- Pricing strategy
- Discount/test group


## Data Preparation

SQL was used to prepare and analyse the insurance dataset before building the Power BI dashboard.

Key preparation and analysis activities included:

- Reviewing the structure and quality of the source dataset
- Checking customer and policy records
- Analysing categorical variables
- Examining missing and inconsistent values
- Creating aggregations for revenue analysis
- Segmenting customers by demographic and insurance characteristics
- Analysing claims and claim costs
- Preparing data for Power BI reporting
- Validating business calculations before incorporating them into dashboard measures

The prepared dataset was then connected to Power BI for further modelling and visualisation.


## Exploratory Analysis

The exploratory analysis focused on five major business areas:

### 1. Revenue & Pricing Analysis

Revenue was analysed across:

- Policy type
- Vehicle type
- Pricing strategy
- Month
- Year
- Region

The analysis also examined average revenue per customer and average discount percentage.

### 2. Customer Conversion Analysis

Conversion rates were analysed across:

- Pricing strategy
- Vehicle type
- Discount/test group

A conversion rate measure was created to determine the proportion of customers who purchased an insurance policy.

```dax
Conversion Rate % =
DIVIDE(
    SUM(insurance_pricing_dataset[purchased]),
    COUNTROWS(insurance_pricing_dataset),
    0
)

3. Churn Analysis

Customer churn was analysed across:

Age groups
Policy types
Regions
Pricing strategies
Years

A churn rate measure was created to calculate the proportion of customers classified as churned.
