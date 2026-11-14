-- analyses/fact_order/audit_schema.sql
{{ audit_helper.compare_relation_columns(
    a_relation = ref('fact_order'),
    b_relation = ref('fact_order_v2')
) }}