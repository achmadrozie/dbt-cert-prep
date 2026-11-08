{% docs dim_restaurant %}
Restaurant dimension with one row per restaurant. Selects the identifier, location, cuisine, rating, and cost attributes from `stg_zomato__restaurant`.
{% enddocs %}

{% docs dim_restaurant_restaurant_id %}
Unique numeric identifier of the restaurant, derived from the source restaurant ID.
{% enddocs %}

{% docs dim_restaurant_restaurant_name %}
Restaurant name from the source record.
{% enddocs %}

{% docs dim_restaurant_city %}
City extracted from the last comma-separated segment of the source city field, or the original value when no segment is found.
{% enddocs %}

{% docs dim_restaurant_cuisine %}
Cuisine value from the source restaurant record.
{% enddocs %}

{% docs dim_restaurant_rating %}
Restaurant rating converted to a decimal during staging. The source placeholder `--` becomes null.
{% enddocs %}

{% docs dim_restaurant_rating_count %}
Numeric count extracted from the source rating count text, such as `50` from `50+`.
{% enddocs %}

{% docs dim_restaurant_cost_for_two %}
Numeric cost for two people extracted from the source cost text.
{% enddocs %}
