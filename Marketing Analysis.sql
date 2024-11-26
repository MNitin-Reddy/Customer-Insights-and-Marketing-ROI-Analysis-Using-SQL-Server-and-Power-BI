-- Marketing Effectiveness Analysis
-- Which marketing channels are generating the most customer interactions?
SELECT DISTINCT channel, 
	COUNT(channel) OVER (PARTITION BY channel) AS 'No. of Interactions'
FROM web_events
ORDER BY 'No. of Interactions' DESC;
--direct	5298
--facebook	967
--organic	952
--adwords	906
--banner	476
--twitter	474

-- What is the conversion rate from marketing touchpoints (e.g., how many web events lead to actual orders)?
-- Total unique accounts with web events
WITH WebEventAccounts AS (
    SELECT DISTINCT account_id
    FROM web_events
),
-- Total unique accounts with orders
OrderAccounts AS (
    SELECT DISTINCT account_id
    FROM orders
)
-- Calculate conversion rate
SELECT 
    (SELECT COUNT(*) FROM OrderAccounts) AS accounts_with_orders,
    (SELECT COUNT(*) FROM WebEventAccounts) AS accounts_with_web_events,
    CAST((SELECT COUNT(*) FROM OrderAccounts) AS FLOAT) / 
    (SELECT COUNT(*) FROM WebEventAccounts) * 100 AS conversion_rate

-- 350	351	 99.7

-- What is the average order size by marketing channel?
SELECT  w.channel AS marketing_channel,
    AVG(o.total) AS avg_order_size
FROM 
    web_events w INNER JOIN orders o
ON w.account_id = o.account_id
GROUP BY w.channel
ORDER BY avg_order_size DESC;

--adwords	529
--direct	526
--facebook	519
--twitter	518
--organic	517
--banner	508

-- How quickly do customers place their first order after being contacted?
WITH FirstOrder AS (
    SELECT w.account_id,
        w.channel AS marketing_channel,
        MIN(o.occurred_at) AS first_order_date,
        MIN(w.occurred_at) AS first_contact_date
    FROM 
        web_events w INNER JOIN orders o
    ON w.account_id = o.account_id
    GROUP BY w.account_id, w.channel
)
SELECT marketing_channel,
    AVG(DATEDIFF(DAY, first_order_date, first_contact_date)) AS avg_days_to_first_order
FROM FirstOrder
GROUP BY marketing_channel
ORDER BY avg_days_to_first_order;
--direct	0
--facebook	59
--adwords	70
--organic	79
--banner	125
--twitter	131


-- What is the retention or churn rate for customers contacted via marketing channels?
---- Key Metrics:
--Retention Rate (%) = (Number of Customers with Multiple Orders / Total Customers with Orders) × 100
--Churn Rate (%) = 100 -Retention Rate(%)
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
--banner	196	200	98	2
--facebook	257	265	96.98	3.02
--direct	340	351	96.87	3.13
--twitter	186	187	99.47	0.53
--adwords	251	257	97.67	2.33
--organic	246	249	98.8	1.2
