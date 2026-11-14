{{ audit_helper.compare_row_counts(
    a_relation = ref('fact_order', v=1),
    b_relation = ref('fact_order', v=2)
) }}