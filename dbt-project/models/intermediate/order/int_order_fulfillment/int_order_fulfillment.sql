SELECT
    order_id
    , order_status
    , is_delivered
    , is_cancelled
    , is_refunded
    , customer_rating
    , delivery_time_min
    , IFF(is_delivered, delivery_time_min, NULL) AS delivered_time_min
    , IFF(is_delivered, customer_rating, NULL) AS delivered_customer_rating
FROM {{ ref('stg_zomato__order') }}
