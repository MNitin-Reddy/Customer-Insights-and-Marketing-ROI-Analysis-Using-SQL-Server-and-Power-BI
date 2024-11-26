-- Sales Performance

-- What are the trends in revenue over months, or years?
SELECT * FROM orders;
-- YEAR
SELECT DISTINCT YEAR(occurred_at) AS order_year, ROUND((SUM(total_amt_usd) OVER (PARTITION BY YEAR(occurred_at)))/1000,2) AS yearly_total_in_k$
FROM orders
UNION ALL
SELECT 
    NULL AS order_year, 
    ROUND(SUM(total_amt_usd)/1000,2) AS yearly_total_in_k$
FROM orders
ORDER BY order_year;
-- Total	23141.51
-- 2013	   377.33
-- 2014	   4069.11
-- 2015	   5752
-- 2016	   12864.92
-- 2017	   78.15
-- Most sales in year 2016

-- MONTH
SELECT DISTINCT MONTH(occurred_at) AS order_month, ROUND((SUM(total_amt_usd) OVER (PARTITION BY MONTH(occurred_at)))/1000,2) AS monthly_total_in_k$
FROM orders
UNION ALL
SELECT 
    NULL AS order_month, 
    ROUND(SUM(total_amt_usd)/1000,2) AS monthly_total_in_k$
FROM orders
ORDER BY order_month;
--NULL	23141.51
--1	1337.66
--2	1312.62
--3	1659.99
--4	1562.04
--5	1537.08
--6	1871.12
--7	1978.73
--8	1918.11
--9	2017.22
--10	2427.51
--11	2390.03
--12	3129.41
-- Most sales at the end of Year

-- Which product types (e.g., standard, gloss, poster) are contributing the most to revenue?
SELECT ROUND(SUM(standard_amt_usd)/1000000,2) AS revenue_standard_M$, 
		ROUND(SUM(gloss_amt_usd)/1000000,2) AS revenue_gloss_M$, 
		ROUND(SUM(poster_amt_usd)/1000000,2) AS revenue_poster_M$
FROM orders;
-- 9.67	7.59	5.88
-- standard contributes more

-- Who are the customers that ordered the most and are frequently purchasing?
WITH AccountOrderStats AS (
    SELECT 
        a.name,
        MIN(occurred_at) AS first_order_date,
        MAX(occurred_at) AS last_order_date,
        COUNT(*) AS order_count
    FROM accounts a JOIN orders o ON a.id = o.account_id
    GROUP BY a.name
)
SELECT 
    name,
    order_count,
    DATEDIFF(DAY, first_order_date, last_order_date) AS avg_days_between_orders
FROM AccountOrderStats
ORDER BY order_count DESC;
--Leucadia National	71	1090
--Sysco	68	1090
--Supervalu	68	1116
--Arrow Electronics	67	1097
--Archer Daniels Midland	66	1096
--General Dynamics	66	1089
--Mosaic	66	1092
--Philip Morris International	65	1095
--Fluor	65	1094
--United States Steel	65	1122


-- What are the accounts that contribute to the most revenue?
SELECT TOP 10 a.name AS account_name, ROUND(SUM(o.total_amt_usd)/1000,2) AS total_revenue_k$
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_revenue_k$ DESC;
--EOG Resources	382.87
--Mosaic	345.62
--IBM	326.82
--General Dynamics	300.69
--Republic Services	293.86
--Leucadia National	291.05
--Arrow Electronics	281.02
--Sysco	278.58
--Supervalu	275.29
--Archer Daniels Midland	272.67