WITH source AS (
    SELECT * FROM {{ ref('menu') }}
)

SELECT
    TRIM(menu_id) AS menu_id
    , TRY_CAST(r_id AS BIGINT) AS restaurant_id
    , TRIM(f_id) AS food_id
    , TRIM(cuisine) AS cuisine
    , TRY_CAST(NULLIF(REGEXP_REPLACE(price, '[^0-9.]', '', 'g'), '') AS DECIMAL(18, 2)) AS price
FROM source
