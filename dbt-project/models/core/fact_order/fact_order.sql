SELECT
    b.order_id
    , b.order_timestamp_source AS order_timestamp
    , b.order_date
    , b.order_hour_source AS order_hour
    , b.customer_id
    , b.restaurant_id
    , b.city
    , b.cuisine
    , b.currency
    , b.payment_method
    , u.order_status
    , u.is_delivered
    , u.is_cancelled
    , u.is_refunded
    , b.source_items_count AS items_count
    , b.source_sales_qty AS sales_qty
    , i.item_line_count
    , i.item_quantity
    , i.distinct_food_count
    , f.subtotal
    , f.discount
    , f.delivery_fee
    , f.gst
    , f.sales_amount
    , f.calculated_sales_amount
    , f.sales_amount_delta
    , f.delivered_sales_amount
    , i.item_line_amount
    , i.calculated_item_amount
    , i.item_amount_delta
    , u.customer_rating
    , u.delivery_time_min
FROM {{ ref('int_order_base') }} b
INNER JOIN {{ ref('int_order_financials') }} f USING (order_id)
INNER JOIN {{ ref('int_order_fulfillment') }} u USING (order_id)
LEFT JOIN {{ ref('int_order_item_rollup') }} i USING (order_id)
