
## 1. Data Cleaning and Preprocessing

### 1.1 Primary and Foreign Key Setup

We set primary keys for all tables and establish foreign key relationships to ensure data integrity.

```sql
USE parch_posey;

-- Set primary keys
ALTER TABLE accounts
ADD CONSTRAINT PK_Accounts PRIMARY KEY (id);

ALTER TABLE orders
ADD CONSTRAINT PK_Orders PRIMARY KEY (id);

ALTER TABLE region
ADD CONSTRAINT PK_Region PRIMARY KEY (id);

ALTER TABLE sales_reps
ADD CONSTRAINT PK_SalesRep PRIMARY KEY (id);

ALTER TABLE web_events
ADD CONSTRAINT PK_WebEvents PRIMARY KEY (id);

-- Foreign Keys setup
-- Link orders to accounts
ALTER TABLE orders
ADD CONSTRAINT FK_Orders_Accounts FOREIGN KEY (account_id)
REFERENCES accounts (id);

-- Link sales_rep to region
ALTER TABLE sales_reps
ADD CONSTRAINT FK_SalesRep_Region FOREIGN KEY (region_id)
REFERENCES region (id);

-- Link accounts to sales_rep
ALTER TABLE accounts
ADD CONSTRAINT FK_Accounts_SalesRep FOREIGN KEY (sales_rep_id)
REFERENCES sales_reps (id);

-- Link web_events to accounts
ALTER TABLE web_events
ADD CONSTRAINT FK_WebEvents_Accounts FOREIGN KEY (account_id)
REFERENCES accounts (id);
```
### 1.2 Checking for Missing Values
We perform checks to identify any missing values in the dataset for each table.
##### Accounts Table
```sql
SELECT 
    'id' AS ColumnName, COUNT(*) AS TotalRows, SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NullCount
FROM accounts
UNION ALL
SELECT 'name', COUNT(*), SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END)
FROM accounts
UNION ALL
SELECT 'website', COUNT(*), SUM(CASE WHEN website IS NULL THEN 1 ELSE 0 END)
FROM accounts
UNION ALL
SELECT 'lat', COUNT(*), SUM(CASE WHEN lat IS NULL THEN 1 ELSE 0 END)
FROM accounts
UNION ALL
SELECT 'long', COUNT(*), SUM(CASE WHEN long IS NULL THEN 1 ELSE 0 END)
FROM accounts
UNION ALL
SELECT 'primary_poc', COUNT(*), SUM(CASE WHEN primary_poc IS NULL THEN 1 ELSE 0 END)
FROM accounts
UNION ALL
SELECT 'sales_rep_id', COUNT(*), SUM(CASE WHEN sales_rep_id IS NULL THEN 1 ELSE 0 END)
FROM accounts;
```
**Insights:**
* No missing values in any of the columns in the accounts table.
##### Orders Table
```sql
SELECT 
    'id' AS ColumnName, COUNT(*) AS TotalRows, SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NullCount
FROM orders
UNION ALL
SELECT 'account_id', COUNT(*), SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END)
FROM orders
UNION ALL
SELECT 'occurred_at', COUNT(*), SUM(CASE WHEN occurred_at IS NULL THEN 1 ELSE 0 END)
FROM orders
UNION ALL
SELECT 'standard_qty', COUNT(*), SUM(CASE WHEN standard_qty IS NULL THEN 1 ELSE 0 END)
FROM orders
UNION ALL
SELECT 'gloss_qty', COUNT(*), SUM(CASE WHEN gloss_qty IS NULL THEN 1 ELSE 0 END)
FROM orders
UNION ALL
SELECT 'poster_qty', COUNT(*), SUM(CASE WHEN poster_qty IS NULL THEN 1 ELSE 0 END)
FROM orders
UNION ALL
SELECT 'total_amt_usd', COUNT(*), SUM(CASE WHEN total_amt_usd IS NULL THEN 1 ELSE 0 END)
FROM orders;
```
**Insights:**
* Found missing values in the columns ```standard_qty```, ```gloss_qty```, and ```poster_qty``` in the ```orders``` table.
* 825 missing values in standard_qty, 1018 in gloss_qty, and 1149 in poster_qty.

##### Region Table
```sql
SELECT * FROM region;
```
**Insights:**
  * No missing values in the region table. ( Table has only 5 records easy to check)

##### Sales Reps Table
```sql
SELECT * FROM sales_reps;
```
**Insights:**
* No missing values in the sales_reps table.
##### Web Events Table
```sql
SELECT 
    'id' AS ColumnName, COUNT(*) AS TotalRows, SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NullCount
FROM web_events
UNION ALL
SELECT 'account_id', COUNT(*), SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END)
FROM web_events
UNION ALL
SELECT 'occurred_at', COUNT(*), SUM(CASE WHEN occurred_at IS NULL THEN 1 ELSE 0 END)
FROM web_events
UNION ALL
SELECT 'channel', COUNT(*), SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END)
FROM web_events;
```
**Insights:**
* No missing values in the web_events table.

### 1.3 Handling Missing Data
For the missing values in the orders table (i.e., standard_qty, gloss_qty, poster_qty), we decided to:
* Replace rows where all three quantities are NULL with 0.
* For other missing values, use the average of non-null values to replace the missing values.
```sql
-- Set quantities to 0 if all are NULL
UPDATE orders
SET standard_qty = 0,
    gloss_qty = 0,
    poster_qty = 0
WHERE standard_qty IS NULL 
   AND gloss_qty IS NULL 
   AND poster_qty IS NULL;

-- Replace missing standard_qty with the average value
UPDATE orders
SET standard_qty = (SELECT AVG(CAST(standard_qty AS FLOAT)) FROM orders WHERE standard_qty IS NOT NULL)
WHERE standard_qty IS NULL;

-- Replace missing gloss_qty with the average value
UPDATE orders
SET gloss_qty = (SELECT AVG(CAST(gloss_qty AS FLOAT)) FROM orders WHERE gloss_qty IS NOT NULL)
WHERE gloss_qty IS NULL;

-- Replace missing poster_qty with the average value
UPDATE orders
SET poster_qty = (SELECT AVG(CAST(poster_qty AS FLOAT)) FROM orders WHERE poster_qty IS NOT NULL)
WHERE poster_qty IS NULL;
```
### 1.4 Checking for Duplicates
We perform checks to ensure there are no duplicate rows in the dataset.
##### Orders Table
```sql
SELECT COUNT(*) as duplicated
FROM orders
GROUP BY id, account_id, occurred_at, standard_qty, gloss_qty, poster_qty, total_amt_usd
HAVING COUNT(*) > 1;
```
**Insights:**
* No duplicate rows in the orders table.

##### Web Events Table
```sql
SELECT id, account_id, occurred_at, channel, COUNT(*) AS duplicate_count
FROM web_events
GROUP BY id, account_id, occurred_at, channel
HAVING COUNT(*) > 1;
```
**Insights:**
* No duplicate rows in the web_events table.

### Checking for Inconsistencies in Categorical Variables
We check if there are any inconsistencies or unusual entries in categorical columns.
##### Accounts Table
```sql
SELECT DISTINCT name FROM accounts;
```
**Insights:**
* All categorical values in the accounts table are correct and consistent.

### 1.5 Checking for Correct Data Types
We ensure that the data types are appropriate for each column, especially date fields.
```sql
SELECT occurred_at
FROM web_events
WHERE ISDATE(occurred_at) = 0;
```
**Insights:**
* All date values are in the correct format.

This section covers the entire data cleaning process, including handling missing data, setting up keys, ensuring there are no duplicates, and verifying the consistency of the data. It is now ready for further analysis and reporting.

--- 

## 2. Customer Analysis

### 2.1 Key Customers by Region and Sales
What are the key customes from each region and the amount of sales brought by them?

This query identifies key customers from each region and their total sales. We group the accounts by region and calculate the total sales for each area.
```sql
SELECT r.name, COUNT(a.id) as num_counts, ROUND(SUM(o.total_amt_usd),2) as total_sales 
FROM 
accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
JOIN orders o ON a.id = o.account_id
GROUP BY r.name;
```
**Insights:**
- **Midwest**: 897 accounts, $3,013,486.51 total sales
- **Northeast**: 2357 accounts, $7,744,405.36 total sales
- **Southeast**: 2024 accounts, $6,458,497 total sales
- **West**: 1634 accounts, $5,925,122.95 total sales

### 2.2 Customer Base Diversity
How diverse is the customer base regarding the number of unique companies or industries?

We analyze the diversity of the customer base by counting the number of unique companies or industries.
```sql
SELECT COUNT(DISTINCT name) FROM accounts;
```
**Insights:**
- There are 351 unique customer companies.
### 2.3 Company Size and Sales Analysis
We analyze total sales based on the size of the companies, categorizing them into small, medium, and large companies based on sales thresholds.
```sql
SELECT a.name, SUM(o.total_amt_usd) as sales
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY sales DESC;
```
**Insights:**
* Maximum sales: $382,873
* Minimum sales: $390

### Categorizing Company Size
We categorize companies based on their sales:
```sql
WITH company_sales_amount AS (
    SELECT a.name, SUM(o.total_amt_usd) as sales
    FROM accounts a
    JOIN sales_reps s ON a.sales_rep_id = s.id
    JOIN region r ON r.id = s.region_id
    JOIN orders o ON a.id = o.account_id
    GROUP BY a.name)
SELECT
    CASE WHEN sales < 100000 THEN 'Small'
         WHEN  sales BETWEEN 100001 AND 250000 THEN 'Medium'
         ELSE 'Large'
    END AS 'Size of company',
    COUNT(*) as count
FROM company_sales_amount
GROUP BY (CASE WHEN sales < 100000 THEN 'Small'
    WHEN  sales BETWEEN 100001 AND 250000 THEN 'Medium'
    ELSE 'Large'
    END);
```

### 2.4 Primary Points of Contact for the Largest Orders
Who is the primary point of contact for the largest orders?

This analysis identifies the primary point of contact (POC) for the accounts generating the highest sales.
```sql
SELECT TOP 10 primary_poc, ROUND(SUM(total_amt_usd),2) AS total_sales
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY primary_poc
ORDER BY total_sales DESC;
```
**Insights:**
| Name                | Total Sales   |
|---------------------|---------------|
| Alida Desrosier     | $382,873.30   |
| Tamara Tuma         | $365,726.12   |
| Lorette Blasi       | $345,618.59   |
| Denis Gros          | $326,819.48   |
| Erin Viverette      | $300,694.79   |
| Gail Widmer         | $293,861.14   |
| Merrill Rubino      | $291,047.25   |
| Craig Mcalpine      | $281,018.36   |
| Julia Laracuente    | $278,575.64   |
| Kristopher Moton    | $275,288.30   |

### 2.5 Top-Tier Customers Based on Total Quantity Purchased
Who are the top-tier customers based on the total quantity purchased?

We identify the top customers based on the total quantity purchased (sum of standard_qty and poster_qty).
```sql
SELECT a.name, SUM (o.standard_qty + o.poster_qty ) as total_qty 
FROM 
accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_qty DESC;
```
**Top 10 Customers:**
| Customer                              | Units Sold  |
|---------------------------------------|-------------|
| Core-Mark Holding                     | 46,616      |
| DISH Network                          | 43,149      |
| Mosaic                                | 34,889      |
| Pacific Life                          | 34,021      |
| IBM                                   | 33,023      |
| Citigroup                             | 32,060      |
| Thermo Fisher Scientific              | 31,676      |
| Republic Services                     | 31,364      |
| ADP                                   | 29,859      |
| American Family Insurance Group       | 29,404      |

This section provides insights into customer analysis, including key customers by region, sales by company size, and identifying primary contacts for top sales. It highlights the diversity and sales volume within the customer base.

---

## 3. Sales Performance

### 3.1 Trends in Revenue Over Time

#### Yearly Trends
What are the trends in revenue over months, or years?
```sql
SELECT DISTINCT YEAR(occurred_at) AS order_year, ROUND((SUM(total_amt_usd) OVER (PARTITION BY YEAR(occurred_at)))/1000,2) AS yearly_total_in_k$
FROM orders
UNION ALL
SELECT 
    NULL AS order_year, 
    ROUND(SUM(total_amt_usd)/1000,2) AS yearly_total_in_k$
FROM orders
ORDER BY order_year;
```
**Insights:**

- **Total Revenue**: $23,141.51K  
- **Year with the highest revenue**: 2016 ($12,864.92K)  

**Yearly Breakdown:**
- 2013: $377.33K  
- 2014: $4,069.11K  
- 2015: $5,752.00K  
- 2016: $12,864.92K  
- 2017: $78.15K  

#### Monthly Trends

Revenue trends were analyzed by months across all years.
```sql
SELECT DISTINCT MONTH(occurred_at) AS order_month, ROUND((SUM(total_amt_usd) OVER (PARTITION BY MONTH(occurred_at)))/1000,2) AS monthly_total_in_k$
FROM orders
UNION ALL
SELECT 
    NULL AS order_month, 
    ROUND(SUM(total_amt_usd)/1000,2) AS monthly_total_in_k$
FROM orders
ORDER BY order_month;
```
**Insights:**

- **Total Revenue**: $23,141.51K  
- **Most sales occur at the end of the year**, with December being the peak month ($3,129.41K).  

**Monthly Breakdown:**

- January: $1,337.66K  
- February: $1,312.62K  
- ...  
- November: $2,390.03K  
- December: $3,129.41K

### 3.2 Revenue Contribution by Product Types
Which product types (e.g., standard, gloss, poster) are contributing the most to revenue?
```sql
SELECT ROUND(SUM(standard_amt_usd)/1000000,2) AS revenue_standard_M$, 
        ROUND(SUM(gloss_amt_usd)/1000000,2) AS revenue_gloss_M$, 
        ROUND(SUM(poster_amt_usd)/1000000,2) AS revenue_poster_M$
FROM orders;
```
**Insights:**

Standard products contribute the most to revenue:  
- **Standard**: $9.67M  
- **Gloss**: $7.59M  
- **Poster**: $5.88M  

### 3.3 Customers with the Most Orders and Frequent Purchases

The following query identifies the most frequent customers and their ordering patterns:
```sql
WITH AccountOrderStats AS (  
    SELECT  
        a.name,  
        MIN(occurred_at) AS first_order_date,  
        MAX(occurred_at) AS last_order_date,  
        COUNT(*) AS order_count  
    FROM accounts a   
    JOIN orders o ON a.id = o.account_id  
    GROUP BY a.name  
)  
SELECT  
    name,  
    order_count,  
    DATEDIFF(DAY, first_order_date, last_order_date) AS avg_days_between_orders  
FROM AccountOrderStats  
ORDER BY order_count DESC;  
```
**Insights:**

- **Top customers based on order count:**
  - Leucadia National: 71 orders, 1,090 days between first and last orders  
  - Sysco: 68 orders, 1,090 days  
  - Supervalu: 68 orders, 1,116 days  
- **Other notable customers:**  
  - Arrow Electronics (67 orders)  
  - Mosaic (66 orders)

### 3.4 Top Revenue-Contributing Accounts

This query identifies the accounts contributing the most to overall revenue:
```sql
SELECT TOP 10 a.name AS account_name, ROUND(SUM(o.total_amt_usd)/1000, 2) AS total_revenue_k$  
FROM accounts a  
JOIN orders o ON a.id = o.account_id  
GROUP BY a.name  
ORDER BY total_revenue_k$ DESC;  
```
**Insights:**

- **Top 10 accounts contributing to revenue:**  
  - EOG Resources: $382.87K  
  - Mosaic: $345.62K  
  - IBM: $326.82K  
  - General Dynamics: $300.69K  
  - Republic Services: $293.86K  
  - Leucadia National: $291.05K  
  - Arrow Electronics: $281.02K  
  - Sysco: $278.58K  
  - Supervalu: $275.29K  
  - Archer Daniels Midland: $272.67K
---

## 4. Marketing Effectiveness Analysis

### 4.1 Customer Interactions by Marketing Channel
Which marketing channels are generating the most customer interactions?
```sql
SELECT DISTINCT channel,   
    COUNT(channel) OVER (PARTITION BY channel) AS 'No. of Interactions'  
FROM web_events  
ORDER BY 'No. of Interactions' DESC;
```

**Insights:**

- **Top channels by interactions:**
  - Direct: 5,298  
  - Facebook: 967  
  - Organic: 952  
  - Adwords: 906  
  - Banner: 476  
  - Twitter: 474  

### 4.2 Conversion Rate from Marketing Touchpoints

What is the conversion rate from marketing touchpoints (e.g., how many web events lead to actual orders)?
```sql
WITH WebEventAccounts AS (  
    SELECT DISTINCT account_id  
    FROM web_events  
),  
OrderAccounts AS (  
    SELECT DISTINCT account_id  
    FROM orders  
)  
SELECT  
    (SELECT COUNT(*) FROM OrderAccounts) AS accounts_with_orders,  
    (SELECT COUNT(*) FROM WebEventAccounts) AS accounts_with_web_events,  
    CAST((SELECT COUNT(*) FROM OrderAccounts) AS FLOAT) /   
    (SELECT COUNT(*) FROM WebEventAccounts) * 100 AS conversion_rate;  
```
**Results:**

- **Accounts with Orders**: 350  
- **Accounts with Web Events**: 351  
- **Conversion Rate**: 99.7%  

### 4.3 Average Order Size by Marketing Channel
 What is the average order size by marketing channel?
 
This query calculates the average order size based on the marketing channel:
```sql
SELECT w.channel AS marketing_channel,  
    AVG(o.total) AS avg_order_size  
FROM web_events w INNER JOIN orders o  
ON w.account_id = o.account_id  
GROUP BY w.channel  
ORDER BY avg_order_size DESC;  
```
**Insights:**

- **Top channels by average order size:**
  - Adwords: 529  
  - Direct: 526  
  - Facebook: 519  
  - Twitter: 518  
  - Organic: 517  
  - Banner: 508  

### 4.4 Time to First Order After Contact

How quickly do customers place their first order after being contacted?
```sql
WITH FirstOrder AS (  
    SELECT w.account_id,  
        w.channel AS marketing_channel,  
        MIN(o.occurred_at) AS first_order_date,  
        MIN(w.occurred_at) AS first_contact_date  
    FROM web_events w INNER JOIN orders o  
    ON w.account_id = o.account_id  
    GROUP BY w.account_id, w.channel  
)  
SELECT marketing_channel,  
    AVG(DATEDIFF(DAY, first_order_date, first_contact_date)) AS avg_days_to_first_order  
FROM FirstOrder  
GROUP BY marketing_channel  
ORDER BY avg_days_to_first_order;  
```
**Results:**

- **Channels by days to first order:**
  - Direct: 0 days  
  - Facebook: 59 days  
  - Adwords: 70 days  
  - Organic: 79 days  
  - Banner: 125 days  
  - Twitter: 131 days  

### 4.5 Retention and Churn Rates by Marketing Channel
 What is the retention or churn rate for customers contacted via marketing channels?
 
Key Metrics:

* Retention Rate (%) = (Number of Customers with Multiple Orders / Total Customers with Orders) × 100
* Churn Rate (%) = 100 -Retention Rate(%)
This query calculates retention and churn rates based on marketing channels:
```sql
WITH OrderCounts AS (  
    SELECT w.channel AS marketing_channel,  
        o.account_id,  
        COUNT(o.id) AS total_orders  
    FROM web_events w LEFT JOIN orders o  
    ON w.account_id = o.account_id  
    GROUP BY w.channel, o.account_id  
),  
RetentionStats AS (  
    SELECT marketing_channel,  
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS retained_customers,  
        COUNT(*) AS total_customers  
    FROM OrderCounts  
    GROUP BY marketing_channel  
)  
SELECT marketing_channel,  
    retained_customers,  
    total_customers,  
    ROUND(CAST(retained_customers AS FLOAT) / total_customers * 100,2) AS retention_rate,  
    ROUND(100 - (CAST(retained_customers AS FLOAT) / total_customers * 100),2) AS churn_rate  
FROM RetentionStats;  
```
**Results:**

- **Retention and churn rates:**
  - Banner: Retention: 98%, Churn: 2%  
  - Facebook: Retention: 96.98%, Churn: 3.02%  
  - Direct: Retention: 96.87%, Churn: 3.13%  
  - Twitter: Retention: 99.47%, Churn: 0.53%  
  - Adwords: Retention: 97.67%, Churn: 2.33%  
  - Organic: Retention: 98.8%, Churn: 1.2%  

### 4.6 Region-wise Influence of Marketing Channels

 Which types of regions are more likely to be influenced by a specific marketing channel?
```sql
SELECT r.name AS region,  
    w.channel AS marketing_channel,  
    COUNT(DISTINCT o.account_id) AS influenced_accounts  
FROM web_events w INNER JOIN orders o  
ON w.account_id = o.account_id  
INNER JOIN accounts a  
ON a.id = o.account_id  
INNER JOIN sales_reps s  
ON a.sales_rep_id = s.id  
INNER JOIN region r  
ON s.region_id = r.id  
GROUP BY r.name, w.channel  
ORDER BY region, influenced_accounts DESC;
``` 
##### Insights from the Region-wise Influence of Marketing Channels:

- **Midwest:**  
  The most effective marketing channel is Direct, with 48 influenced accounts.
- **Northeast:**  
  The most effective marketing channel is Direct, with 105 influenced accounts.
- **Southeast:**  
  The most effective marketing channel is Direct, with 96 influenced accounts.
- **West:**  
  The most effective marketing channel is Direct, with 101 influenced accounts.
  
**Summary:**  

Direct is the most influential marketing channel across all regions, with the highest number of influenced accounts in each.
---
## 5. Geographic Insights

### 5.1 Where are the highest-revenue-generating customers located?
```sql
SELECT DISTINCT r.name,
    ROUND((SUM(total_amt_usd) OVER (PARTITION BY r.name))/1000000,2) AS revenue_M$
FROM region r JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a 
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
ORDER BY revenue_M$ DESC;
```
**Results:**

| Region    | Revenue (in million $) |
|-----------|------------------------|
| Northeast | 7.74                   |
| Southeast | 6.46                   |
| West      | 5.93                   |
| Midwest   | 3.01                   |

**Insight:**

* The Northeast region generates the highest revenue, significantly outperforming the Midwest, which contributes the least.

### 5.2 What is the geographic distribution of customer orders (e.g., are certain regions more active than others)? What product types are more preferred based on the region?
```sql
SELECT DISTINCT r.name,
    SUM(standard_qty) OVER (PARTITION BY r.name) as standard_orders_qty,
    SUM(poster_qty) OVER (PARTITION BY r.name) as poster_orders_qty,
    SUM(total) OVER (PARTITION BY r.name) AS total_orders
FROM region r JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a 
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
ORDER BY total_orders DESC;
```
**Results:**

| Region    | Standard Orders Quantity | Poster Orders Quantity | Total Orders |
|-----------|--------------------------|-------------------------|--------------|
| Northeast | 737,533                  | 280,078                 | 1,230,378    |
| Southeast | 641,187                  | 236,410                 | 1,035,005    |
| West      | 519,925                  | 245,781                 | 927,532      |
| Midwest   | 294,886                  | 102,502                 | 482,850      |

**Insight:**

* The Northeast region has the highest total order count, followed by the Southeast, with the Midwest having the lowest total orders. Standard products are generally preferred across all regions.

### 5.3 How does customer retention vary by location?
```sql
WITH CustomerOrders AS (
    SELECT a.id AS account_id,
        r.name AS region,
        COUNT(o.id) AS total_orders
    FROM accounts a INNER JOIN sales_reps s
    ON a.sales_rep_id = s.id INNER JOIN region r
    ON s.region_id = r.id
    LEFT JOIN orders o
    ON a.id = o.account_id
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
    ROUND(CAST(retained_customers AS FLOAT) / total_customers * 100,2) AS retention_rate
FROM RetentionStats;
```
**Results:**

| Region    | Retained Customers | Total Customers | Retention Rate (%) |
|-----------|--------------------|-----------------|--------------------|
| Midwest   | 48                 | 48              | 100%               |
| Northeast | 98                 | 106             | 92.45%             |
| Southeast | 91                 | 96              | 94.79%             |
| West      | 95                 | 101             | 94.06%             |

**Insight:**

* The Midwest has perfect retention (100%), indicating high customer satisfaction and repeat purchases. The Northeast region shows slightly lower retention but is still strong. The West and Southeast have similar retention rates, around 94-95%.

### 5.4 How has the revenue grown from each region over the years?
```sql
SELECT DISTINCT YEAR(occurred_at) FROM orders;
-- 2013 - 2017

SELECT *
FROM (
    SELECT YEAR(o.occurred_at) as year_n,
        r.name as region_name,
        ROUND(o.total_amt_usd,2) as total_amt
    FROM
    region r JOIN sales_reps s
        ON r.id = s.region_id
        JOIN accounts a 
        ON s.id = a.sales_rep_id
        JOIN orders o
        ON a.id = o.account_id
) AS SourceTable
PIVOT (
    SUM(total_amt)
    FOR year_n IN ([2013], [2014], [2015], [2016],[2017])
) AS PivotTable;
```
**Results:**
| Region    | 2013  | 2014  | 2015  | 2016  | 2017  |
|-----------|-------|-------|-------|-------|-------|
| Midwest   | 88K   | 609K  | 603K  | 1.7M  | NULL  |
| Northeast | 106K  | 1.27M | 2.34M | 3.99M | 26K   |
| Southeast | 126K  | 1.33M | 1.43M | 3.55M | 27K   |
| West      | 57K   | 860K  | 1.38M | 3.61M | 24K   |

**Insight:**
* Northeast and Southeast show strong revenue growth in 2015 and 2016. The West region has steady growth, but there’s a slight dip in 2017. The Midwest saw the most significant jump in revenue from 2015 to 2016, but data for 2017 is unavailable.


## Conclusion and Final Analysis

The analysis of the company's ```marketing effectiveness```, ```geographic distribution```, ```customer interactions```, ```sales performance```, and ```revenue trends``` across different regions provides a comprehensive overview of how each region and marketing channel is performing.

### 1. Marketing Effectiveness

**Top Performing Channels:**
- Direct marketing leads across all regions in customer interactions, order sizes, and rapid conversion to first orders. It is the most effective touchpoint, contributing significantly to both interactions and revenue.
- Other channels such as Facebook, Adwords, and Organic have strong performances in certain regions but are not as universally impactful as Direct.

**Key Insight:** The Direct channel is the most effective in terms of customer engagement and conversion. Increasing investments or improving strategies for other channels like Facebook and Adwords may help capture a larger share of the market.

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





