# Testing strategy — M1

## Overall

Testing is important to ensure the data we deliver is as expected and meets business requirements. I think we need to balance the depth of testing: if tests are too tight, valid new data may be rejected; if they are too loose, problems may pass unnoticed. The rule and the threshold should make sense for the business.

## How is the strategy?

I start by layer: **Bronze (Source) → Silver (Staging, Intermediate) → Gold (Core, Marts)**. At each layer I ask what could go wrong, then choose a test for that risk.

| Layer | Test | Example from this project | Why I put it here |
| --- | --- | --- | --- |
| Bronze — source / seeds | Built-in generic tests (`unique`, `not_null`) and source freshness | `restaurant.id` has `unique` and `not_null`. `_sources.yml` sets freshness for `orders` and `reviews`; `users` opts out. | Check input keys early. Freshness asks whether the newest source data arrived within the expected time; a source can override a general rule or opt out when the rule is not relevant. |
| Silver — staging / intermediate | Unit tests for calculation logic, plus custom or singular data tests for business rules | `int_order_financials` has unit tests for discount above subtotal and null delivery fee. `assert_non_negative` checks amounts; `test_discount_exceeds_subtotal` checks an invalid discount. | This is where I normalize data and calculate values, so I want to know whether a chosen input produces the expected output and whether real rows violate the rule. |
| Gold — core / marts | Grain tests (`unique`, `not_null`), relationships, and reconciliation | `fact_order.order_id` is `unique` and `not_null`; `restaurant_id` has a relationship to `dim_restaurant`; `fact_order_item.line_amount` uses `assert_sum_matches`. | A fact or dimension should have a clear grain, for example one row per `order_id` or `order_item_id`. These tests also catch missing references or mismatched totals. Unit tests may be useful here if a model adds important logic. |

## What I intentionally do not test

I would not add a unit test to every model that only passes through or renames columns. I focus unit tests on logic with a meaningful input and expected output. A `where` config can limit a data test to a recent period, but I need to check that the period actually has rows: zero rows can still give a PASS. Source freshness helps detect a source that stopped updating, but only if the timestamp represents data arrival. In this seed-based sandbox, `order_timestamp` and `review_date` are event dates, so the freshness check is a learning exercise rather than a real ingestion SLA.

## What I learned from a deliberate failure

When I deliberately duplicated a `restaurant_id`, the `unique` test gave a warning and `store_failures` let me see the duplicated ID. I learned that the test result is a count of failing values, while `warn_if` and `error_if` decide whether that count becomes a warning or an error. I also learned from the `where` exercise that a PASS is only useful when I know which rows were tested. After an experiment with bad data, I need to remove the intentional change.
