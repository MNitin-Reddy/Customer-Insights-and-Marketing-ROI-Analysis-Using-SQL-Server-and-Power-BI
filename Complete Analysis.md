
## Data Cleaning and Preprocessing

### Primary and Foreign Key Setup

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
### Checking for Missing Values
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

### Handling Missing Data
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
### Checking for Duplicates
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

### Checking for Correct Data Types
We ensure that the data types are appropriate for each column, especially date fields.
```sql
SELECT occurred_at
FROM web_events
WHERE ISDATE(occurred_at) = 0;
```
**Insights:**
* All date values are in the correct format.

This section covers the entire data cleaning process, including handling missing data, setting up keys, ensuring there are no duplicates, and verifying the consistency of the data. It is now ready for further analysis and reporting.


