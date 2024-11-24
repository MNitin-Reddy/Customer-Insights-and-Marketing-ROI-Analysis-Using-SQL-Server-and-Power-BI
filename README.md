# Parch & Posey SQL project

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

## Data Sources
The analysis uses the following datasets:
* `accounts.csv`: Details about customer accounts, including geographic coordinates and primary points of contact.
* `orders.csv`: Order details such as product quantities, amounts, and timestamps.
* `region.csv`: Regional information tied to sales performance.
* `sales_rep.csv`: Details of sales representatives, including their assigned regions.
* `web_events.csv`: Customer interaction data from different marketing channels.

## Data Cleaning
* **Null Value Checks:** Identify missing values in critical fields like sales_rep_id, account_id, occurred_at, etc., and decide on handling (e.g., imputation, exclusion).
* **Duplicate Checks:** Look for duplicate rows in datasets like orders.csv or web_events.csv.
* **Data Type Validation:** Ensure dates are formatted correctly and numeric fields are consistent (e.g., latitude/longitude, sales amounts).
* **Data Consistency:** Verify relationships (e.g., all region_id in sales_rep.csv exist in region.csv).
