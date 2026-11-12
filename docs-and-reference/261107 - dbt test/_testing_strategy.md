# Testing strategy — M1

## Overall

Testing is important to ensure the data we deliver is as expected and meets business requirements. I think we need to balance the depth of testing: if tests are too tight, valid new data may be rejected; if they are too loose, problems may pass unnoticed. The rule and the threshold should make sense for the business.

## How is the strategy?

I start by layer: **Bronze (Source) → Silver (Staging, Intermediate) → Gold (Core, Marts)**. At each layer I ask what could go wrong, then choose a test for that risk.

- **Bronze — source / seeds:** Check input keys with `unique` and `not_null`, as on `restaurant.id`. Use freshness to check whether new source data arrives on schedule; `orders` and `reviews` have freshness configs, while `users` opts out.
- **Silver — staging / intermediate:** Test calculation logic with chosen input and expected output. For example, `int_order_financials` has unit tests for excess discount and null delivery fee. `assert_non_negative` and the singular discount test check business rules on built data.
- **Gold — core / marts:** Protect the declared grain with `unique` and `not_null`, for example one `fact_order` row per `order_id`. Use relationships for references to dimensions and `assert_sum_matches` for totals across layers.

## What I intentionally do not test

- No unit test for every pass-through or rename-only model; I prioritize meaningful transformation logic.
- No real ingestion SLA from this sandbox's historical seeds: `order_timestamp` and `review_date` are event dates, not load times.

## What I learned from a deliberate failure

- A deliberately duplicated `restaurant_id` produced a warning; `store_failures` showed the duplicated ID. The thresholds determined whether the failure was a warning or error.
- A test with `where` can PASS after checking zero rows. I need to check the filtered row count before trusting that PASS.
