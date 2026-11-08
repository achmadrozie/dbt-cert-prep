WITH order_items AS (
    SELECT
        order_id
        , f_id
        , price
        , quantity
        , line_amount
    FROM {{ ref('stg_zomato__order_item') }}
)

SELECT
    order_id
    , COUNT(*) AS item_line_count
    , SUM(quantity) AS item_quantity
    , COUNT(DISTINCT f_id) AS distinct_food_count
    , SUM(line_amount)::NUMBER(18, 2) AS item_line_amount
    , SUM(price * quantity)::NUMBER(18, 2) AS calculated_item_amount
    , (SUM(line_amount) - SUM(price * quantity))::NUMBER(18, 2) AS item_amount_delta
FROM order_items
GROUP BY order_id
