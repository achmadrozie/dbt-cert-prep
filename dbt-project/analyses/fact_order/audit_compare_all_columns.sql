{{
    audit_helper.compare_all_columns(
        a_relation = ref('fact_order', v=1)
        , b_relation = ref('fact_order', v=2)
        , primary_key = 'order_id'
        , summarize = true
    )
}}
