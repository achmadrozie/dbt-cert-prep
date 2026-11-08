WITH source AS (
    SELECT * FROM {{ ref('restaurant') }}
)

SELECT
    TRY_CAST(id AS BIGINT) AS restaurant_id
    , TRIM(name) AS restaurant_name
    , TRIM(REGEXP_EXTRACT(city, '[^,]+$')) AS city
    , TRY_CAST(NULLIF(rating, '--') AS DECIMAL(3, 1)) AS rating
    , TRY_CAST(NULLIF(REGEXP_REPLACE(rating_count, '[^0-9]', '', 'g'), '') AS BIGINT) AS rating_count
    , TRY_CAST(NULLIF(REGEXP_REPLACE(cost, '[^0-9]', '', 'g'), '') AS BIGINT) AS cost_for_two
    , TRIM(cuisine) AS cuisine
    , TRIM(lic_no) AS license_no
FROM source
