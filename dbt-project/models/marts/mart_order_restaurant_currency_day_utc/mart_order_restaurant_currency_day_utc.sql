SELECT
    order_date AS order_date_utc
    , restaurant_id
    , currency
    , COUNT(*) AS order_count
    , COALESCE(COUNT_IF(is_delivered), 0) AS delivered_order_count
    , COALESCE(COUNT_IF(is_cancelled), 0) AS cancelled_order_count
    , COALESCE(COUNT_IF(is_refunded), 0) AS refunded_order_count
    , SUM(delivered_sales_amount) AS delivered_sales_amount
    , COALESCE(SUM(customer_rating), 0) AS customer_rating_sum
    , COUNT(customer_rating) AS customer_rating_observation_count
    , COALESCE(SUM(IFF(is_delivered, delivery_time_min, NULL)), 0) AS delivery_time_sum_min
    , COUNT(IFF(is_delivered, delivery_time_min, NULL)) AS delivery_time_observation_count
FROM {{ ref('fact_order') }}
GROUP BY order_date, restaurant_id, currency
