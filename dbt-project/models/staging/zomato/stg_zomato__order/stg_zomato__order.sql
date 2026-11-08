WITH source AS (
    SELECT * FROM {{ ref('orders') }}
)

SELECT
    TRY_TO_NUMBER(order_id) AS order_id
    , TRY_TO_TIMESTAMP_NTZ(order_timestamp) AS order_timestamp
    , TRY_TO_DATE(order_date) AS order_date
    , TRY_TO_NUMBER(user_id) AS customer_id
    , TRY_TO_NUMBER(r_id) AS restaurant_id
    , TRIM(COALESCE(REGEXP_SUBSTR(restaurant_city, '[^,]+$'), restaurant_city)) AS city
    , TRIM(cuisine) AS cuisine
    , TRY_TO_NUMBER(items_count) AS items_count
    , TRY_TO_NUMBER(sales_qty) AS sales_qty
    , TRY_TO_DECIMAL(subtotal, 18, 2) AS subtotal
    , TRY_TO_DECIMAL(discount, 18, 2) AS discount
    , TRY_TO_DECIMAL(delivery_fee, 18, 2) AS delivery_fee
    , TRY_TO_DECIMAL(gst, 18, 2) AS gst
    , TRY_TO_DECIMAL(sales_amount, 18, 2) AS sales_amount
    , UPPER(TRIM(currency)) AS currency
    , TRIM(payment_method) AS payment_method
    , INITCAP(TRIM(order_status)) AS order_status
    , IFF(INITCAP(TRIM(order_status)) = 'Delivered', TRUE, FALSE) AS is_delivered
    , IFF(INITCAP(TRIM(order_status)) = 'Cancelled', TRUE, FALSE) AS is_cancelled
    , IFF(INITCAP(TRIM(order_status)) = 'Refunded', TRUE, FALSE) AS is_refunded
    , TRY_TO_DECIMAL(customer_rating, 5, 2) AS customer_rating
    , TRY_TO_DECIMAL(delivery_time_min, 10, 1) AS delivery_time_min
FROM source
