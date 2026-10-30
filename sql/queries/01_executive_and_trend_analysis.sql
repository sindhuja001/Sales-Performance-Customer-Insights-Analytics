/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 01_executive_and_trend_analysis.sql
Purpose: Analyze executive KPIs, sales trends, growth and regional performance.
*/

USE ecommerce_analytics;


/* ============================================================
   Query 01: Executive KPI Overview
   Business Question:
   What is the company's overall commercial performance?
   ============================================================ */

SELECT
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        100 * SUM(profit) / NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_percentage,

    COUNT(DISTINCT order_key) AS total_orders,
    COUNT(DISTINCT customer_key) AS unique_customers,
    SUM(quantity) AS total_quantity,

    ROUND(
        SUM(sales) /
        NULLIF(COUNT(DISTINCT order_key), 0),
        2
    ) AS average_order_value,

    COUNT(
        DISTINCT CASE
            WHEN is_returned = 1 THEN order_key
        END
    ) AS returned_orders,

    ROUND(
        100 * COUNT(
            DISTINCT CASE
                WHEN is_returned = 1 THEN order_key
            END
        ) /
        NULLIF(COUNT(DISTINCT order_key), 0),
        2
    ) AS return_rate_percentage

FROM fact_sales;

/* ============================================================
   Query 02: Annual Performance and Year-over-Year Growth
   Business Question:
   How have revenue, profit, orders and AOV changed by year?
   ============================================================ */

WITH yearly_performance AS (
    SELECT
        order_date.calendar_year,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,
        COUNT(DISTINCT fact.customer_key) AS customers,
        SUM(fact.quantity) AS quantity
    FROM fact_sales AS fact
    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key
    GROUP BY
        order_date.calendar_year
),

yearly_comparison AS (
    SELECT
        yearly_performance.*,

        LAG(revenue) OVER (
            ORDER BY calendar_year
        ) AS previous_year_revenue,

        LAG(profit) OVER (
            ORDER BY calendar_year
        ) AS previous_year_profit

    FROM yearly_performance
)

SELECT
    calendar_year,
    revenue,
    profit,
    orders,
    customers,
    quantity,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        revenue / NULLIF(orders, 0),
        2
    ) AS average_order_value,

    ROUND(
        100 * (revenue - previous_year_revenue) /
        NULLIF(previous_year_revenue, 0),
        2
    ) AS revenue_yoy_growth_percentage,

    ROUND(
        100 * (profit - previous_year_profit) /
        NULLIF(previous_year_profit, 0),
        2
    ) AS profit_yoy_growth_percentage

FROM yearly_comparison
ORDER BY calendar_year;

/* ============================================================
   Query 03: Monthly Performance, MoM Growth and YTD Revenue
   Business Question:
   How does monthly performance change, and what is the
   cumulative revenue achieved within each year?
   ============================================================ */

WITH monthly_performance AS (
    SELECT
        order_date.calendar_year,
        order_date.month_number,
        order_date.calendar_year_month,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,
        COUNT(DISTINCT fact.customer_key) AS customers
    FROM fact_sales AS fact
    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key
    GROUP BY
        order_date.calendar_year,
        order_date.month_number,
        order_date.calendar_year_month
),

monthly_trends AS (
    SELECT
        monthly_performance.*,

        LAG(revenue) OVER (
            ORDER BY calendar_year, month_number
        ) AS previous_month_revenue,

        SUM(revenue) OVER (
            PARTITION BY calendar_year
            ORDER BY month_number
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS year_to_date_revenue

    FROM monthly_performance
)

SELECT
    calendar_year_month,
    revenue,
    profit,
    orders,
    customers,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        revenue / NULLIF(orders, 0),
        2
    ) AS average_order_value,

    ROUND(
        100 * (revenue - previous_month_revenue) /
        NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_mom_growth_percentage,

    ROUND(year_to_date_revenue, 2)
        AS year_to_date_revenue

FROM monthly_trends
ORDER BY
    calendar_year,
    month_number;
    
/* ============================================================
   Query 04: Monthly Seasonality Analysis
   Business Question:
   Which calendar months consistently generate the strongest
   revenue, profit and profit margin?
   ============================================================ */

WITH individual_months AS (
    SELECT
        order_date.calendar_year,
        order_date.month_number,
        order_date.month_name,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders
    FROM fact_sales AS fact
    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key
    GROUP BY
        order_date.calendar_year,
        order_date.month_number,
        order_date.month_name
),

seasonal_performance AS (
    SELECT
        month_number,
        month_name,
        ROUND(AVG(revenue), 2) AS average_monthly_revenue,
        ROUND(AVG(profit), 2) AS average_monthly_profit,
        ROUND(AVG(orders), 1) AS average_monthly_orders,

        ROUND(
            100 * SUM(profit) / NULLIF(SUM(revenue), 0),
            2
        ) AS profit_margin_percentage,

        ROUND(
            SUM(revenue) / NULLIF(SUM(orders), 0),
            2
        ) AS average_order_value

    FROM individual_months
    GROUP BY
        month_number,
        month_name
)

SELECT
    month_number,
    month_name,
    average_monthly_revenue,
    average_monthly_profit,
    average_monthly_orders,
    profit_margin_percentage,
    average_order_value,

    DENSE_RANK() OVER (
        ORDER BY average_monthly_revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY average_monthly_profit DESC
    ) AS profit_rank,

    DENSE_RANK() OVER (
        ORDER BY profit_margin_percentage DESC
    ) AS margin_rank

FROM seasonal_performance
ORDER BY month_number;

/* ============================================================
   Query 05: Market Performance Ranking
   Business Question:
   Which global markets lead or lag in revenue, profit,
   margin, AOV and return rate?
   ============================================================ */

WITH market_performance AS (
    SELECT
        geography.market,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,
        SUM(fact.quantity) AS quantity,

        COUNT(
            DISTINCT CASE
                WHEN fact.is_returned = 1
                THEN fact.order_key
            END
        ) AS returned_orders

    FROM fact_sales AS fact

    INNER JOIN dim_geography AS geography
        ON fact.geography_key = geography.geography_key

    GROUP BY geography.market
)

SELECT
    market,
    revenue,
    profit,
    orders,
    quantity,
    returned_orders,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        revenue / NULLIF(orders, 0),
        2
    ) AS average_order_value,

    ROUND(
        100 * returned_orders / NULLIF(orders, 0),
        2
    ) AS return_rate_percentage,

    ROUND(
        100 * revenue /
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS revenue_share_percentage,

    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY profit DESC
    ) AS profit_rank,

    DENSE_RANK() OVER (
        ORDER BY
            profit / NULLIF(revenue, 0) DESC
    ) AS margin_rank

FROM market_performance
ORDER BY revenue_rank;