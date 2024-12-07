# Customer Insights and Marketing ROI Analysis Using SQL Server and Power BI

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


![P&P](https://github.com/MNitin-Reddy/parch-posy-project/blob/main/Database%20ERD.png)


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

## PowerBI Report
![Dashboard1](Report%20Images/Sales%20Summary%20Report.png)
![Dashboard1](Report%20Images/Regional%20Performance%20Report.png)
![Dashboard1](Report%20Images/Marketing%20Performance%20Report.png)

## Conclusion and Final Analysis

The analysis of the company's ```marketing effectiveness```, ```geographic distribution```, ```customer interactions```, ```sales performance```, and ```revenue trends``` across different regions provides a comprehensive overview of how each region and marketing channel is performing.

### 1. Marketing Effectiveness

**Top Performing Channels:**
- Direct marketing leads in customer interactions, order sizes, and rapid conversion to first orders across all regions. It is the most effective touchpoint, contributing significantly to both interactions and revenue.
Other channels, such as Facebook, Adwords, and Organic, perform strongly in certain regions but are not as universally impactful as Direct.

**Key Insight:** The Direct channel is the most effective in terms of customer engagement and conversion. Increasing investments or improving strategies for other channels like Facebook and Adwords may help capture a larger market share.

### 2. Customer Behavior and Retention
**Customer Conversion & Retention Rates:**
- Conversion rates from marketing touchpoints are very high, with 99.7% of customers making an order after interacting with a marketing touchpoint. The Twitter and Facebook channels, while effective for initial engagement, show a longer time to first order.
- Retention Rates are strong across regions, particularly in the Midwest with a perfect retention rate of 100%. However, regions like the Northeast, Southeast, and West show slightly lower retention rates (92%–94%).

**Key Insight:** Retention is a key factor driving long-term business success, particularly in regions like the Midwest, where perfect retention suggests high customer satisfaction. Strategies to increase retention, such as personalized offerings and loyalty programs, could yield significant long-term benefits.

### 3. Geographic Insights and Revenue

**Top Revenue-Generating Regions:**
- The Northeast leads in total revenue generation, followed by the Southeast and West. The Midwest region, while not a top performer in terms of revenue, shows steady growth and high retention.

**Key Insight:** Focus on scaling marketing efforts in the Midwest, which shows high potential for growth in both orders and customer retention. The Northeast and Southeast should continue to be high-priority markets due to their strong revenue generation.

### 4. Sales Performance by Region

**Order Distribution:**
- The Northeast is the highest in terms of total orders, with a significant contribution from standard orders and poster orders.
- The Midwest has the lowest number of total orders but excels in customer retention, which may indicate strong loyalty among a smaller customer base.

**Key Insight:** Enhancing product offerings in the Midwest could boost order volume, while in the Northeast, focusing on expanding the variety of products (especially poster orders) could capitalize on high order frequency.

### 5. Revenue Growth Trends

**Revenue Growth Over Time:**
- The Northeast and Southeast saw strong revenue growth from 2014 to 2016 but experienced a dip in 2017. The Midwest showed strong growth in 2016, while the West maintained steady growth with some fluctuations.

**Key Insight:** The Midwest’s growth in 2016 could provide useful insights into successful strategies that can be replicated in other regions. The dip in 2017 across certain regions warrants a deeper investigation into the factors contributing to this drop, whether it’s market trends, product issues, or external economic factors.

---

## Final Recommendations

1. **Leverage Direct Marketing:** Given its dominant performance across all regions, increase focus on the Direct channel while optimizing Facebook, Adwords, and Organic strategies to capture a wider audience and improve conversion rates.

2. **Focus on Customer Retention:** Especially in regions like the Northeast and West, retention strategies should be improved to match the Midwest’s performance. This could include enhancing customer service, loyalty programs, or introducing incentives for repeat orders.

3. **Capitalize on Regional Strengths:** The Northeast and Southeast remain the top regions for revenue generation, while the Midwest offers high potential for growth and strong customer loyalty. Tailor strategies to maintain high retention in the Midwest and expand market share in the Northeast and Southeast.

4. **Targeted Product Expansion:** The Northeast region benefits from a high number of poster orders. Tailoring product offerings based on regional preferences could increase order volumes and revenue. Similarly, improving order volumes in the Midwest through targeted campaigns could unlock additional revenue streams.

5. **Investigate Revenue Declines:** The drop in revenue in 2017 should be investigated thoroughly to understand the reasons behind it, whether it’s external factors like economic downturns or internal issues such as product quality or pricing changes.

