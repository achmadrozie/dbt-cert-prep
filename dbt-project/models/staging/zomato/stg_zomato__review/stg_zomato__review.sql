WITH source AS (
    SELECT * FROM {{ ref('reviews') }}
)

SELECT
    TRY_CAST(review_id AS BIGINT) AS review_id
    , TRY_CAST(order_id AS BIGINT) AS order_id
    , TRY_CAST(user_id AS BIGINT) AS customer_id
    , TRY_CAST(restaurant_id AS BIGINT) AS restaurant_id
    , TRY_CAST(rating AS DECIMAL(3, 1)) AS rating
    , TRIM(comment) AS comment
    , TRY_CAST(review_date AS DATE) AS review_date
FROM source
