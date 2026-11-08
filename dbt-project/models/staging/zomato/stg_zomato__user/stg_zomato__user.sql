WITH source AS (
    SELECT * FROM {{ ref('users') }}
)

SELECT
    TRY_CAST(user_id AS BIGINT) AS customer_id
    , TRIM(name) AS customer_name
    , LOWER(TRIM(email)) AS email
    , TRY_CAST(age AS BIGINT) AS age
    , TRIM(gender) AS gender
    , TRIM(marital_status) AS marital_status
    , TRIM(occupation) AS occupation
    , TRIM(monthly_income) AS income_band
    , TRIM(educational_qualifications) AS education
    , TRY_CAST(family_size AS BIGINT) AS family_size
FROM source
