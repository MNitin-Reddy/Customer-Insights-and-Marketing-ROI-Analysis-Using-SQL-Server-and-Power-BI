# Parch & Posey SQL project

## Problem Statement
Parch & Posey, a growing B2B paper goods company, faces challenges in optimizing its business operations amidst increasing competition. The company does not clearly understand how its sales efforts, marketing channels, and regional performance impact overall profitability. With vast amounts of untapped data on customer accounts, orders, and web interactions, there is a pressing need to analyze this information to:

1. **`Regional Performance:`** Identify high-performing regions and underperforming areas.
2. **`Marketing Effectiveness:`** Evaluate the effectiveness of marketing channels in driving customer engagement.
3. **`Customer Behaviour:`** Understand customer purchasing behaviour to tailor sales strategies better.

## Objective
The primary goal of this project is to:
* Analyze sales performance by region, sales representatives, and product categories.
* Understand customer behavior through order patterns and web interactions.
* Evaluate the impact of marketing channels on customer engagement.
* Provide actionable insights for decision-making through data-driven analysis.

## **Data Sources and Column Descriptions**

<table>
<tr>
<td valign="top">

#### **accounts.csv**  
Contains details about customer accounts.  

| **Column Name**   | **Description**                                    |
|--------------------|----------------------------------------------------|
| `id`              | Unique identifier for each account.                |
| `name`            | Name of the customer account.                      |
| `website`         | Website associated with the customer account.      |
| `lat`             | Latitude of the customer’s location.               |
| `long`            | Longitude of the customer’s location.              |
| `primary_poc`     | Primary point of contact for the account.           |
| `sales_rep_id`    | Identifier of the sales representative managing the account. |

</td>
<td>

#### **orders.csv**  
Details of orders placed by customers.  

| **Column Name**         | **Description**                                    |
|--------------------------|----------------------------------------------------|
| `id`                    | Unique identifier for each order.                  |
| `account_id`            | Identifier linking the order to a customer account.|
| `occurred_at`           | Timestamp indicating when the order occurred.       |
| `standard_qty`          | Quantity of standard items ordered.                |
| `gloss_qty`             | Quantity of gloss items ordered.                   |
| `poster_qty`            | Quantity of poster items ordered.                  |
| `total`                 | Total quantity of items in the order.              |
| `standard_amt_usd`      | Revenue generated from standard items (in USD).     |
| `gloss_amt_usd`         | Revenue generated from gloss items (in USD).        |
| `poster_amt_usd`        | Revenue generated from poster items (in USD).       |
| `total_amt_usd`         | Total revenue generated from the order (in USD).    |

</td>
</tr>
</table>

---

<table>
<tr>
<td>

#### **region.csv**  
Information about regions where sales representatives operate.  

| **Column Name** | **Description**                          |
|------------------|------------------------------------------|
| `id`            | Unique identifier for each region.       |
| `name`          | Name of the region.                      |

</td>
<td>

#### **sales_rep.csv**  
Details about sales representatives and their assigned regions.  

| **Column Name** | **Description**                                   |
|------------------|---------------------------------------------------|
| `id`            | Unique identifier for each sales representative. |
| `name`          | Name of the sales representative.                |
| `region_id`     | Identifier linking the sales representative to a region. |

</td>
</tr>
</table>

---

#### **web_events.csv**  
Logs of customer interactions via various marketing channels.  

| **Column Name** | **Description**                                       |
|------------------|-------------------------------------------------------|
| `id`            | Unique identifier for each web event.                |
| `account_id`    | Identifier linking the web event to a customer account.|
| `occurred_at`   | Timestamp indicating when the web event occurred.      |
| `channel`       | Marketing channel where the interaction took place.   |



## Data Cleaning
* **Null Value Checks:** Identify missing values in critical fields like sales_rep_id, account_id, occurred_at, etc., and decide on handling (e.g., imputation, exclusion).
* **Duplicate Checks:** Look for duplicate rows in datasets like orders.csv or web_events.csv.
* **Data Type Validation:** Ensure dates are formatted correctly and numeric fields are consistent (e.g., latitude/longitude, sales amounts).
* **Data Consistency:** Verify relationships (e.g., all region_id in sales_rep.csv exist in region.csv).

## Analysis
* **Sales Performance Analysis:** We analyze the trends in revenue over months and years, identify the in-demand product types, and determine the top customers and accounts contributing to sales. This includes exploring patterns in sales data, order volumes, and customer behaviour to identify key revenue drivers.

* **Marketing Effectiveness Analysis:** Evaluate the performance of various marketing channels. Includes metrics such as customer interactions by channel, conversion rates from web events to orders, average order size by marketing channel, and the speed at which customers place their first order. Additionally, it covers customer retention and churn rates for each marketing channel.

* **Geographic Insights:** Identifying which regions generate the highest revenue and customer activity. Analyze customer retention across different regions and track revenue growth over the years for each geographical area. It helps in understanding regional differences in sales performance, product preferences, and customer behaviour.

* **Customer Retention and Revenue Growth:** Analysis of customer retention rates and the impact of geographic location on customer loyalty. Explore how revenue has evolved over time in different regions, providing insights into the long-term growth potential of each market.

## Key Impactful Queries from the Project Analysis

#### 1. Revenue by Region with Window Function
- This query calculates the revenue generated by customers in each region.

```sql
SELECT DISTINCT r.name,
	ROUND((SUM(total_amt_usd) OVER (PARTITION BY r.name))/1000000,2) AS revenue_M$
FROM region r 
JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON s.id = a.sales_rep_id
JOIN orders o ON a.id = o.account_id
ORDER BY revenue_M$ DESC;
```
**Insight:** 
* This query highlights the highest-revenue-generating regions. 
* It gives a comparative view of revenue across regions, presented in millions of USD.

#### 2. Customer Retention by Region
 This query calculates customer retention rates for each region, based on the number of customers who placed more than one order.
```sql
WITH CustomerOrders AS (
    SELECT a.id AS account_id,
        r.name AS region,
        COUNT(o.id) AS total_orders
    FROM accounts a 
    INNER JOIN sales_reps s ON a.sales_rep_id = s.id 
    INNER JOIN region r ON s.region_id = r.id
    LEFT JOIN orders o ON a.id = o.account_id
    GROUP BY a.id, r.name
),
RetentionStats AS (
    SELECT region,
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS retained_customers,
        COUNT(*) AS total_customers
    FROM CustomerOrders
    GROUP BY region
)
SELECT region,
    retained_customers,
    total_customers,
    ROUND(CAST(retained_customers AS FLOAT) / total_customers * 100, 2) AS retention_rate
FROM RetentionStats;
```
**Insight:** 
* This query calculates retention rates by region, showing how many customers are loyal (i.e., have placed more than one order).

#### 3. Geographic Distribution of Orders by Product Type
This query calculates the quantity of different product types ordered by region.It breaks down orders into 'standard' and 'poster' categories and calculates totals.
```sql
SELECT DISTINCT r.name,
	SUM(standard_qty) OVER (PARTITION BY r.name) as standard_orders_qty,
	SUM(poster_qty) OVER (PARTITION BY r.name) as poster_orders_qty,
	SUM(total) OVER (PARTITION BY r.name) AS total_orders
FROM region r 
JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON s.id = a.sales_rep_id
JOIN orders o ON a.id = o.account_id
ORDER BY total_orders DESC;
```
**Insight:** 
*This query presents the distribution of orders by product type and identifies which regions are most active in terms of overall orders.

#### 4. Revenue Growth Over Multiple Years (Pivot Query)
This query calculates revenue growth by region from 2013 to 2017 using a pivot table.
```sql
SELECT DISTINCT YEAR(occurred_at) FROM orders;  -- 2013 - 2017

SELECT *
FROM (
    SELECT YEAR(o.occurred_at) as year_n,
		r.name as region_name,
		ROUND(o.total_amt_usd, 2) as total_amt
	FROM region r 
	JOIN sales_reps s ON r.id = s.region_id
	JOIN accounts a ON s.id = a.sales_rep_id
	JOIN orders o ON a.id = o.account_id
) AS SourceTable
PIVOT (
    SUM(total_amt)
    FOR year_n IN ([2013], [2014], [2015], [2016],[2017])
) AS PivotTable;
```
**Insight:** 
* This pivot query shows the revenue growth for each region over the years, providing a year-on-year comparison of revenue trends.

#### 5. Advanced Query for Highest-Value Orders
This query identifies the highest-value orders in each region by filtering for orders with a total value greater than $1,000.
```sql
SELECT r.name AS region,
		o.id AS order_id,
		ROUND(o.total_amt_usd, 2) AS total_order_value
FROM region r
JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON s.id = a.sales_rep_id
JOIN orders o ON a.id = o.account_id
WHERE o.total_amt_usd > 1000  -- Filter for high-value orders
ORDER BY total_order_value DESC;
```
**Insight:** 
* This query helps identify the highest-value orders, which can be useful for focusing on key accounts or products that contribute to higher revenue.
