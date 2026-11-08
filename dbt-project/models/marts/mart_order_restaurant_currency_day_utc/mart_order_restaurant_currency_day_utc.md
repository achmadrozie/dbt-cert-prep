{% docs mart_order_restaurant_currency_day_utc %}
One row per source order date, restaurant ID, and source currency. Replaces the lifetime restaurant summary with a daily additive aggregate. Restaurant attributes remain in dim_restaurant, joined by restaurant_id when needed. Average rating uses summed customer_rating_sum divided by summed customer_rating_observation_count; average delivery time uses summed delivery_time_sum_min divided by summed delivery_time_observation_count. A zero observation count produces an undefined average, not zero.
The `_utc` suffix is a project naming convention only: values remain the existing source date or wall-clock bucket, without timezone conversion or verification.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_order_date_utc %}
Separately supplied source order date, parsed without timezone conversion.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_restaurant_id %}
Restaurant identifier on the order; joins many-to-one to dim_restaurant.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_currency %}
Source order currency; monetary values are not converted.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_order_count %}
Count of all order rows.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_delivered_order_count %}
Count of Delivered orders.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_cancelled_order_count %}
Count of Cancelled orders.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_refunded_order_count %}
Count of Refunded orders.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_delivered_sales_amount %}
Sum of source sales amount for Delivered orders; non-delivered orders contribute zero.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_customer_rating_sum %}
Sum of nonnull numeric order customer ratings across all statuses; zero with no observations.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_customer_rating_observation_count %}
Count of orders with a nonnull numeric customer rating across all statuses.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_delivery_time_sum_min %}
Sum of nonnull delivery durations among Delivered orders; zero with no observations.
{% enddocs %}

{% docs mart_order_restaurant_currency_day_utc_delivery_time_observation_count %}
Count of Delivered orders with a nonnull delivery duration.
{% enddocs %}
