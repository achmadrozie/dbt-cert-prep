# M2.1: Incremental Proof for `fact_order`

Date: 2026-11-14 · Stack: dbt Core 1.10.22, dbt-duckdb 1.10.0 · Data ends 2026-06-30 (10,000,000 orders)

Tags: **Fact** = observed in my own runs or stated in docs. **Hypothesis** = reasoned, not verified. **Unknown** = still to test.

## 1. Question

Does rewriting `fact_order` from a full `table` into an `incremental` model (3-day lookback, `merge` on `order_id`) change any data?

- Reference: `fact_order` (full table, all data).
- Candidate: `fact_order_v2` (incremental).

## 2. What I learned first (concepts)

- **Incremental is about build cost, not about keeping "the latest value".** Each run processes only new or changed rows instead of rebuilding everything.
- The first run of an incremental model is a full build, identical to a `table`. The real test is the **second run**.
- `is_incremental()` is true only when the target table exists, the model is incremental, and no `--full-refresh` is used.
- `unique_key` must be unique and non-null. With `merge`, rows read twice get updated, not duplicated.
- **Lookback window** re-reads the last N days to catch late data. It reduces drift but never guarantees zero drift, so a periodic full refresh is still wise.
- Backfill is not always `--full-refresh`. A partial backfill is possible (microbatch: `--event-time-start` / `--event-time-end`).
- Microbatch is an incremental *strategy*, not a cheaper materialization. Its advantage is safer backfill and retries, not lower cost per normal run. (Not used here; Unknown how dbt-duckdb implements it.)

## 3. Problem: no "new data" to test with

The source already contains everything up to 2026-06-30, so a second incremental run would have nothing new to add and prove nothing.

**Solution: simulate time passing.** Hide the last 4 days in run 1, reveal them in run 2.

```
Real data:   [ ........ 26 Jun | 27 | 28 | 29 | 30 Jun ]
Run 1 (as_of 26 Jun):  table = [ ........ 26 Jun ]
Run 2 (as_of 30 Jun):  table = [ ........ 26 Jun | 27 | 28 | 29 | 30 ]   <- incremental adds this
```

Test-only scaffold added to `fact_order_v2.sql`:

```sql
WHERE b.order_date <= '{{ var("as_of", "2026-06-30") }}'
{% if is_incremental() %}
    AND b.order_date >= (SELECT MAX(order_date) FROM {{ this }}) - INTERVAL 3 DAY
{% endif %}
```

## 4. Run log

```bash
# Run 1: pretend today is 26 Jun (full build)
dbt run -s fact_order_v2 --full-refresh --vars '{as_of: "2026-06-26"}'

# Check
dbt show --inline "select max(order_date) as max_d, count(*) as n from {{ ref('fact_order_v2') }}"

# Run 2: time moves to 30 Jun (normal incremental, no --full-refresh)
dbt run -s fact_order_v2 --vars '{as_of: "2026-06-30"}'

# Compare against the full table
dbt show -s audit_relation_rows
```

| Step | max order_date | rows | build time |
|---|---|---|---|
| Full build, all data (reference run of v2) | 2026-06-30 | 10,000,000 | 6.19s |
| Run 1 (as_of 26 Jun, full refresh) | 2026-06-26 | 9,933,854 | 4.00s |
| Run 2 (as_of 30 Jun, incremental) | 2026-06-30 | 10,000,000 | 2.52s |

- Rows added by run 2: 10,000,000 - 9,933,854 = **66,146** (matches the expected gap).
- **Fact:** `merge` ran successfully in my setup. DuckDB engine version itself is still **Unknown** (the `1.10.0` shown in logs is the dbt-duckdb adapter version).
- Runtime: one measurement on a laptop with local data, so treat the ~2.5x speedup as indicative, not a benchmark.

## 5. Proof of equality

Result of the `EXCEPT` comparison after run 2 (`fact_order` vs `fact_order_v2`):

| side | n |
|---|---|
| only_in_old | 0 |
| only_in_new | 0 |

Row counts are equal (10,000,000 vs 10,000,000) and no row exists on only one side. At column level, schema and all 32 columns also matched (section 6).

**Conclusion:** the incremental model caught up on 4 days of new data with no missing or duplicated rows, and its output matches the full table.

Query used (`analyses/fact_order/audit_relation_rows.sql`; note the file name is misleading, it contains the `EXCEPT` fallback, not the audit_helper macro):

```sql
select 'only_in_old' as side, count(*) as n
from (select * from {{ ref('fact_order') }}
      except
      select * from {{ ref('fact_order_v2') }})
union all
select 'only_in_new', count(*)
from (select * from {{ ref('fact_order_v2') }}
      except
      select * from {{ ref('fact_order') }})
```

## 6. audit_helper on DuckDB: what worked and what did not

**Works**
- `compare_row_counts`: 10,000,000 vs 10,000,000.
- `compare_relation_columns` (schema check): first run showed 32 columns with the same names, positions and types in both tables.
- `compare_all_columns` (value check): when both tables have the same columns, all 32 columns had 10,000,000 perfect matches and 0 missing.
  - Nulls only in `customer_rating` (3,592,803) and `delivery_time_min` (849,878), identical on both sides.

**Fails**
- `compare_and_classify_relation_rows`: generated SQL uses `count(distinct a, b)`, which DuckDB rejects (`No function matches ... 'count(VARCHAR, BIGINT)'`).
- `compare_all_columns` when a column is missing on one side: `Binder Error: ... does not have a column named "delivery_fee"` (see 6.1).

**Not tested / not available**
- `compare_which_relation_columns_differ`: Unknown.
- `quick_are_relations_identical`: README says Snowflake and BigQuery only.

**Fallback**
- Plain SQL `EXCEPT` in both directions (section 5).
- Limits: no modified/added/removed classification, and set semantics hide duplicate differences. Mitigation: also compare row counts (done).

**Gotchas**
- PK argument name differs by macro:
  - `primary_key_columns` (list) in `compare_and_classify_*` and `compare_which_*_differ`.
  - `primary_key` (single column) in `compare_all_columns` and `compare_column_values`.
- My first attempt used the wrong one: `takes no keyword argument 'primary_key'`.

**How I call a package macro**
- Macros live in `dbt_packages/audit_helper/macros/`, one file per macro. I never edit them.
- I write a one-line call in `analyses/` and run `dbt show -s <analysis name>`.

### 6.1 Schema drift found later

- A later `compare_relation_columns` run showed `fact_order_v2` no longer has `delivery_fee`.
  - Columns: 32 in `fact_order`, 31 in `fact_order_v2`.
  - `delivery_fee` is position 22 in A and empty in B (`has_ordinal_position = False`).
  - Every column after it shifts by one position.
- `compare_all_columns` then errored instead of reporting the missing column.
- Workaround: `exclude_columns = ['delivery_fee']`.
- Cause: **TODO, fill in** (intentional experiment or accidental change to `fact_order_v2.sql`).
- The "all 32 columns match" result applies to `fact_order_v2` as it was before `delivery_fee` disappeared.
- Lesson: run the schema check first, then the value check.

## 7. Final model (test scaffold removed)

The `as_of` filter was only for the proof. Leaving a hardcoded `2026-06-30` default would silently cut off any future data.

```sql
FROM {{ ref('int_order_base') }} b
INNER JOIN {{ ref('int_order_financials') }} f USING (order_id)
INNER JOIN {{ ref('int_order_fulfillment') }} u USING (order_id)
LEFT JOIN {{ ref('int_order_item_rollup') }} i USING (order_id)
{% if is_incremental() %}
WHERE b.order_date >= (SELECT MAX(order_date) FROM {{ this }}) - INTERVAL 3 DAY
{% endif %}
```

Config: `materialized = 'incremental'`, `unique_key = 'order_id'`, `incremental_strategy = 'merge'`.

## 8. Mistakes and lessons

- Assumed data ended in September; it ends 2026-06-30. Check `max(date)` before designing a simulation.
- Ran the "pretend" build without `--vars`, so the filter did nothing. Verify with a `max(order_date)` check after every step.
- Tried to open the `.duckdb` file in the CLI while a `dbt` process held the lock (Hypothesis: the VS Code dbt extension). Use `dbt show --inline` instead.
- Run `compare_relation_columns` before `compare_all_columns`. A column missing on one side breaks the value check (6.1).
- Read the error message literally: "takes no keyword argument X" means the argument name is wrong; copy the real name from the macro file.

## 9. Not proven yet

- **Late-arriving data.** The dataset has no late rows, so the 3-day lookback was not truly exercised. Possible follow-up: change one old source row, run incrementally, and check whether it updates; also try lookback 0 to show why it exists.
- Behavior on schema changes (`on_schema_change`) was not tested here.
- Full-refresh cadence for production is a decision, not a measurement. dbt guidance suggests weekly or monthly if size allows.

## 10. Next

- Snapshot `restaurant` into `dim_restaurant_scd2`.
- Resolve the `delivery_fee` state in 6.1: restore it and rebuild with `--full-refresh`, or document it as an intentional experiment.
- Optionally test `compare_which_relation_columns_differ` on DuckDB.
