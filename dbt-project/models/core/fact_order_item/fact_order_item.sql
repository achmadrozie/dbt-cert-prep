SELECT
    oi.order_item_id
    , oi.order_id
    , oi.restaurant_id
    , oi.f_id AS food_id
    , b.order_timestamp_source AS order_ts
    , b.order_date
    , b.city
    , oi.price
    , oi.quantity
    , oi.line_amount
    , (oi.price * oi.quantity)::NUMBER(18, 2) AS calculated_line_amount
    , (oi.line_amount - oi.price * oi.quantity)::NUMBER(18, 2) AS line_amount_delta
FROM {{ ref('stg_zomato__order_item') }} AS oi
LEFT JOIN {{ ref('int_order_base') }} AS b
    ON oi.order_id = b.order_id
