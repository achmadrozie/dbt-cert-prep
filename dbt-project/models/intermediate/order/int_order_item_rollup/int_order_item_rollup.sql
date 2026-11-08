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
    , TRY_CAST(SUM(line_amount) AS DECIMAL(18, 2)) AS item_line_amount
    , TRY_CAST(SUM(price * quantity) AS DECIMAL(18, 2)) AS calculated_item_amount
    , TRY_CAST((SUM(line_amount) - SUM(price * quantity)) AS DECIMAL(18, 2)) AS item_amount_delta
FROM order_items
GROUP BY order_id
