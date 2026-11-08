WITH source AS (
    SELECT * FROM {{ ref('reviews') }}
)

SELECT
    TRY_TO_NUMBER(review_id) AS review_id
    , TRY_TO_NUMBER(order_id) AS order_id
    , TRY_TO_NUMBER(user_id) AS customer_id
    , TRY_TO_NUMBER(restaurant_id) AS restaurant_id
    , TRY_TO_DECIMAL(rating, 3, 1) AS rating
    , TRIM(comment) AS comment
    , TRY_TO_DATE(review_date) AS review_date
FROM source
