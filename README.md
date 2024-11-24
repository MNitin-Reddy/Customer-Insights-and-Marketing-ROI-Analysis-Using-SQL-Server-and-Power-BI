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

## **Data Sources and Column Descriptions**

<table>
<tr>
<td valign="top">

#### **accounts.csv**  
Contains details about customer accounts.  

| **Column Name**   | **Description**                                    |
|--------------------|----------------------------------------------------|
| `id`              | Unique identifier for each account.                |
| `name`            | Name of the customer account.                      |
| `website`         | Website associated with the customer account.      |
| `lat`             | Latitude of the customer’s location.               |
| `long`            | Longitude of the customer’s location.              |
| `primary_poc`     | Primary point of contact for the account.           |
| `sales_rep_id`    | Identifier of the sales representative managing the account. |

</td>
<td>

#### **orders.csv**  
Details of orders placed by customers.  

| **Column Name**         | **Description**                                    |
|--------------------------|----------------------------------------------------|
| `id`                    | Unique identifier for each order.                  |
| `account_id`            | Identifier linking the order to a customer account.|
| `occurred_at`           | Timestamp indicating when the order occurred.       |
| `standard_qty`          | Quantity of standard items ordered.                |
| `gloss_qty`             | Quantity of gloss items ordered.                   |
| `poster_qty`            | Quantity of poster items ordered.                  |
| `total`                 | Total quantity of items in the order.              |
| `standard_amt_usd`      | Revenue generated from standard items (in USD).     |
| `gloss_amt_usd`         | Revenue generated from gloss items (in USD).        |
| `poster_amt_usd`        | Revenue generated from poster items (in USD).       |
| `total_amt_usd`         | Total revenue generated from the order (in USD).    |

</td>
</tr>
</table>

---

<table>
<tr>
<td>

#### **region.csv**  
Information about regions where sales representatives operate.  

| **Column Name** | **Description**                          |
|------------------|------------------------------------------|
| `id`            | Unique identifier for each region.       |
| `name`          | Name of the region.                      |

</td>
<td>

#### **sales_rep.csv**  
Details about sales representatives and their assigned regions.  

| **Column Name** | **Description**                                   |
|------------------|---------------------------------------------------|
| `id`            | Unique identifier for each sales representative. |
| `name`          | Name of the sales representative.                |
| `region_id`     | Identifier linking the sales representative to a region. |

</td>
</tr>
</table>

---

#### **web_events.csv**  
Logs of customer interactions via various marketing channels.  

| **Column Name** | **Description**                                       |
|------------------|-------------------------------------------------------|
| `id`            | Unique identifier for each web event.                |
| `account_id`    | Identifier linking the web event to a customer account.|
| `occurred_at`   | Timestamp indicating when the web event occurred.      |
| `channel`       | Marketing channel where the interaction took place.   |


## Data Cleaning
* **Null Value Checks:** Identify missing values in critical fields like sales_rep_id, account_id, occurred_at, etc., and decide on handling (e.g., imputation, exclusion).
* **Duplicate Checks:** Look for duplicate rows in datasets like orders.csv or web_events.csv.
* **Data Type Validation:** Ensure dates are formatted correctly and numeric fields are consistent (e.g., latitude/longitude, sales amounts).
* **Data Consistency:** Verify relationships (e.g., all region_id in sales_rep.csv exist in region.csv).
