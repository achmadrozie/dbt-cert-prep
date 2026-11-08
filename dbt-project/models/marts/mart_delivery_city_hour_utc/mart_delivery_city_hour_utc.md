{% docs mart_delivery_city_hour_utc %}
One row per source timestamp hour and order city among Delivered orders. All measures are additive over disjoint buckets. The timestamp hour includes its date; its timezone is unverified. Average delivery minutes is SUM(delivery_time_sum_min) / NULLIF(SUM(delivery_time_observation_count), 0).
The `_utc` suffix is a project naming convention only: values remain the existing source date or wall-clock bucket, without timezone conversion or verification.
{% enddocs %}

{% docs mart_delivery_city_hour_utc_order_hour_utc %}
Source wall-clock order timestamp truncated to the hour, including the date; no timezone conversion.
{% enddocs %}

{% docs mart_delivery_city_hour_utc_city %}
City recorded on the order.
{% enddocs %}

{% docs mart_delivery_city_hour_utc_delivered_order_count %}
Count of Delivered order rows, including rows with a null duration.
{% enddocs %}

{% docs mart_delivery_city_hour_utc_delivery_time_sum_min %}
Sum of nonnull delivery durations in minutes; zero when there are no observations.
{% enddocs %}

{% docs mart_delivery_city_hour_utc_delivery_time_observation_count %}
Count of Delivered orders with a nonnull duration; denominator for average duration.
{% enddocs %}
