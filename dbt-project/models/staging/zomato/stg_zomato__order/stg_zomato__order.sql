WITH source AS (
    SELECT * FROM {{ ref('orders') }}
)

SELECT
    TRY_CAST(order_id AS BIGINT) AS order_id
    , TRY_CAST(order_timestamp AS TIMESTAMP) AS order_timestamp
    , TRY_CAST(order_date AS DATE) AS order_date
    , TRY_CAST(user_id AS BIGINT) AS customer_id
    , TRY_CAST(r_id AS BIGINT) AS restaurant_id
    , TRIM(REGEXP_EXTRACT(restaurant_city, '[^,]+$')) AS city
    , TRIM(cuisine) AS cuisine
    , TRY_CAST(items_count AS BIGINT) AS items_count
    , TRY_CAST(sales_qty AS BIGINT) AS sales_qty
    , TRY_CAST(subtotal AS DECIMAL(18, 2)) AS subtotal
    , TRY_CAST(discount AS DECIMAL(18, 2)) AS discount
    , TRY_CAST(delivery_fee AS DECIMAL(18, 2)) AS delivery_fee
    , TRY_CAST(gst AS DECIMAL(18, 2)) AS gst
    , TRY_CAST(sales_amount AS DECIMAL(18, 2)) AS sales_amount
    , UPPER(TRIM(currency)) AS currency
    , TRIM(payment_method) AS payment_method
    , UPPER(LEFT(TRIM(order_status), 1)) || LOWER(SUBSTR(TRIM(order_status), 2)) AS order_status
    , UPPER(TRIM(order_status)) = 'DELIVERED' AS is_delivered
    , UPPER(TRIM(order_status)) = 'CANCELLED' AS is_cancelled
    , UPPER(TRIM(order_status)) = 'REFUNDED' AS is_refunded
    , TRY_CAST(customer_rating AS DECIMAL(5, 2)) AS customer_rating
    , TRY_CAST(delivery_time_min AS DECIMAL(10, 1)) AS delivery_time_min
FROM source
