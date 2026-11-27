-- Builds a small, consistent sample of the Zomato seeds for CI.
-- Run from dbt-project/ (reads the full CSVs, writes ci/seeds/):
--   duckdb :memory: < scripts/make_ci_sample.sql
-- In-memory on purpose: it never touches dbt.duckdb, so no lock conflict.
-- Parents first, children after, so relationships tests still pass on the sample.

CREATE TEMP TABLE s_orders AS
SELECT *
FROM read_csv('seeds/orders.csv', header = true, all_varchar = true)
-- Reproducible "random" pick: same 1000 orders every run.
ORDER BY hash(order_id)
LIMIT 1000;

CREATE TEMP TABLE s_order_items AS
SELECT oi.*
FROM read_csv('seeds/order_items.csv', header = true, all_varchar = true) AS oi
WHERE oi.order_id IN (SELECT order_id FROM s_orders);

CREATE TEMP TABLE s_restaurant AS
SELECT r.*
FROM read_csv('seeds/restaurant.csv', header = true, all_varchar = true) AS r
WHERE r.id IN (SELECT r_id FROM s_orders)
    OR r.id IN (SELECT r_id FROM s_order_items);

CREATE TEMP TABLE s_food AS
SELECT f.*
FROM read_csv('seeds/food.csv', header = true, all_varchar = true) AS f
WHERE f.f_id IN (SELECT f_id FROM s_order_items);

CREATE TEMP TABLE s_users AS
SELECT u.*
FROM read_csv('seeds/users.csv', header = true, all_varchar = true) AS u
WHERE u.user_id IN (SELECT user_id FROM s_orders);

CREATE TEMP TABLE s_reviews AS
SELECT rv.*
FROM read_csv('seeds/reviews.csv', header = true, all_varchar = true) AS rv
WHERE rv.order_id IN (SELECT order_id FROM s_orders);

CREATE TEMP TABLE s_menu AS
SELECT m.*
FROM read_csv('seeds/menu.csv', header = true, all_varchar = true) AS m
WHERE m.r_id IN (SELECT id FROM s_restaurant)
    AND m.f_id IN (SELECT f_id FROM s_food);

COPY s_orders TO 'ci/seeds/orders.csv' (HEADER, DELIMITER ',');
COPY s_order_items TO 'ci/seeds/order_items.csv' (HEADER, DELIMITER ',');
COPY s_restaurant TO 'ci/seeds/restaurant.csv' (HEADER, DELIMITER ',');
COPY s_food TO 'ci/seeds/food.csv' (HEADER, DELIMITER ',');
COPY s_users TO 'ci/seeds/users.csv' (HEADER, DELIMITER ',');
COPY s_reviews TO 'ci/seeds/reviews.csv' (HEADER, DELIMITER ',');
COPY s_menu TO 'ci/seeds/menu.csv' (HEADER, DELIMITER ',');

-- Row counts and orphan checks (all orphan counts must be 0).
SELECT 'orders' AS tbl, count(*) AS n FROM s_orders
UNION ALL SELECT 'order_items', count(*) FROM s_order_items
UNION ALL SELECT 'restaurant', count(*) FROM s_restaurant
UNION ALL SELECT 'food', count(*) FROM s_food
UNION ALL SELECT 'users', count(*) FROM s_users
UNION ALL SELECT 'reviews', count(*) FROM s_reviews
UNION ALL SELECT 'menu', count(*) FROM s_menu
UNION ALL SELECT 'ORPHAN order_items->orders', count(*) FROM s_order_items WHERE order_id NOT IN (SELECT order_id FROM s_orders)
UNION ALL SELECT 'ORPHAN order_items->food', count(*) FROM s_order_items WHERE f_id NOT IN (SELECT f_id FROM s_food)
UNION ALL SELECT 'ORPHAN order_items->restaurant', count(*) FROM s_order_items WHERE r_id NOT IN (SELECT id FROM s_restaurant)
UNION ALL SELECT 'ORPHAN orders->restaurant', count(*) FROM s_orders WHERE r_id NOT IN (SELECT id FROM s_restaurant)
UNION ALL SELECT 'ORPHAN orders->users', count(*) FROM s_orders WHERE user_id NOT IN (SELECT user_id FROM s_users);
