{% docs fact_order %}
Order fact with one row per `order_id`. Combines the four order intermediate models on their tested unique key. The item rollup is left joined so an order remains visible if it has no item rows. Source financial and item amounts remain visible alongside calculated values and reconciliation deltas. Rebuilt as a table from the Project 1 source snapshot; source timestamps do not provide a reliable change marker for incremental loading.
{% enddocs %}

{% docs fact_order_order_id %}
Identifier and unique key of the order.
{% enddocs %}

{% docs fact_order_order_timestamp %}
Source wall-clock order timestamp. Its timezone has not been verified.
{% enddocs %}

{% docs fact_order_order_date %}
Order date from the source, parsed to a date.
{% enddocs %}

{% docs fact_order_customer_id %}
Customer identifier, renamed from source `user_id` in staging.
{% enddocs %}

{% docs fact_order_restaurant_id %}
Restaurant identifier, renamed from source `r_id` in staging.
{% enddocs %}

{% docs fact_order_city %}
City prepared in `int_order_base` from the source restaurant city.
{% enddocs %}

{% docs fact_order_cuisine %}
Cuisine value recorded on the order.
{% enddocs %}

{% docs fact_order_currency %}
Currency code recorded on the order and normalized in staging.
{% enddocs %}

{% docs fact_order_payment_method %}
Payment method recorded on the order.
{% enddocs %}

{% docs fact_order_order_status %}
Order status from the source.
{% enddocs %}

{% docs fact_order_is_delivered %}
True when `order_status` equals `Delivered`; derived in staging.
{% enddocs %}

{% docs fact_order_is_cancelled %}
True when `order_status` equals `Cancelled`.
{% enddocs %}

{% docs fact_order_is_refunded %}
True when `order_status` equals `Refunded`.
{% enddocs %}

{% docs fact_order_order_hour %}
Hour of day extracted from `order_timestamp`.
{% enddocs %}

{% docs fact_order_items_count %}
Item count recorded on the order.
{% enddocs %}

{% docs fact_order_sales_qty %}
Sales quantity recorded on the order.
{% enddocs %}

{% docs fact_order_rollup_item_line_count %}
Number of order-item rows for the order, aggregated in `int_order_item_rollup`.
{% enddocs %}

{% docs fact_order_rollup_item_quantity %}
Sum of item quantities for the order, aggregated from item-grain rows.
{% enddocs %}

{% docs fact_order_rollup_distinct_food_count %}
Number of distinct food IDs within the order.
{% enddocs %}

{% docs fact_order_subtotal %}
Subtotal amount recorded on the order.
{% enddocs %}

{% docs fact_order_discount %}
Discount amount recorded on the order.
{% enddocs %}

{% docs fact_order_delivery_fee %}
Delivery fee recorded on the order.
{% enddocs %}

{% docs fact_order_gst %}
GST amount recorded on the order.
{% enddocs %}

{% docs fact_order_sales_amount %}
Sales amount recorded on the order and parsed in staging.
{% enddocs %}

{% docs fact_order_calculated_sales_amount %}
Subtotal minus discount plus delivery fee and GST, calculated in intermediate.
{% enddocs %}

{% docs fact_order_sales_amount_delta %}
Source sales amount minus calculated sales amount. Zero means the order financial components reconcile.
{% enddocs %}

{% docs fact_order_delivered_sales_amount %}
Source sales amount for a delivered order and zero otherwise.
{% enddocs %}

{% docs fact_order_rollup_item_line_amount %}
Sum of source line amounts for the order, aggregated from item-grain rows.
{% enddocs %}

{% docs fact_order_rollup_calculated_item_amount %}
Sum of item price times quantity for the order.
{% enddocs %}

{% docs fact_order_rollup_item_amount_delta %}
Source item line amount minus calculated item amount, summed per order. Nonzero values are retained for data quality review.
{% enddocs %}

{% docs fact_order_customer_rating %}
Customer rating recorded on the order, parsed as a decimal when available.
{% enddocs %}

{% docs fact_order_delivery_time_min %}
Delivery time in minutes, parsed as a decimal when available.
{% enddocs %}
