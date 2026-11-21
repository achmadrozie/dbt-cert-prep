SELECT
    food_id
    , food_name
    , veg_or_non_veg
FROM {{ ref('stg_zomato__food') }}
