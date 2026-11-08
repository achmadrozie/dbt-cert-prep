SELECT
    date_day
    , EXTRACT(YEAR FROM date_day)   AS year
    , EXTRACT(MONTH FROM date_day)  AS month
    , STRFTIME(date_day, '%b')      AS month_name
    , STRFTIME(date_day, '%a')      AS day_name
    , EXTRACT(ISODOW FROM date_day) >= 6 AS is_weekend
FROM {{ ref('int_date_spine') }}
