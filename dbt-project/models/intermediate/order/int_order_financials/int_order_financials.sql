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
    , (subtotal - discount + delivery_fee + gst)::NUMBER(18, 2) AS calculated_sales_amount
    , (sales_amount - (subtotal - discount + delivery_fee + gst))::NUMBER(18, 2) AS sales_amount_delta
    , IFF(is_delivered, sales_amount, 0::NUMBER(18, 2)) AS delivered_sales_amount
FROM orders
