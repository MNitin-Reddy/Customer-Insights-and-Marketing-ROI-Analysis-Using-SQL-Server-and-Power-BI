-- Customer Analysis

-- 1. What are the key customes from each region and the amount of sales brought by them?
-- Grouping accounts by region and finding total sales in each region
SELECT r.name, COUNT(a.id) as num_counts, ROUND(SUM(o.total_amt_usd),2) as total_sales 
FROM 
accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
JOIN orders o ON a.id = o.account_id
GROUP BY r.name;
-- Midwest	     897	3013486.51
-- Northeast	2357	7744405.36
-- Southeast	2024	6458497
-- West	        1634	5925122.95

-- 2. How diverse is the customer base in terms of the number of unique companies or industries?
SELECT COUNT(DISTINCT name) FROM accounts;
-- 351

-- 3. Company Size: Analyze total sales based on assumed customer size
SELECT a.name, SUM(o.total_amt_usd) as sales
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY sales DESC;
-- Max -> 3,82,873   , Min -> 390

-- Consider company size small when sales < 1,00,000 , medium when between 100000 to  2,50,000 , Large when greater than that

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
-- Large	14
-- Medium	68
-- Small	268

-- 4. Who is the primary point of contact for the largest orders?
 -- Which accounts are generating the most revenue (in terms total spend)?
SELECT TOP 10 primary_poc, ROUND(SUM(total_amt_usd),2) AS total_sales
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY primary_poc
ORDER BY total_sales DESC;
--Alida Desrosier	382873.3
--Tamara Tuma	365726.12
--Lorette Blasi	345618.59
--Denis Gros	326819.48
--Erin Viverette	300694.79
--Gail Widmer	293861.14
--Merrill Rubino	291047.25
--Craig Mcalpine	281018.36
--Julia Laracuente	278575.64
--Kristopher Moton	275288.3

-- 5. Who are the top-tier customers based on total quantity purchased?
SELECT a.name, SUM (o.standard_qty + o.poster_qty )as total_qty 
FROM 
accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
order BY total_qty DESC;

-- These are top 10
--Core-Mark Holding	46616
--DISH Network	43149
--Mosaic	34889
--Pacific Life	34021
--IBM	33023
--Citigroup	32060
--Thermo Fisher Scientific	31676
--Republic Services	31364
--ADP	29859
--American Family Insurance Group	29404




