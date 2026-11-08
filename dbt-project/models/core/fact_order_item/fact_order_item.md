{% docs fact_order_item %}
Order-item fact with one row per `order_item_id`. Left joins staged item rows to `int_order_base` for order timestamp, date, and city, keeping any orphan item visible for relationship tests. Source and calculated line amounts remain separate. Rebuilt as a table from the Project 1 source snapshot; there is no reliable source change marker for incremental loading.
{% enddocs %}

{% docs fact_order_item_order_item_id %}
Identifier and unique key of the order item.
{% enddocs %}

{% docs fact_order_item_order_id %}
Identifier of the order containing the item.
{% enddocs %}

{% docs fact_order_item_restaurant_id %}
Restaurant identifier recorded on the item.
{% enddocs %}

{% docs fact_order_item_food_id %}
Food identifier, renamed from staged `f_id`.
{% enddocs %}

{% docs fact_order_item_order_ts %}
Source wall-clock timestamp of the related order from `int_order_base`; its timezone has not been verified.
{% enddocs %}

{% docs fact_order_item_order_date %}
Calendar date of the related order from `int_order_base`.
{% enddocs %}

{% docs fact_order_item_city %}
City associated with the related order from `int_order_base`.
{% enddocs %}

{% docs fact_order_item_price %}
Recorded price of the item, cast to decimal in staging.
{% enddocs %}

{% docs fact_order_item_quantity %}
Recorded quantity of the item, cast to a number in staging.
{% enddocs %}

{% docs fact_order_item_line_amount %}
Recorded line amount from the item source, cast to decimal in staging. It is not recomputed from price and quantity.
{% enddocs %}

{% docs fact_order_item_calculated_line_amount %}
Item price multiplied by quantity.
{% enddocs %}

{% docs fact_order_item_line_amount_delta %}
Source line amount minus price multiplied by quantity. Nonzero values are retained for data quality review.
{% enddocs %}
