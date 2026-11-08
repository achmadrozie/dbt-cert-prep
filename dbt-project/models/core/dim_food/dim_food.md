{% docs dim_food %}
Food dimension with one row per food ID. Selects the food name and vegetarian classification from `stg_zomato__food`.
{% enddocs %}

{% docs dim_food_food_id %}
Identifier of the food item, sourced from `f_id` and renamed in staging.
{% enddocs %}

{% docs dim_food_food_name %}
Food item name, sourced from the `item` field.
{% enddocs %}

{% docs dim_food_veg_or_non_veg %}
Vegetarian or non-vegetarian classification, converted to initial capitals in staging.
{% enddocs %}
