SELECT 
    restaurant_id
    , restaurant_name
    , city
    , cuisine
    , rating
    , rating_count
    , cost_for_two
FROM {{ ref('stg_zomato__restaurant') }}