WITH source AS (
    SELECT * FROM {{ ref('food') }}
)

SELECT
    TRIM(f_id) AS food_id
    , TRIM(item) AS food_name
    , INITCAP(TRIM(veg_or_non_veg)) AS veg_or_non_veg
FROM source
