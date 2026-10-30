/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 03_customer_analytics.sql
Purpose: Analyze customer value, profitability, repeat purchasing,
         new-versus-returning revenue and annualized customer value.
*/

USE ecommerce_analytics;


/* ============================================================
   Query 11: Top Customers by Revenue
   Business Question:
   Which customers generate the highest revenue, and are they
   also profitable and operationally healthy?
   ============================================================ */

WITH customer_performance AS (
    SELECT
        customer.customer_key,
        customer.customer_name,
        customer.segment,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,

        COUNT(
            DISTINCT CASE
                WHEN fact.is_returned = 1
                THEN fact.order_key
            END
        ) AS returned_orders

    FROM fact_sales AS fact

    INNER JOIN dim_customer AS customer
        ON fact.customer_key = customer.customer_key

    GROUP BY
        customer.customer_key,
        customer.customer_name,
        customer.segment
),

ranked_customers AS (
    SELECT
        customer_performance.*,

        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM customer_performance
)

SELECT
    revenue_rank,
    customer_name,
    segment,
    revenue,
    profit,
    orders,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        revenue / NULLIF(orders, 0),
        2
    ) AS average_order_value,

    returned_orders,

    ROUND(
        100 * returned_orders / NULLIF(orders, 0),
        2
    ) AS return_rate_percentage

FROM ranked_customers

WHERE revenue_rank <= 10

ORDER BY revenue_rank;

/* ============================================================
   Query 12: Customers Generating the Largest Losses
   Business Question:
   Which customers generate sales but produce the largest
   cumulative losses?
   ============================================================ */

WITH customer_performance AS (
    SELECT
        customer.customer_key,
        customer.customer_name,
        customer.segment,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,

        ROUND(
            100 * AVG(fact.discount),
            2
        ) AS average_discount_percentage,

        COUNT(
            DISTINCT CASE
                WHEN fact.is_returned = 1
                THEN fact.order_key
            END
        ) AS returned_orders

    FROM fact_sales AS fact

    INNER JOIN dim_customer AS customer
        ON fact.customer_key = customer.customer_key

    GROUP BY
        customer.customer_key,
        customer.customer_name,
        customer.segment
),

loss_making_customers AS (
    SELECT
        customer_performance.*,

        ROW_NUMBER() OVER (
            ORDER BY profit ASC
        ) AS loss_rank

    FROM customer_performance

    WHERE profit < 0
)

SELECT
    loss_rank,
    customer_name,
    segment,
    revenue,
    profit,
    orders,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    average_discount_percentage,

    ROUND(
        100 * returned_orders / NULLIF(orders, 0),
        2
    ) AS return_rate_percentage

FROM loss_making_customers

WHERE loss_rank <= 10

ORDER BY loss_rank;

/* ============================================================
   Query 13: Repeat vs One-Time Customer Performance
   Business Question:
   How do repeat customers differ from one-time customers in
   revenue, profit, margin and average order value?
   Important limitation:
   The dataset contains only one one-time customer. Therefore,
   this group comparison is descriptive and is not statistically
   balanced.
   ============================================================ */

WITH customer_metrics AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_key) AS orders,
        ROUND(SUM(sales), 2) AS revenue,
        ROUND(SUM(profit), 2) AS profit
    FROM fact_sales
    GROUP BY customer_key
),

classified_customers AS (
    SELECT
        customer_key,
        orders,
        revenue,
        profit,

        CASE
            WHEN orders = 1
                THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type

    FROM customer_metrics
),

customer_type_performance AS (
    SELECT
        customer_type,
        COUNT(*) AS customers,
        SUM(orders) AS orders,
        ROUND(SUM(revenue), 2) AS revenue,
        ROUND(SUM(profit), 2) AS profit
    FROM classified_customers
    GROUP BY customer_type
)

SELECT
    customer_type,
    customers,
    orders,
    revenue,
    profit,

    ROUND(
        100 * revenue /
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS revenue_share_percentage,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        revenue / NULLIF(orders, 0),
        2
    ) AS average_order_value,

    ROUND(
        revenue / NULLIF(customers, 0),
        2
    ) AS average_revenue_per_customer

FROM customer_type_performance

ORDER BY
    CASE
        WHEN customer_type = 'Repeat Customer' THEN 1
        ELSE 2
    END;
/* ============================================================
   Query 14: New vs Returning Customer Revenue
   Business Question:
   How much revenue comes from customers on their first
   observed purchase date versus later purchase dates?

   Limitation:
   "New" means first observed purchase within this dataset,
   not necessarily the customer's first-ever company purchase.
   ============================================================ */

WITH order_level_performance AS (
    SELECT
        order_key,
        customer_key,
        order_date_key,
        ROUND(SUM(sales), 2) AS order_revenue,
        ROUND(SUM(profit), 2) AS order_profit
    FROM fact_sales
    GROUP BY
        order_key,
        customer_key,
        order_date_key
),

customer_first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date_key) AS first_order_date_key
    FROM order_level_performance
    GROUP BY customer_key
),

classified_orders AS (
    SELECT
        order_performance.order_key,
        order_performance.customer_key,
        order_performance.order_revenue,
        order_performance.order_profit,

        CASE
            WHEN order_performance.order_date_key =
                 first_purchase.first_order_date_key
                THEN 'New Customer Revenue'
            ELSE 'Returning Customer Revenue'
        END AS customer_order_type

    FROM order_level_performance AS order_performance

    INNER JOIN customer_first_purchase AS first_purchase
        ON order_performance.customer_key =
           first_purchase.customer_key
),

customer_order_type_performance AS (
    SELECT
        customer_order_type,
        COUNT(DISTINCT customer_key) AS customers,
        COUNT(*) AS orders,
        ROUND(SUM(order_revenue), 2) AS revenue,
        ROUND(SUM(order_profit), 2) AS profit
    FROM classified_orders
    GROUP BY customer_order_type
)

SELECT
    customer_order_type,
    customers,
    orders,
    revenue,
    profit,

    ROUND(
        100 * revenue /
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS revenue_share_percentage,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        revenue / NULLIF(orders, 0),
        2
    ) AS average_order_value

FROM customer_order_type_performance

ORDER BY
    CASE
        WHEN customer_order_type = 'New Customer Revenue'
            THEN 1
        ELSE 2
    END;
/* ============================================================
   Query 15: Estimated 12-Month Customer Profit Value
   Business Question:
   Which established customers are expected to generate the
   highest annual profit if their historical purchase pace
   continues?

   Limitation:
   This is a historical annualized profit estimate, not a
   predictive lifetime-value model. Acquisition cost, churn
   probability and future behavior are unavailable.
   ============================================================ */

WITH customer_history AS (
    SELECT
        customer.customer_key,
        customer.customer_name,
        customer.segment,
        MIN(order_date.full_date) AS first_order_date,
        MAX(order_date.full_date) AS last_order_date,
        COUNT(DISTINCT fact.order_key) AS observed_orders,
        ROUND(SUM(fact.sales), 2) AS observed_revenue,
        ROUND(SUM(fact.profit), 2) AS observed_profit

    FROM fact_sales AS fact

    INNER JOIN dim_customer AS customer
        ON fact.customer_key = customer.customer_key

    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key

    GROUP BY
        customer.customer_key,
        customer.customer_name,
        customer.segment
),

analysis_snapshot AS (
    SELECT
        DATE_ADD(
            MAX(order_date.full_date),
            INTERVAL 1 DAY
        ) AS snapshot_date

    FROM fact_sales AS fact

    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key
),

eligible_customers AS (
    SELECT
        customer_history.*,
        analysis_snapshot.snapshot_date,

        DATEDIFF(
            analysis_snapshot.snapshot_date,
            customer_history.first_order_date
        ) / 365.25 AS observed_tenure_years

    FROM customer_history

    CROSS JOIN analysis_snapshot

    WHERE DATEDIFF(
        analysis_snapshot.snapshot_date,
        customer_history.first_order_date
    ) >= 365
),

customer_value_estimates AS (
    SELECT
        eligible_customers.*,

        observed_revenue /
        NULLIF(observed_orders, 0)
            AS average_order_value,

        observed_orders /
        NULLIF(observed_tenure_years, 0)
            AS annual_order_frequency,

        observed_profit /
        NULLIF(observed_revenue, 0)
            AS profit_margin,

        observed_profit /
        NULLIF(observed_tenure_years, 0)
            AS estimated_12_month_profit_value

    FROM eligible_customers
),

ranked_customer_values AS (
    SELECT
        customer_value_estimates.*,

        ROW_NUMBER() OVER (
            ORDER BY estimated_12_month_profit_value DESC
        ) AS estimated_value_rank

    FROM customer_value_estimates
)

SELECT
    estimated_value_rank,
    customer_name,
    segment,
    ROUND(observed_tenure_years, 2)
        AS observed_tenure_years,
    observed_orders,
    ROUND(average_order_value, 2)
        AS average_order_value,
    ROUND(annual_order_frequency, 2)
        AS annual_order_frequency,
    ROUND(100 * profit_margin, 2)
        AS profit_margin_percentage,
    ROUND(estimated_12_month_profit_value, 2)
        AS estimated_12_month_profit_value

FROM ranked_customer_values

WHERE estimated_value_rank <= 10

ORDER BY estimated_value_rank;