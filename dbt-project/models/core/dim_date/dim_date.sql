SELECT
    date_day
    , year
    , month
    , month_name
    , day_name
    , is_weekend
FROM {{ ref('int_date_features') }}
