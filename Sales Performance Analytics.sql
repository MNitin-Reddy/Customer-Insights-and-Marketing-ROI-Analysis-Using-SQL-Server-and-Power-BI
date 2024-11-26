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



