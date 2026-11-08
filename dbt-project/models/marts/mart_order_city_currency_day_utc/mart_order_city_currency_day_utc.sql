SELECT
    order_date AS order_date_utc
    , city
    , currency
    , COUNT(*) AS order_count
    , COALESCE(COUNT_IF(is_delivered), 0) AS delivered_order_count
    , COALESCE(COUNT_IF(is_cancelled), 0) AS cancelled_order_count
    , COALESCE(COUNT_IF(is_refunded), 0) AS refunded_order_count
    , SUM(delivered_sales_amount) AS delivered_sales_amount
FROM {{ ref('fact_order') }}
GROUP BY order_date, city, currency
