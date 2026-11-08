SELECT
    order_id
    , order_timestamp AS order_timestamp_source
    , order_date
    , HOUR(order_timestamp) AS order_hour_source
    , customer_id
    , restaurant_id
    , city
    , cuisine
    , currency
    , payment_method
    , items_count AS source_items_count
    , sales_qty AS source_sales_qty
FROM {{ ref('stg_zomato__order') }}
