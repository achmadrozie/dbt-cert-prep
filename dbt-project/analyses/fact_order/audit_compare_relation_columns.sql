-- analyses/fact_order/audit_schema.sql
{{ audit_helper.compare_relation_columns(
    a_relation = ref('fact_order', v=1),
    b_relation = ref('fact_order', v=2)
) }}