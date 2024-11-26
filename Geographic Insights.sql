-- Geographic Insights
-- Where are the highest-revenue-generating customers located?
SELECT DISTINCT r.name,
	ROUND((SUM(total_amt_usd) OVER (PARTITION BY r.name))/1000000,2) AS revenue_M$
FROM region r JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a 
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
ORDER BY revenue_M$ DESC;
--Northeast	7.74
--Southeast	6.46
--West	5.93
--Midwest	3.01

-- What is the geographic distribution of customer orders (e.g., are certain regions more active than others)?
-- What Product types are more preferred based on the region
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
--Northeast	737533	280078	1230378
--Southeast	641187	236410	1035005
--West	519925	245781	927532
--Midwest	294886	102502	482850


-- How does customer retention vary by location?
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
--Midwest	48	48	100
--Northeast	98	106	92.45
--Southeast	91	96	94.79
--West	95	101	94.06

-- How is the revenue growth from each region over the years?
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
--Midwest	88128.18	609959.35	603651.73	1711747.25	NULL
--Northeast	106136.18	1268612.19	2344588.19	3999036.82	26031.98
--Southeast	126098.59	1330490.39	1428618.1	3545487.49	27802.43
--West	56968.05	860044.61	1375146.92	3608646.35	24317.02

