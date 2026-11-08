WITH source AS (
    SELECT * FROM {{ ref('menu') }}
)

SELECT
    TRIM(menu_id) AS menu_id
    , TRY_TO_NUMBER(r_id) AS restaurant_id
    , TRIM(f_id) AS food_id
    , TRIM(cuisine) AS cuisine
    , TRY_TO_DECIMAL(price, 18, 2) AS price
FROM source
