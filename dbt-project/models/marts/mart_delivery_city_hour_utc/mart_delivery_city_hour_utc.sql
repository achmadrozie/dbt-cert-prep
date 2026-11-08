SELECT
    DATE_TRUNC('HOUR', order_timestamp) AS order_hour_utc
    , city
    , COUNT(*) AS delivered_order_count
    , COALESCE(SUM(delivery_time_min), 0) AS delivery_time_sum_min
    , COUNT(delivery_time_min) AS delivery_time_observation_count
FROM {{ ref('fact_order') }}
WHERE is_delivered
GROUP BY DATE_TRUNC('HOUR', order_timestamp), city
