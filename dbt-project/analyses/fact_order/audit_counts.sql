{{ audit_helper.compare_row_counts(
    a_relation = ref('fact_order'),
    b_relation = ref('fact_order_v2')
) }}