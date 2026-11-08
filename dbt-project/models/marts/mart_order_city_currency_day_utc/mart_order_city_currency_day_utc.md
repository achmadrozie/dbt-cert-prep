{% docs mart_order_city_currency_day_utc %}
One row per source order date, city, and currency. Counts all orders and statuses, and sums delivered sales without currency conversion.
The `_utc` suffix is a project naming convention only: values remain the existing source date or wall-clock bucket, without timezone conversion or verification.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_order_date_utc %}
Separately supplied source order date, parsed without timezone conversion.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_city %}
City recorded on the order.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_currency %}
Source currency; monetary values are not converted.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_order_count %}
All order rows.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_delivered_order_count %}
Delivered order rows.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_cancelled_order_count %}
Cancelled order rows.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_refunded_order_count %}
Refunded order rows.
{% enddocs %}

{% docs mart_order_city_currency_day_utc_delivered_sales_amount %}
Sum of delivered sales amount.
{% enddocs %}
