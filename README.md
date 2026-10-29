# E-commerce Sales, Customer Behaviour and Profitability Analytics



An end-to-end data analytics project built using Python, MySQL, Excel and Power BI.



## Project Overview



This project analyses the sales, profitability, customers, products, discounts, returns and geographic performance of a global e-commerce business.



The goal was to build a complete analytics solution, starting from raw data validation and cleaning and ending with interactive dashboards and practical business recommendations.



The fictional business name used in this project is **NovaCart Global**.



> **Dataset Note:** This project uses the public Global Superstore business-case dataset. NovaCart Global is a fictional company, and the results should not be presented as verified transactional data from a named real company.



## Business Questions



The project was designed to answer the following questions:



1\. How did revenue and profit change between 2012 and 2015?

2\. Which categories, sub-categories and products generated the most profit?

3\. Which products generated revenue but still produced a loss?

4\. How did discount levels affect profit margin?

5\. Which Markets, Regions and Countries performed best and worst?

6\. How important were repeat customers to total revenue?

7\. Which customers may require reactivation?

8\. What was the returned-order rate?

9\. Were there useful customer cohort or market basket patterns?

10\. What practical actions could improve future profitability?



## Dataset



| Source Table | Rows | Columns | Purpose |

|---|---:|---:|---|

| Orders | 51,290 | 24 | Sales, products, customers, discounts, shipping and geography |

| Returns | 1,079 | 3 | Returned-order information |

| People | 24 | 2 | Region-to-manager mapping |



**Order Period:** 1 January 2012 to 31 December 2015



After cleaning and feature engineering, the main Orders dataset contained **51,290 rows and 38 columns**.



## Tools Used



| Tool | Main Use |

|---|---|

| Python | Data loading, validation, cleaning, EDA and statistical analysis |

| Pandas and NumPy | Data preparation and calculations |

| Matplotlib and Seaborn | Exploratory visualisations |

| SciPy | Statistical testing |

| MySQL 8 | Star schema, SQL analysis and validation |

| Excel | Power Query, Data Model, PivotTables, PivotCharts and slicers |

| Power BI | Data model, DAX measures and interactive dashboards |

| Git and GitHub | Version control and project documentation |



## Project Workflow



1\. Business understanding and dataset selection

2\. Data dictionary and project structure

3\. Python data loading and source validation

4\. Data-quality audit

5\. Data cleaning and feature engineering

6\. Exploratory data analysis

7\. Statistical and advanced analysis

8\. MySQL star-schema design

9\. Advanced SQL business analysis

10\. Interactive Excel dashboard

11\. Power BI data model and DAX

12\. Four-page Power BI dashboard

13\. Business insights and recommendations



## Main Business KPIs



| KPI | Result |

|---|---:|

| Total Revenue | $12.64M |

| Total Profit | $1.47M |

| Profit Margin | 11.61% |

| Total Orders | 25,739 |

| Customers | 796 |

| Total Quantity | 178,312 |

| Average Order Value | $491.18 |

| Returned-Order Rate | 4.19% |



## Key Findings



\- Revenue increased from approximately **$2.26M in 2012** to **$4.30M in 2015**.

\- Profit increased from approximately **$248.94K to $504.17K** during the same period.

\- Growth was driven mainly by more orders, while average order value slightly decreased.

\- Technology was the strongest category for revenue and profit.

\- Tables was the only loss-making sub-category, with approximately **-$64.08K profit** and a **-8.46% margin**.

\- The analysis found **677 loss-making products**, producing a combined loss of approximately **$247.84K**.

\- Discount levels above 20% were loss-making overall.

\- The discount band above 50% generated **$371.62K in revenue** but produced a **$412.58K loss**.

\- Asia Pacific generated the highest revenue, while Europe generated the highest profit and strongest market margin.

\- Thirty-one countries were loss-making.

\- Repeat purchasers generated approximately **96.86% of total revenue**.

\- The At Risk customer group contained approximately **$2.02M in historical revenue**.

\- The overall returned-order rate was **4.19%**.

\- Statistical testing confirmed a strong negative relationship between discount and line-level profit margin.



Detailed findings are available in \[Business Insights](reports/business_insights.md).

## Executive Business Report

A concise management report brings together the validated KPIs, key business risks, customer and geographic findings, dashboard evidence, limitations and the recommended 90-day action plan.

- [View the client-ready PDF report](reports/NovaCart_Global_Executive_Business_Report.pdf)
- [Download the editable Word report](reports/NovaCart_Global_Executive_Business_Report.docx)

## Power BI Dashboard



The Power BI report contains four visible pages and one hidden measure-validation page.



### 1. Executive Overview



This page presents the main KPIs, monthly Revenue and Profit trend, category performance and Market-to-Region revenue drill-down.



!\[Power BI Executive Overview](reports/dashboard_screenshots/powerbi_01_executive_overview.png)



### 2. Product and Profitability



This page analyses sub-category profitability, the Bottom 5 products by profit and the impact of discount bands on revenue and margin.



!\[Power BI Product and Profitability](reports/dashboard_screenshots/powerbi_02_product_profitability.png)



### 3. Customer Analytics



This page contains customer Revenue-versus-Profit analysis, Top 10 customers and customer-segment performance.



!\[Power BI Customer Analytics](reports/dashboard_screenshots/powerbi_03_customer_analytics.png)



### 4. Recommendations and Details



This page provides detailed product-level profitability, Year, Market, Category and Region filters, and the main recommended actions.



!\[Power BI Recommendations and Details](reports/dashboard_screenshots/powerbi_04_recommendations_details.png)



The complete Power BI file is available at:



\[`powerbi/ecommerce_sales_customer_profitability_dashboard.pbix`](powerbi/ecommerce_sales_customer_profitability_dashboard.pbix)



## Power BI Data Model



The Power BI model uses a star-schema design with:



\- FactSales at sales-line level

\- DimDate

\- DimCustomer

\- DimProduct

\- DimGeography

\- Four active one-to-many relationships

\- One inactive Ship Date relationship

\- Single-direction filtering



!\[Power BI Star Schema](reports/dashboard_screenshots/powerbi_star_schema.png)



## Excel Dashboard



The Excel dashboard was built using Power Query, the Excel Data Model, PivotTables, PivotCharts, slicers and formula-linked KPIs.



!\[Excel Executive Dashboard](reports/dashboard_screenshots/excel_executive_dashboard.png)



The Excel workbook is available at:



\[`excel/ecommerce_sales_dashboard.xlsx`](excel/ecommerce_sales_dashboard.xlsx)



## Python Analysis



The notebooks are designed to run in sequence:



| Notebook | Purpose |

|---|---|

| \[01 Data Loading and Inspection](notebooks/01_data_loading_and_inspection.ipynb) | Loads the source files and validates their structure |

| \[02 Data Quality Audit](notebooks/02_data_quality_audit.ipynb) | Checks missing values, duplicates, validity, outliers, keys and joins |

| \[03 Data Cleaning and Feature Engineering](notebooks/03_data_cleaning_and_feature_engineering.ipynb) | Cleans the data, creates reliable keys and exports processed files |

| \[04 Exploratory Data Analysis](notebooks/04_exploratory_data_analysis.ipynb) | Analyses revenue, profit, products, discounts, customers, geography and returns |

| \[05 Statistical and Advanced Analysis](notebooks/05_statistical_and_advanced_analysis.ipynb) | Performs statistical tests, cohort analysis and market basket analysis |



## MySQL Database and SQL Analysis



The MySQL star schema contains:



| Table | Rows |

|---|---:|

| dim_date | 1,468 |

| dim_customer | 796 |

| dim_product | 3,788 |

| dim_geography | 3,856 |

| fact_sales | 51,290 |



Schema scripts:



1\. \[Create Database and Staging Tables](sql/schema/01_create_database_and_tables.sql)

2\. \[Create Star Schema](sql/schema/02_create_star_schema.sql)

3\. \[Populate Star Schema](sql/schema/03_populate_star_schema.sql)

4\. \[Validate Star Schema](sql/schema/04_validate_star_schema.sql)



The project also contains 20 business-focused SQL queries covering:



\- Executive KPIs and trends

\- Month-over-month and year-over-year growth

\- Product and category profitability

\- Discount analysis

\- Customer behaviour and RFM

\- Cohort activity

\- Geographic performance

\- Returns

\- Market basket analysis



SQL query files are available in \[`sql/queries/`](sql/queries/).



## Processed Data



The cleaned outputs are stored in \[`data/processed/`](data/processed/):



\- `orders_cleaned.csv`

\- `returns_cleaned.csv`

\- `customer_key_mapping.csv`

\- `regional_manager_mapping.csv`



Raw source files are not edited or overwritten. They are excluded from Git and must be stored separately under `data/raw/`.



## Main Recommendations



1\. Introduce approval rules for discounts above 20%.

2\. Restrict discounts above 50% unless they are part of an approved stock-clearance decision.

3\. Review the 677 loss-making products, starting with Tables and the Bottom 5 products.

4\. Review pricing, shipping and fulfilment costs in loss-making countries.

5\. Assign Region and Country actions to the relevant Regional Managers.

6\. Reactivate valuable At Risk customers without using unprofitable blanket discounts.

7\. Plan November and December campaigns using both revenue and profit targets.

8\. Improve return data by recording the exact returned product and return reason.

9\. Test selected cross-selling opportunities on a small scale before wider use.



The complete action plan is available in \[Business Recommendations](reports/business_recommendations.md).



## How to Run the Project



### Python



1\. Clone or download the repository.

2\. Place the original source files under `data/raw/`.

3\. Install the required Python libraries:



```bash

pip install -r requirements.txt
