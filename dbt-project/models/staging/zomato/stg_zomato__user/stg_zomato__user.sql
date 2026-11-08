WITH source AS (
    SELECT * FROM {{ ref('users') }}
)

SELECT
    TRY_TO_NUMBER(user_id) AS customer_id
    , TRIM(name) AS customer_name
    , LOWER(TRIM(email)) AS email
    , TRY_TO_NUMBER(age) AS age
    , TRIM(gender) AS gender
    , TRIM(marital_status) AS marital_status
    , TRIM(occupation) AS occupation
    , TRIM(monthly_income) AS income_band
    , TRIM(educational_qualifications) AS education
    , TRY_TO_NUMBER(family_size) AS family_size
FROM source
