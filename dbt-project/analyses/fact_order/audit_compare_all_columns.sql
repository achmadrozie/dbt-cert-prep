{{
    audit_helper.compare_all_columns(
        a_relation = ref('fact_order')
        , b_relation = ref('fact_order_v2')
        , primary_key = 'order_id'
        , summarize = true
    )
}}
