/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 04_validate_star_schema.sql
Purpose: Validate row preservation, financial reconciliation,
         dimension completeness and referential integrity.
*/

USE ecommerce_analytics;


/* 1. Model row inventory */

SELECT 'stg_orders' AS table_name, COUNT(*) AS row_count
FROM stg_orders

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dim_date

UNION ALL

SELECT 'dim_customer', COUNT(*)
FROM dim_customer

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dim_product

UNION ALL

SELECT 'dim_geography', COUNT(*)
FROM dim_geography

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM fact_sales;


/* 2. Source-to-fact reconciliation */

WITH source_summary AS (
    SELECT
        COUNT(*) AS source_rows,
        COUNT(DISTINCT order_key) AS source_orders,
        COUNT(
            DISTINCT CASE
                WHEN LOWER(is_returned) = 'true'
                THEN order_key
            END
        ) AS source_returned_orders,
        SUM(quantity) AS source_quantity,
        ROUND(SUM(sales), 2) AS source_sales,
        ROUND(SUM(profit), 2) AS source_profit
    FROM stg_orders
),
fact_summary AS (
    SELECT
        COUNT(*) AS fact_rows,
        COUNT(DISTINCT order_key) AS fact_orders,
        COUNT(
            DISTINCT CASE
                WHEN is_returned = 1
                THEN order_key
            END
        ) AS fact_returned_orders,
        SUM(quantity) AS fact_quantity,
        ROUND(SUM(sales), 2) AS fact_sales,
        ROUND(SUM(profit), 2) AS fact_profit
    FROM fact_sales
)
SELECT
    source_summary.source_rows,
    fact_summary.fact_rows,
    source_summary.source_orders,
    fact_summary.fact_orders,
    source_summary.source_returned_orders,
    fact_summary.fact_returned_orders,
    source_summary.source_quantity,
    fact_summary.fact_quantity,
    source_summary.source_sales,
    fact_summary.fact_sales,
    source_summary.source_profit,
    fact_summary.fact_profit,
    CASE
        WHEN source_summary.source_rows =
             fact_summary.fact_rows
         AND source_summary.source_orders =
             fact_summary.fact_orders
         AND source_summary.source_returned_orders =
             fact_summary.fact_returned_orders
         AND source_summary.source_quantity =
             fact_summary.fact_quantity
         AND source_summary.source_sales =
             fact_summary.fact_sales
         AND source_summary.source_profit =
             fact_summary.fact_profit
        THEN 'Passed'
        ELSE 'Failed'
    END AS reconciliation_status
FROM source_summary
CROSS JOIN fact_summary;

/* 3. Dimension completeness */

WITH source_dimension_counts AS (
    SELECT
        DATEDIFF(
            GREATEST(MAX(order_date), MAX(ship_date)),
            LEAST(MIN(order_date), MIN(ship_date))
        ) + 1 AS expected_date_rows,

        COUNT(DISTINCT customer_key)
            AS expected_customer_rows,

        COUNT(DISTINCT product_id)
            AS expected_product_rows,

        COUNT(
            DISTINCT CONCAT_WS(
                '|',
                COALESCE(postal_code, ''),
                city,
                state,
                country,
                region,
                market
            )
        ) AS expected_geography_rows
    FROM stg_orders
)
SELECT
    'dim_date' AS dimension_name,
    expected_date_rows AS expected_rows,
    (SELECT COUNT(*) FROM dim_date) AS actual_rows,
    CASE
        WHEN expected_date_rows =
             (SELECT COUNT(*) FROM dim_date)
        THEN 'Passed'
        ELSE 'Failed'
    END AS validation_status
FROM source_dimension_counts

UNION ALL

SELECT
    'dim_customer',
    expected_customer_rows,
    (SELECT COUNT(*) FROM dim_customer),
    CASE
        WHEN expected_customer_rows =
             (SELECT COUNT(*) FROM dim_customer)
        THEN 'Passed'
        ELSE 'Failed'
    END
FROM source_dimension_counts

UNION ALL

SELECT
    'dim_product',
    expected_product_rows,
    (SELECT COUNT(*) FROM dim_product),
    CASE
        WHEN expected_product_rows =
             (SELECT COUNT(*) FROM dim_product)
        THEN 'Passed'
        ELSE 'Failed'
    END
FROM source_dimension_counts

UNION ALL

SELECT
    'dim_geography',
    expected_geography_rows,
    (SELECT COUNT(*) FROM dim_geography),
    CASE
        WHEN expected_geography_rows =
             (SELECT COUNT(*) FROM dim_geography)
        THEN 'Passed'
        ELSE 'Failed'
    END
FROM source_dimension_counts;


/* 4. Referential-integrity audit */

SELECT
    SUM(
        CASE WHEN order_date_dimension.date_key IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_order_dates,

    SUM(
        CASE WHEN ship_date_dimension.date_key IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_ship_dates,

    SUM(
        CASE WHEN customer_dimension.customer_key IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_customers,

    SUM(
        CASE WHEN product_dimension.product_key IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_products,

    SUM(
        CASE WHEN geography_dimension.geography_key IS NULL
             THEN 1 ELSE 0 END
    ) AS missing_geographies

FROM fact_sales AS fact

LEFT JOIN dim_date AS order_date_dimension
    ON fact.order_date_key = order_date_dimension.date_key

LEFT JOIN dim_date AS ship_date_dimension
    ON fact.ship_date_key = ship_date_dimension.date_key

LEFT JOIN dim_customer AS customer_dimension
    ON fact.customer_key = customer_dimension.customer_key

LEFT JOIN dim_product AS product_dimension
    ON fact.product_key = product_dimension.product_key

LEFT JOIN dim_geography AS geography_dimension
    ON fact.geography_key = geography_dimension.geography_key;


/* 5. Validated analytical baseline */

SELECT
    COUNT(*) AS sales_lines,
    COUNT(DISTINCT order_key) AS analytical_orders,
    COUNT(DISTINCT customer_key) AS customers,
    COUNT(DISTINCT product_key) AS products,
    SUM(quantity) AS total_quantity,
    COUNT(
        DISTINCT CASE
            WHEN is_returned = 1 THEN order_key
        END
    ) AS returned_orders,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        100 * SUM(profit) / NULLIF(SUM(sales), 0),
        2
    ) AS profit_margin_percentage
FROM fact_sales;