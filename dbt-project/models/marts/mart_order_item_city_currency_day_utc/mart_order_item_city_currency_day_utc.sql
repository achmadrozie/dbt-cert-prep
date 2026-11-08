SELECT
    i.order_date AS order_date_utc
    , i.city
    , o.currency
    , COUNT(*) AS order_item_count
    , SUM(i.quantity) AS ordered_quantity
    , SUM(i.line_amount) AS source_line_amount
    , SUM(i.calculated_line_amount) AS calculated_line_amount
    , SUM(i.line_amount_delta) AS line_amount_delta
FROM {{ ref('fact_order_item') }} AS i
LEFT JOIN {{ ref('fact_order') }} AS o
    ON i.order_id = o.order_id
GROUP BY i.order_date, i.city, o.currency
