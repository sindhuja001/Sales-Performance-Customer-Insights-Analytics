/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 02_product_and_profitability_analysis.sql
Purpose: Analyze category, product, discount and return profitability.
*/

USE ecommerce_analytics;


/* ============================================================
   Query 06: Category Revenue and Profitability
   Business Question:
   Which categories contribute the most revenue and profit,
   and which category has the weakest margin?
   ============================================================ */

WITH category_performance AS (
    SELECT
        product.category,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        SUM(fact.quantity) AS quantity,
        COUNT(DISTINCT fact.order_key) AS orders,
        COUNT(DISTINCT fact.product_key) AS products
    FROM fact_sales AS fact
    INNER JOIN dim_product AS product
        ON fact.product_key = product.product_key
    GROUP BY product.category
)

SELECT
    category,
    revenue,
    profit,
    quantity,
    orders,
    products,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        100 * revenue /
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS revenue_share_percentage,

    ROUND(
        100 * profit /
        NULLIF(SUM(profit) OVER (), 0),
        2
    ) AS profit_share_percentage,

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

FROM category_performance
ORDER BY revenue_rank;

/* ============================================================
   Query 07: Sub-Category Profitability Diagnosis
   Business Question:
   Which sub-categories generate strong sales but weak or
   negative profit?
   ============================================================ */

WITH sub_category_performance AS (
    SELECT
        product.category,
        product.sub_category,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        SUM(fact.quantity) AS quantity,
        COUNT(DISTINCT fact.order_key) AS orders,

        ROUND(
            100 * AVG(fact.discount),
            2
        ) AS average_discount_percentage

    FROM fact_sales AS fact

    INNER JOIN dim_product AS product
        ON fact.product_key = product.product_key

    GROUP BY
        product.category,
        product.sub_category
)

SELECT
    category,
    sub_category,
    revenue,
    profit,
    quantity,
    orders,
    average_discount_percentage,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    CASE
        WHEN profit < 0 THEN 'Loss-Making'
        WHEN profit = 0 THEN 'Break-Even'
        ELSE 'Profitable'
    END AS profitability_status,

    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY profit DESC
    ) AS profit_rank

FROM sub_category_performance
ORDER BY
    profit ASC,
    revenue DESC;
    
/* ============================================================
   Query 08: High-Revenue Loss-Making Products
   Business Question:
   Which products generate substantial revenue but still
   destroy profit?
   ============================================================ */

WITH product_performance AS (
    SELECT
        product.product_name,
        product.category,
        product.sub_category,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,

        ROUND(
            100 * AVG(fact.discount),
            2
        ) AS average_discount_percentage

    FROM fact_sales AS fact

    INNER JOIN dim_product AS product
        ON fact.product_key = product.product_key

    GROUP BY
        product.product_key,
        product.product_name,
        product.category,
        product.sub_category
),

loss_making_products AS (
    SELECT
        product_performance.*,

        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS loss_product_revenue_rank

    FROM product_performance
    WHERE profit < 0
)

SELECT
    loss_product_revenue_rank,
    product_name,
    category,
    sub_category,
    revenue,
    profit,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    average_discount_percentage,
    orders

FROM loss_making_products

WHERE loss_product_revenue_rank <= 10

ORDER BY loss_product_revenue_rank;

/* ============================================================
   Query 09: Discount Band Profitability
   Business Question:
   At what discount levels do margins and loss rates
   materially deteriorate?
   ============================================================ */

WITH classified_sales AS (
    SELECT
        sales,
        profit,
        quantity,
        discount,

        CASE
            WHEN discount = 0
                THEN 'No Discount'

            WHEN discount <= 0.10
                THEN 'Low (>0% to 10%)'

            WHEN discount <= 0.20
                THEN 'Moderate (>10% to 20%)'

            WHEN discount <= 0.30
                THEN 'High (>20% to 30%)'

            ELSE 'Very High (>30%)'
        END AS discount_band,

        CASE
            WHEN discount = 0 THEN 1
            WHEN discount <= 0.10 THEN 2
            WHEN discount <= 0.20 THEN 3
            WHEN discount <= 0.30 THEN 4
            ELSE 5
        END AS discount_band_order,

        CASE
            WHEN profit < 0 THEN 1
            ELSE 0
        END AS is_loss_line

    FROM fact_sales
),

discount_performance AS (
    SELECT
        discount_band,
        discount_band_order,
        COUNT(*) AS sales_lines,
        ROUND(SUM(sales), 2) AS revenue,
        ROUND(SUM(profit), 2) AS profit,
        SUM(quantity) AS quantity,

        ROUND(
            100 * AVG(discount),
            2
        ) AS average_discount_percentage,

        SUM(is_loss_line) AS loss_lines

    FROM classified_sales

    GROUP BY
        discount_band,
        discount_band_order
)

SELECT
    discount_band,
    sales_lines,
    revenue,
    profit,
    quantity,
    average_discount_percentage,
    loss_lines,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage,

    ROUND(
        100 * loss_lines / NULLIF(sales_lines, 0),
        2
    ) AS loss_line_rate_percentage,

    ROUND(
        100 * revenue /
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS revenue_share_percentage

FROM discount_performance

ORDER BY discount_band_order;

/* ============================================================
   Query 10: Highest Returned-Order Association Rates
   Business Question:
   Which sufficiently established products have the highest
   returned-order association rates?

   Important limitation:
   Returns are available only at Order ID level. Therefore,
   this analysis measures product association with returned
   orders; it does not prove that the product caused the return.
   ============================================================ */
   
WITH product_order_associations AS (
    SELECT
        product.product_name,
        product.category,
        product.sub_category,

        COUNT(
            DISTINCT fact.order_key
        ) AS total_orders,

        COUNT(
            DISTINCT CASE
                WHEN fact.is_returned = 1
                THEN fact.order_key
            END
        ) AS returned_order_associations

    FROM fact_sales AS fact

    INNER JOIN dim_product AS product
        ON fact.product_key = product.product_key

    GROUP BY
        product.product_key,
        product.product_name,
        product.category,
        product.sub_category
),

eligible_products AS (
    SELECT
        product_order_associations.*,

        ROUND(
            100 * returned_order_associations /
            NULLIF(total_orders, 0),
            2
        ) AS returned_order_association_rate,

        ROW_NUMBER() OVER (
            ORDER BY
                returned_order_associations /
                NULLIF(total_orders, 0) DESC,
                returned_order_associations DESC,
                product_name
        ) AS association_rate_rank

    FROM product_order_associations

    WHERE total_orders >= 20
)

SELECT
    association_rate_rank,
    product_name,
    category,
    sub_category,
    total_orders,
    returned_order_associations,
    returned_order_association_rate

FROM eligible_products

WHERE association_rate_rank <= 10

ORDER BY association_rate_rank;