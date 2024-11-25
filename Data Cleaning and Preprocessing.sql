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

  
-- Are there any duplicates in the dataset?**
-- Are there duplicate rows that should be removed to ensure the integrity of the analysis?

-- Are there any outliers or anomalies in key columns?**
 -- Which values are outside the expected range (e.g., negative quantities or negative revenue)?

-- Are there any inconsistencies in categorical variables (e.g., spelling errors, mixed case)?**
  --  How will you standardize the text data in columns like `name` or `channel`?

-- Are the data types for each column appropriate (e.g., date columns formatted as dates)?**
  --  Do we need to convert columns like `occurred_at` to a proper datetime format?

-- What are the statistics for numeric columns (e.g., mean, standard deviation, min/max)?**
  --  This will help identify any unexpected or inconsistent values.