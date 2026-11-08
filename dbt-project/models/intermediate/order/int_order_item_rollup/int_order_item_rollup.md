{% docs int_order_item_rollup %}
One row per order, aggregated from one row per order item in `stg_zomato__order_item`. Counts item lines and distinct food IDs, sums quantities and amounts, and exposes the difference between source line amounts and price times quantity. This changes the grain from item to order so it can join to the other order intermediate models on `order_id`.
{% enddocs %}
