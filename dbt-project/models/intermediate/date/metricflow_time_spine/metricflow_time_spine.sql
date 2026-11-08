{{ config(materialized='table') }}

SELECT CAST(date_day AS DATE) AS date_day
FROM GENERATE_SERIES(
    DATE '2020-01-01',
    DATE '2030-12-31',
    INTERVAL 1 DAY
) AS dates(date_day)
