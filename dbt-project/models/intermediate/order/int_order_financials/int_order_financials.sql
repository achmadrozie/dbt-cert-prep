WITH orders AS (
    SELECT
        order_id
        , subtotal
        , discount
        , delivery_fee
        , gst
        , sales_amount
        , is_delivered
    FROM {{ ref('stg_zomato__order') }}
)

SELECT
    order_id
    , subtotal
    , discount
    , delivery_fee
    , gst
    , sales_amount
    , TRY_CAST(subtotal - discount + delivery_fee + gst AS DECIMAL(18,2)) AS calculated_sales_amount
    , TRY_CAST(sales_amount - (subtotal - discount + delivery_fee + gst) AS DECIMAL(18,2)) AS sales_amount_delta
    , TRY_CAST(IF(is_delivered, sales_amount, 0) AS DECIMAL(18,2)) AS delivered_sales_amount
FROM orders
