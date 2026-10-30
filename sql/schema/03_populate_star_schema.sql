/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 03_populate_star_schema.sql
Purpose: Populate the analytical dimensions and fact table from stg_orders.
*/

USE ecommerce_analytics;

SET SESSION cte_max_recursion_depth = 2000;
SET SESSION lc_time_names = 'en_US';

SET @minimum_date = (
    SELECT LEAST(
        MIN(order_date),
        MIN(ship_date)
    )
    FROM stg_orders
);

SET @maximum_date = (
    SELECT GREATEST(
        MAX(order_date),
        MAX(ship_date)
    )
    FROM stg_orders
);

INSERT INTO dim_date (
    date_key,
    full_date,
    calendar_year,
    calendar_quarter,
    month_number,
    month_name,
    calendar_year_month,
    day_of_month,
    day_name,
    week_of_year,
    is_weekend
)
WITH RECURSIVE calendar_dates AS (
    SELECT CAST(@minimum_date AS DATE) AS full_date

    UNION ALL

    SELECT DATE_ADD(full_date, INTERVAL 1 DAY)
    FROM calendar_dates
    WHERE full_date < CAST(@maximum_date AS DATE)
)
SELECT
    CAST(DATE_FORMAT(cd.full_date, '%Y%m%d') AS UNSIGNED),
    cd.full_date,
    YEAR(cd.full_date),
    CONCAT('Q', QUARTER(cd.full_date)),
    MONTH(cd.full_date),
    DATE_FORMAT(cd.full_date, '%M'),
    DATE_FORMAT(cd.full_date, '%Y-%m'),
    DAY(cd.full_date),
    DAYNAME(cd.full_date),
    WEEKOFYEAR(cd.full_date),
    CASE
        WHEN WEEKDAY(cd.full_date) IN (5, 6) THEN 1
        ELSE 0
    END
FROM calendar_dates AS cd
LEFT JOIN dim_date AS existing_date
    ON cd.full_date = existing_date.full_date
WHERE existing_date.full_date IS NULL
ORDER BY cd.full_date;

INSERT INTO dim_customer (
    customer_key,
    customer_name,
    segment
)
SELECT DISTINCT
    source.customer_key,
    source.customer_name,
    source.segment
FROM stg_orders AS source
LEFT JOIN dim_customer AS existing_customer
    ON source.customer_key = existing_customer.customer_key
WHERE existing_customer.customer_key IS NULL
ORDER BY source.customer_key;

INSERT INTO dim_product (
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT
    source.product_id,
    source.product_name,
    source.category,
    source.sub_category
FROM stg_orders AS source
LEFT JOIN dim_product AS existing_product
    ON source.product_id = existing_product.product_id
WHERE existing_product.product_id IS NULL
ORDER BY source.product_id;

INSERT INTO dim_geography (
    geography_business_key,
    postal_code,
    city,
    state,
    country,
    region,
    market,
    regional_manager,
    manager_mapping_status
)
SELECT DISTINCT
    CONCAT_WS(
        '|',
        COALESCE(source.postal_code, ''),
        source.city,
        source.state,
        source.country,
        source.region,
        source.market
    ) AS geography_business_key,
    source.postal_code,
    source.city,
    source.state,
    source.country,
    source.region,
    source.market,
    source.regional_manager,
    source.manager_mapping_status
FROM stg_orders AS source
LEFT JOIN dim_geography AS existing_geography
    ON existing_geography.geography_business_key =
        CONCAT_WS(
            '|',
            COALESCE(source.postal_code, ''),
            source.city,
            source.state,
            source.country,
            source.region,
            source.market
        )
WHERE existing_geography.geography_key IS NULL
ORDER BY
    source.country,
    source.state,
    source.city,
    source.postal_code;
INSERT INTO fact_sales (
    row_id,
    order_key,
    order_id,
    customer_id,
    order_date_key,
    ship_date_key,
    customer_key,
    product_key,
    geography_key,
    ship_mode,
    order_priority,
    shipping_days,
    quantity,
    sales,
    sales_per_unit,
    discount,
    profit,
    line_profit_margin,
    profit_status,
    shipping_cost,
    is_returned
)
SELECT
    source.row_id,
    source.order_key,
    source.order_id,
    source.customer_id,
    order_date_dimension.date_key,
    ship_date_dimension.date_key,
    customer_dimension.customer_key,
    product_dimension.product_key,
    geography_dimension.geography_key,
    source.ship_mode,
    source.order_priority,
    source.shipping_days,
    source.quantity,
    source.sales,
    source.sales_per_unit,
    source.discount,
    source.profit,
    source.line_profit_margin,
    source.profit_status,
    source.shipping_cost,
    CASE
        WHEN LOWER(source.is_returned) = 'true' THEN 1
        ELSE 0
    END
FROM stg_orders AS source

INNER JOIN dim_date AS order_date_dimension
    ON source.order_date = order_date_dimension.full_date

INNER JOIN dim_date AS ship_date_dimension
    ON source.ship_date = ship_date_dimension.full_date

INNER JOIN dim_customer AS customer_dimension
    ON source.customer_key = customer_dimension.customer_key

INNER JOIN dim_product AS product_dimension
    ON source.product_id = product_dimension.product_id

INNER JOIN dim_geography AS geography_dimension
    ON geography_dimension.geography_business_key =
        CONCAT_WS(
            '|',
            COALESCE(source.postal_code, ''),
            source.city,
            source.state,
            source.country,
            source.region,
            source.market
        )

LEFT JOIN fact_sales AS existing_fact
    ON source.row_id = existing_fact.row_id

WHERE existing_fact.row_id IS NULL

ORDER BY source.row_id;    