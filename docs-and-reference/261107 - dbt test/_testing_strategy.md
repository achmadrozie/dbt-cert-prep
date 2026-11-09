# Overall
1. Testing is important to ensure the data we deliver is as expected / meet business requirement.
2. We have to balance between the deep of the test
    - too tight data-test is not guarantee if we got better data
    - too loose data-test is also not run as expected
# How is the strategy
1. Start by layer: Bronze (Source) --> Silver (Staging, Intermediate) -> Gold (Core and Marts)
    1. Source: 
        a. built-in, generic
        b. custome, custom (e.g. assert_non_negative )
        c. dbt source freshness (to ensure that the data here is still new as business expectation)
            further configuration: we can either override (with more specific configuration) or optout for non-relevant/ slow-updated data
    2. Silver (Staging, Intermediate)
        - There is a location where we start to normalize the data and do data manipulation and logic calculation
        - Unit test is might be needed here to ensure if the data is processed as expected
        - Example:
            
    3. Gold (Core, Marts)
        - There is a location where the table has to own clear granularity 
            (e.g. dim_user for user_id, fact_order for order_id, fact_order_item for order_item_id, etc.)
            - this test to ensure 1 row per grain
        - So, basic test like generic built-in is important here (unique, not null), also with the generic- custom to prevent miscalculation from the silver layer
            - unit test might be needed on this layer.

FEEDBACK: will be solved later

- Ganti penjelasan freshness “data masih relevan” menjadi data terbaru masuk sesuai jadwal yang diharapkan. Data lama tetap bisa relevan.
- Ubah daftar per layer menjadi tabel layer → jenis test → contoh dari repo → alasan.
- Tambahkan bagian yang sengaja tidak dites dan pelajaran dari test merah yang lu sengaja buat. Keduanya belum ada di draft terbaru.