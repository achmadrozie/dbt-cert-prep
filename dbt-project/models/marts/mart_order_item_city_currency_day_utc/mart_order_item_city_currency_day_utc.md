{% docs mart_order_item_city_currency_day_utc %}
One row per source order date, order city, and parent-order currency. All order statuses are included. The many-to-one join to fact_order supplies currency without adding order-level measures. The left join retains an unmatched item as a null-currency bucket, which fails the currency not-null check rather than silently dropping it. Source and calculated amounts remain separate; monetary totals require a currency-specific scope.
The `_utc` suffix is a project naming convention only: values remain the existing source date or wall-clock bucket, without timezone conversion or verification.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_order_date_utc %}
Separately supplied source order date from the related order.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_city %}
City associated with the parent order.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_currency %}
Source currency obtained from the unique parent order; no conversion.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_order_item_count %}
Count of item lines, not distinct orders or units.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_ordered_quantity %}
Sum of item quantities.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_source_line_amount %}
Sum of recorded source item line amounts.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_calculated_line_amount %}
Sum of price multiplied by quantity.
{% enddocs %}

{% docs mart_order_item_city_currency_day_utc_line_amount_delta %}
Sum of source minus calculated item amount.
{% enddocs %}
