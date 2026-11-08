{{ config(materialized='table') }}

WITH days AS (
    SELECT DATEADD(
        DAY
        , ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1
        , '2020-01-01'::DATE
    ) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
)

SELECT date_day
FROM days
WHERE date_day <= '2030-12-31'::DATE
