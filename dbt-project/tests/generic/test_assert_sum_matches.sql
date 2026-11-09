{% test assert_sum_matches(model, column_name, compare_model, compare_column) %}

with totals as (
    select
        (select sum({{ column_name }}) from {{ model }}) as actual_total,
        (select sum({{ compare_column }}) from {{ compare_model }}) as comparison_total
)

select *
from totals
where actual_total is distinct from comparison_total

{% endtest %}
