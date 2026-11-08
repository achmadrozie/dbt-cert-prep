SELECT
    date_day
    , YEAR(date_day)                AS year
    , MONTH(date_day)               AS month
    , MONTHNAME(date_day)           AS month_name
    , DAYNAME(date_day)             AS day_name
    , (DAYOFWEEKISO(date_day) >= 6) AS is_weekend
FROM {{ ref('int_date_spine') }}
