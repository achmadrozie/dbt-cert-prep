{% docs int_date_features %}
Calendar attributes derived from `int_date_spine`, with one row per date. Supplies the columns exposed by `dim_date`.
{% enddocs %}

{% docs int_date_features_date_day %}
Calendar date and unique key inherited from `int_date_spine`.
{% enddocs %}

{% docs int_date_features_year %}
Calendar year extracted from `date_day`.
{% enddocs %}

{% docs int_date_features_month %}
Calendar month number extracted from `date_day`, from 1 to 12.
{% enddocs %}

{% docs int_date_features_month_name %}
Month name returned by Snowflake `MONTHNAME` for `date_day`.
{% enddocs %}

{% docs int_date_features_day_name %}
Day name returned by Snowflake `DAYNAME` for `date_day`.
{% enddocs %}

{% docs int_date_features_is_weekend %}
True when `date_day` is Saturday or Sunday according to ISO weekday numbering.
{% enddocs %}
