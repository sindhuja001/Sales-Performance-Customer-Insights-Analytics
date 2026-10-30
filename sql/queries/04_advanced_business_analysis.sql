/*
Project: E-commerce Sales, Customer Behaviour and Profitability Analytics
Script: 04_advanced_business_analysis.sql
Purpose: Perform RFM segmentation, cohort retention,
         basket analysis and geographic profitability analysis.
*/

USE ecommerce_analytics;


/* ============================================================
   Query 16: RFM Customer Segmentation
   Business Question:
   How can customers be segmented using recency, frequency
   and monetary value for targeted retention actions?
   ============================================================ */

WITH analysis_snapshot AS (
    SELECT
        DATE_ADD(
            MAX(order_date.full_date),
            INTERVAL 1 DAY
        ) AS snapshot_date

    FROM fact_sales AS fact

    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key
),

customer_rfm_metrics AS (
    SELECT
        customer.customer_key,
        customer.customer_name,
        customer.segment,

        DATEDIFF(
            snapshot.snapshot_date,
            MAX(order_date.full_date)
        ) AS recency_days,

        COUNT(
            DISTINCT fact.order_key
        ) AS frequency,

        ROUND(
            SUM(fact.sales),
            2
        ) AS monetary,

        ROUND(
            SUM(fact.profit),
            2
        ) AS profit

    FROM fact_sales AS fact

    INNER JOIN dim_customer AS customer
        ON fact.customer_key = customer.customer_key

    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key

    CROSS JOIN analysis_snapshot AS snapshot

    GROUP BY
        customer.customer_key,
        customer.customer_name,
        customer.segment,
        snapshot.snapshot_date
),

rank_components AS (
    SELECT
        customer_rfm_metrics.*,

        RANK() OVER (
            ORDER BY recency_days
        ) AS recency_minimum_rank,

        COUNT(*) OVER (
            PARTITION BY recency_days
        ) AS recency_tie_count,

        RANK() OVER (
            ORDER BY frequency
        ) AS frequency_minimum_rank,

        COUNT(*) OVER (
            PARTITION BY frequency
        ) AS frequency_tie_count,

        RANK() OVER (
            ORDER BY monetary
        ) AS monetary_minimum_rank,

        COUNT(*) OVER (
            PARTITION BY monetary
        ) AS monetary_tie_count,

        COUNT(*) OVER () AS customer_count

    FROM customer_rfm_metrics
),

percentile_metrics AS (
    SELECT
        rank_components.*,

        (
            recency_minimum_rank
            + (recency_tie_count - 1) / 2.0
        ) / customer_count AS recency_percentile,

        (
            frequency_minimum_rank
            + (frequency_tie_count - 1) / 2.0
        ) / customer_count AS frequency_percentile,

        (
            monetary_minimum_rank
            + (monetary_tie_count - 1) / 2.0
        ) / customer_count AS monetary_percentile

    FROM rank_components
),

scored_customers AS (
    SELECT
        percentile_metrics.*,

        CASE
            WHEN recency_percentile <= 0.20 THEN 5
            WHEN recency_percentile <= 0.40 THEN 4
            WHEN recency_percentile <= 0.60 THEN 3
            WHEN recency_percentile <= 0.80 THEN 2
            ELSE 1
        END AS recency_score,

        CASE
            WHEN frequency_percentile <= 0.20 THEN 1
            WHEN frequency_percentile <= 0.40 THEN 2
            WHEN frequency_percentile <= 0.60 THEN 3
            WHEN frequency_percentile <= 0.80 THEN 4
            ELSE 5
        END AS frequency_score,

        CASE
            WHEN monetary_percentile <= 0.20 THEN 1
            WHEN monetary_percentile <= 0.40 THEN 2
            WHEN monetary_percentile <= 0.60 THEN 3
            WHEN monetary_percentile <= 0.80 THEN 4
            ELSE 5
        END AS monetary_score

    FROM percentile_metrics
),

segmented_customers AS (
    SELECT
        scored_customers.*,

        recency_score
        + frequency_score
        + monetary_score AS rfm_total_score,

        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 3
             AND frequency_score >= 4
             AND monetary_score >= 3
                THEN 'Loyal High-Value'

            WHEN recency_score >= 4
             AND monetary_score >= 4
                THEN 'Recent High Spenders'

            WHEN recency_score >= 4
             AND frequency_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN recency_score <= 2
             AND frequency_score >= 4
                THEN 'At Risk'

            WHEN recency_score <= 2
             AND frequency_score <= 2
                THEN 'Hibernating'

            ELSE 'Needs Attention'
        END AS rfm_segment

    FROM scored_customers
),

segment_performance AS (
    SELECT
        rfm_segment,
        COUNT(*) AS customers,
        ROUND(SUM(monetary), 2) AS revenue,
        ROUND(SUM(profit), 2) AS profit,
        ROUND(AVG(recency_days), 1)
            AS average_recency_days,
        ROUND(AVG(frequency), 1)
            AS average_orders

    FROM segmented_customers

    GROUP BY rfm_segment
)

SELECT
    rfm_segment,
    customers,
    revenue,
    profit,
    average_recency_days,
    average_orders,

    ROUND(
        100 * customers /
        NULLIF(SUM(customers) OVER (), 0),
        2
    ) AS customer_share_percentage,

    ROUND(
        100 * revenue /
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS revenue_share_percentage,

    ROUND(
        100 * profit / NULLIF(revenue, 0),
        2
    ) AS profit_margin_percentage

FROM segment_performance

ORDER BY revenue DESC;

/* ============================================================
   Query 17: Twelve-Month Cohort Activity Retention
   Business Question:
   What percentage of customers acquired in sufficiently large
   cohorts remained active in each relative purchase month?

   Method:
   Only acquisition cohorts with at least 20 customers are
   included to reduce instability from very small cohorts.
   ============================================================ */

WITH RECURSIVE customer_month_activity AS (
    SELECT DISTINCT
        fact.customer_key,

        STR_TO_DATE(
            CONCAT(
                order_date.calendar_year_month,
                '-01'
            ),
            '%Y-%m-%d'
        ) AS activity_month

    FROM fact_sales AS fact

    INNER JOIN dim_date AS order_date
        ON fact.order_date_key = order_date.date_key
),

latest_activity_month AS (
    SELECT
        MAX(activity_month) AS latest_activity_month
    FROM customer_month_activity
),

customer_cohorts AS (
    SELECT
        customer_key,
        MIN(activity_month) AS cohort_month
    FROM customer_month_activity
    GROUP BY customer_key
),

eligible_cohorts AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
    HAVING COUNT(*) >= 20
),

observed_cohort_activity AS (
    SELECT
        cohort.cohort_month,

        TIMESTAMPDIFF(
            MONTH,
            cohort.cohort_month,
            activity.activity_month
        ) + 1 AS cohort_month_number,

        COUNT(
            DISTINCT activity.customer_key
        ) AS active_customers

    FROM customer_month_activity AS activity

    INNER JOIN customer_cohorts AS cohort
        ON activity.customer_key = cohort.customer_key

    WHERE
        TIMESTAMPDIFF(
            MONTH,
            cohort.cohort_month,
            activity.activity_month
        ) + 1 BETWEEN 1 AND 12

    GROUP BY
        cohort.cohort_month,
        TIMESTAMPDIFF(
            MONTH,
            cohort.cohort_month,
            activity.activity_month
        ) + 1
),

month_numbers AS (
    SELECT 1 AS cohort_month_number

    UNION ALL

    SELECT cohort_month_number + 1
    FROM month_numbers
    WHERE cohort_month_number < 12
),

complete_eligible_grid AS (
    SELECT
        eligible.cohort_month,
        eligible.cohort_size,
        month_numbers.cohort_month_number

    FROM eligible_cohorts AS eligible

    CROSS JOIN month_numbers

    CROSS JOIN latest_activity_month AS observation_window

    WHERE month_numbers.cohort_month_number <=
        TIMESTAMPDIFF(
            MONTH,
            eligible.cohort_month,
            observation_window.latest_activity_month
        ) + 1
)

SELECT
    grid.cohort_month_number,
    COUNT(*) AS eligible_cohorts,

    SUM(
        COALESCE(
            activity.active_customers,
            0
        )
    ) AS active_customers,

    SUM(grid.cohort_size)
        AS eligible_customers,

    ROUND(
        100 * SUM(
            COALESCE(
                activity.active_customers,
                0
            )
        ) /
        NULLIF(SUM(grid.cohort_size), 0),
        2
    ) AS weighted_retention_percentage

FROM complete_eligible_grid AS grid

LEFT JOIN observed_cohort_activity AS activity
    ON grid.cohort_month =
       activity.cohort_month
   AND grid.cohort_month_number =
       activity.cohort_month_number

GROUP BY grid.cohort_month_number

ORDER BY grid.cohort_month_number;

/* ============================================================
   Query 18: Sub-Category Market Basket Analysis
   Business Question:
   Which sub-categories appear together more often than
   expected and may support cross-selling experiments?

   Method:
   Product-level pairs are too sparse for reliable action.
   This query analyzes broader sub-category combinations and
   requires at least 50 shared orders.
   ============================================================ */

WITH order_sub_categories AS (
    SELECT DISTINCT
        fact.order_key,
        product.sub_category

    FROM fact_sales AS fact

    INNER JOIN dim_product AS product
        ON fact.product_key = product.product_key
),

pair_order_counts AS (
    SELECT
        first_item.sub_category
            AS sub_category_a,

        second_item.sub_category
            AS sub_category_b,

        COUNT(*) AS pair_orders

    FROM order_sub_categories AS first_item

    INNER JOIN order_sub_categories AS second_item
        ON first_item.order_key =
           second_item.order_key

       AND first_item.sub_category <
           second_item.sub_category

    GROUP BY
        first_item.sub_category,
        second_item.sub_category
),

sub_category_order_counts AS (
    SELECT
        sub_category,
        COUNT(*) AS sub_category_orders

    FROM order_sub_categories

    GROUP BY sub_category
),

total_order_count AS (
    SELECT
        COUNT(DISTINCT order_key) AS total_orders
    FROM fact_sales
),

pair_metrics AS (
    SELECT
        pair.sub_category_a,
        pair.sub_category_b,
        pair.pair_orders,
        first_count.sub_category_orders
            AS sub_category_a_orders,
        second_count.sub_category_orders
            AS sub_category_b_orders,
        total_order_count.total_orders,

        (
            CAST(
                pair.pair_orders AS DECIMAL(20, 10)
            )
            * total_order_count.total_orders
        )
        / NULLIF(
            first_count.sub_category_orders
            * second_count.sub_category_orders,
            0
        ) AS lift

    FROM pair_order_counts AS pair

    INNER JOIN sub_category_order_counts AS first_count
        ON pair.sub_category_a =
           first_count.sub_category

    INNER JOIN sub_category_order_counts AS second_count
        ON pair.sub_category_b =
           second_count.sub_category

    CROSS JOIN total_order_count
),

eligible_pairs AS (
    SELECT
        pair_metrics.*,

        ROW_NUMBER() OVER (
            ORDER BY
                lift DESC,
                pair_orders DESC
        ) AS lift_rank

    FROM pair_metrics

    WHERE pair_orders >= 50
      AND lift > 1
)

SELECT
    lift_rank,
    sub_category_a,
    sub_category_b,
    pair_orders,

    ROUND(
        100 * pair_orders /
        NULLIF(total_orders, 0),
        2
    ) AS support_percentage,

    ROUND(
        100 * pair_orders /
        NULLIF(sub_category_a_orders, 0),
        2
    ) AS confidence_a_to_b_percentage,

    ROUND(
        100 * pair_orders /
        NULLIF(sub_category_b_orders, 0),
        2
    ) AS confidence_b_to_a_percentage,

    ROUND(lift, 2) AS lift

FROM eligible_pairs

WHERE lift_rank <= 10

ORDER BY lift_rank;

/* ============================================================
   Query 19: Best and Worst Countries by Profit
   Business Question:
   Which countries create the most profit, and which countries
   create the largest cumulative losses?
   ============================================================ */

WITH country_performance AS (
    SELECT
        geography.country,
        geography.market,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,

        ROUND(
            100 * AVG(fact.discount),
            2
        ) AS average_discount_percentage

    FROM fact_sales AS fact

    INNER JOIN dim_geography AS geography
        ON fact.geography_key = geography.geography_key

    GROUP BY
        geography.country,
        geography.market
),

ranked_countries AS (
    SELECT
        country_performance.*,

        ROW_NUMBER() OVER (
            ORDER BY profit DESC
        ) AS profit_rank,

        ROW_NUMBER() OVER (
            ORDER BY profit ASC
        ) AS loss_rank,

        SUM(
            CASE
                WHEN profit < 0 THEN 1
                ELSE 0
            END
        ) OVER () AS loss_making_country_count,

        SUM(
            CASE
                WHEN profit < 0 THEN profit
                ELSE 0
            END
        ) OVER () AS combined_loss_from_loss_making_countries

    FROM country_performance
),

selected_countries AS (
    SELECT
        CASE
            WHEN profit_rank <= 10
                THEN 'Top 10 by Profit'
            ELSE 'Bottom 10 by Profit'
        END AS performance_group,

        CASE
            WHEN profit_rank <= 10
                THEN profit_rank
            ELSE loss_rank
        END AS performance_rank,

        country,
        market,
        revenue,
        profit,
        orders,
        average_discount_percentage,

        ROUND(
            100 * profit / NULLIF(revenue, 0),
            2
        ) AS profit_margin_percentage,

        loss_making_country_count,

        ROUND(
            combined_loss_from_loss_making_countries,
            2
        ) AS combined_loss_from_loss_making_countries

    FROM ranked_countries

    WHERE profit_rank <= 10
       OR loss_rank <= 10
)

SELECT
    performance_group,
    performance_rank,
    country,
    market,
    revenue,
    profit,
    profit_margin_percentage,
    orders,
    average_discount_percentage,
    loss_making_country_count,
    combined_loss_from_loss_making_countries

FROM selected_countries

ORDER BY
    CASE
        WHEN performance_group = 'Top 10 by Profit'
            THEN 1
        ELSE 2
    END,
    performance_rank;
    
/* ============================================================
   Query 20: Regional Manager Performance
   Business Question:
   Which regions and managers lead or lag in profit, margin,
   discounts and returned-order rates?
   Important limitation:
   Regional results are attributed to the assigned manager for
   reporting purposes; they do not prove that the manager caused
   the observed performance. Canada has no available manager mapping.
   ============================================================ */

WITH regional_performance AS (
    SELECT
        geography.region,
        geography.market,
        geography.regional_manager,
        geography.manager_mapping_status,
        ROUND(SUM(fact.sales), 2) AS revenue,
        ROUND(SUM(fact.profit), 2) AS profit,
        COUNT(DISTINCT fact.order_key) AS orders,

        COUNT(
            DISTINCT CASE
                WHEN fact.is_returned = 1
                THEN fact.order_key
            END
        ) AS returned_orders,

        ROUND(
            100 * AVG(fact.discount),
            2
        ) AS average_discount_percentage

    FROM fact_sales AS fact

    INNER JOIN dim_geography AS geography
        ON fact.geography_key = geography.geography_key

    GROUP BY
        geography.region,
        geography.market,
        geography.regional_manager,
        geography.manager_mapping_status
),

ranked_regions AS (
    SELECT
        regional_performance.*,

        ROW_NUMBER() OVER (
            ORDER BY profit DESC
        ) AS profit_rank,

        ROW_NUMBER() OVER (
            ORDER BY profit ASC
        ) AS bottom_profit_rank

    FROM regional_performance
),

selected_regions AS (
    SELECT
        CASE
            WHEN profit_rank <= 5
                THEN 'Top 5 by Profit'
            ELSE 'Bottom 5 by Profit'
        END AS performance_group,

        CASE
            WHEN profit_rank <= 5
                THEN profit_rank
            ELSE bottom_profit_rank
        END AS performance_rank,

        region,
        market,
        regional_manager,
        manager_mapping_status,
        revenue,
        profit,
        orders,
        returned_orders,
        average_discount_percentage,

        ROUND(
            100 * profit / NULLIF(revenue, 0),
            2
        ) AS profit_margin_percentage,

        ROUND(
            100 * returned_orders /
            NULLIF(orders, 0),
            2
        ) AS return_rate_percentage

    FROM ranked_regions

    WHERE profit_rank <= 5
       OR bottom_profit_rank <= 5
)

SELECT
    performance_group,
    performance_rank,
    region,
    market,
    regional_manager,
    manager_mapping_status,
    revenue,
    profit,
    profit_margin_percentage,
    orders,
    returned_orders,
    return_rate_percentage,
    average_discount_percentage

FROM selected_regions

ORDER BY
    CASE
        WHEN performance_group = 'Top 5 by Profit'
            THEN 1
        ELSE 2
    END,
    performance_rank;