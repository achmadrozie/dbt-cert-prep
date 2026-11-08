{% docs dim_date %}
Date dimension with one row per calendar day from 2024-01-01 through 2026-12-31. Exposes the attributes prepared in `int_date_features`.
{% enddocs %}

{% docs dim_date_date_day %}
Calendar date and unique key of this dimension.
{% enddocs %}

{% docs dim_date_year %}
Calendar year of `date_day`.
{% enddocs %}

{% docs dim_date_month %}
Calendar month number of `date_day`, from 1 to 12.
{% enddocs %}

{% docs dim_date_month_name %}
Month name returned by Snowflake `MONTHNAME` for `date_day`.
{% enddocs %}

{% docs dim_date_day_name %}
Day name returned by Snowflake `DAYNAME` for `date_day`.
{% enddocs %}

{% docs dim_date_is_weekend %}
True when `date_day` falls on Saturday or Sunday according to ISO weekday numbering.
{% enddocs %}
