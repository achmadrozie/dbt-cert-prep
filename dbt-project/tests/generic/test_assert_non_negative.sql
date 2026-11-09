{% test assert_non_negative(model,column_name) %}

    select 1 from {{ model }} where {{ column_name }} < 0 

{% endtest %}