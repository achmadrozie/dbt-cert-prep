-- Deliberately failing test to demonstrate a red CI run. Remove after.
SELECT order_id
FROM {{ ref('fact_order') }}
WHERE sales_amount > 0
