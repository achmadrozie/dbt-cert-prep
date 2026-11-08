WITH source AS (
    SELECT * FROM {{ ref('restaurant') }}
)

SELECT
    TRY_TO_NUMBER(id) AS restaurant_id
    , TRIM(name) AS restaurant_name
    , TRIM(COALESCE(REGEXP_SUBSTR(city, '[^,]+$'), city)) AS city
    , TRY_TO_DECIMAL(NULLIF(rating, '--'), 3, 1) AS rating
    , TRY_TO_NUMBER(NULLIF(REGEXP_REPLACE(rating_count, '[^0-9]', ''), '')) AS rating_count
    , TRY_TO_NUMBER(NULLIF(REGEXP_REPLACE(cost, '[^0-9]', ''), '')) AS cost_for_two
    , TRIM(cuisine) AS cuisine
    , TRIM(lic_no) AS license_no
FROM source
