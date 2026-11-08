WITH source AS (
    SELECT * FROM {{ ref('order_items') }}
)

SELECT
    TRY_CAST(order_item_id AS BIGINT) AS order_item_id
    , TRY_CAST(order_id AS BIGINT) AS order_id
    , TRY_CAST(r_id AS BIGINT) AS restaurant_id
    , TRIM(f_id) AS f_id
    , TRY_CAST(price AS DECIMAL(18, 2)) AS price
    , TRY_CAST(quantity AS BIGINT) AS quantity
    , TRY_CAST(line_amount AS DECIMAL(18, 2)) AS line_amount
FROM source
