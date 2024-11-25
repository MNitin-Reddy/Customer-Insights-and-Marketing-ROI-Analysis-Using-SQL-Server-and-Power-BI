-- 1. Data Cleaning and Preprocessing
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


-- Are there any missing values in the dataset?
-- Accounts table
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
-- Zero NUll count in all columns

-- Orders table
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
SELECT * FROM orders WHERE standard_qty IS NULL;
-- standard_qty -> 825 Null values
-- gloss_qty -> 1018
-- poster_qty -> 1149

-- Region table
SELECT * FROM region;
-- No missing values in region

-- Sales reps table
SELECT * FROM sales_reps;
-- NO missing values in sales_reps

-- Web events table
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
-- No missing values

-- In orders table if all the three columns standard_qty, gloss_qty,  poster_qty are zero then it is 
-- considered as there is no order made so we can replace them with zero
UPDATE orders
SET standard_qty = 0,
    gloss_qty = 0,
    poster_qty = 0
WHERE standard_qty IS NULL 
   AND gloss_qty IS NULL 
   AND poster_qty IS NULL;
-- only 20 rows affected

SELECT * FROM orders WHERE standard_qty IS NULL;
SELECT * FROM orders WHERE gloss_qty IS NULL;
SELECT * FROM orders WHERE poster_qty IS NULL;
-- There is no pattern associated with null values

UPDATE orders
SET standard_qty = (SELECT AVG(CAST(standard_qty AS FLOAT)) FROM orders WHERE standard_qty IS NOT NULL)
WHERE standard_qty IS NULL 

UPDATE orders
SET gloss_qty = (SELECT AVG(CAST(gloss_qty AS FLOAT)) FROM orders WHERE gloss_qty IS NOT NULL)
WHERE gloss_qty IS NULL 

UPDATE orders
SET poster_qty = (SELECT AVG(CAST(poster_qty AS FLOAT)) FROM orders WHERE poster_qty IS NOT NULL)
WHERE poster_qty IS NULL;


-- Are there any duplicates in the dataset?

SELECT COUNT(*) as duplicated
FROM orders
GROUP BY id, account_id, occurred_at, standard_qty, gloss_qty, poster_qty, total_amt_usd
HAVING COUNT(*) > 1;
-- None

SELECT id, account_id, occurred_at, standard_qty, gloss_qty, poster_qty, total_amt_usd, COUNT(*) AS duplicate_count
FROM orders
GROUP BY id, account_id, occurred_at, standard_qty, gloss_qty, poster_qty, total_amt_usd
HAVING COUNT(*) > 1;
-- None

SELECT id, account_id, occurred_at, channel, COUNT(*) AS duplicate_count
FROM web_events
GROUP BY id, account_id, occurred_at, channel
HAVING COUNT(*) > 1;
-- None

-- There are no duplicated records

-- Are there any inconsistencies in categorical variables (e.g., spelling errors, mixed case)?
SELECT DISTINCT name FROM accounts;
-- All ok
-- All tables categorical values are correct

-- Are the data types for each column appropriate (e.g., date columns formatted as dates)?
SELECT occurred_at
FROM web_events
WHERE ISDATE(occurred_at) = 0;
-- Dates are in correct format

