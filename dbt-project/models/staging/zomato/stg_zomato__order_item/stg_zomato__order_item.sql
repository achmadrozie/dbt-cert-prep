WITH source AS (
    SELECT * FROM {{ ref('order_items') }}
)

SELECT
    TRY_TO_NUMBER(order_item_id) AS order_item_id
    , TRY_TO_NUMBER(order_id) AS order_id
    , TRY_TO_NUMBER(r_id) AS restaurant_id
    , TRIM(f_id) AS f_id
    , TRY_TO_DECIMAL(price, 18, 2) AS price
    , TRY_TO_NUMBER(quantity) AS quantity
    , TRY_TO_DECIMAL(line_amount, 18, 2) AS line_amount
FROM source
