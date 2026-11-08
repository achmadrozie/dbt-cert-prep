WITH generated_dates AS (
    SELECT
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, '2024-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1200))
)

SELECT date_day
FROM generated_dates
WHERE date_day <= '2026-12-31'::DATE
