# M2.0

Recap | Learning notes regarding M2

## Materialization
- What? Materializatiom act as a strategy to develop and maintain our data warehouse storaging process
  1. Why I called it as a strategy? because through correct materialization - we can not only reduce the cost but also make the consumption layer is efficient
     1. we state all as a table - make our storage in data warehouse become costly - while when we state all models as a 'view' we can make the consumption layer not-effective (long time process)
     2. Here is the materialization come: we can make a strategy to achieve 2 condition in 1 way: effective (fast to be consumed in consumption layer) and efficient (cheap or cost effective - compared to above)
  2. 5 strategies that available on materialization (primarily 2: table and view ):
    1. Table
        - Data is presenced into the warehouse,
        - Exist on data warehouse (queryable) 
        - Fit for consumption layer - fast to be conusumed (since the data was ready) - 
        - Not fit for continuosly-growing data since the cost would get expensive along the time.
    2. View
        - Data is created every time once the model executed 
        - Exist on data warehouse (queryable)
        - Fit for upstream data warehouse layer
    3. Ephemeral
        - Data is created every time once the model executed
        - The difference with the view is the output is not queryable / not available on data warehouse
    4. Incemental
        - Similar with table
        - Exist on data warehouse (queryable)
        - Fit for consumption layer (faster since the data was ready)
        - Fit (cost effective compared to table) for continuously growing data such as event-data with late-data arrival conditions (e.g. last 3 or x days)
        
        - Some important part under incremental (I know it's part of incremental - but I only remember these 2)
          1. **`materialized`**
            - `merge`: we scan based on unique_key on certained period - then we update everything unique_key that exist there
            - `upsert`: (insert + delete): we scan based on unique_key on certain period - then we delete the last data that matched
          2. **`on_schema_change`**
            - `append_new_columns`:
              - every new column added to the data model - data will be shown into the table within is_incremental time range.
              - all deleted columns in data model would be still exist until the model is fully refreshed.
              - pros: prone to less error since the data would still exist in downstream layer
              - cons: the column is not represent the latest model - it might be a technical debt for the future once there is a deletion in data model but the table itself just fully refreshed
            - `sync_all_columns`:
              - every new column (add and update/delete) will be synced when the data building process happens
              - pros: all columns represent latest data model
              - cons: once there is deleted columnd in data model - it might generate error if there is a conumer in downstream layer
            - `fail`:
              - make the data building process fail once new column appears into the developed table
              - fit if the table become very critical ??
              - pros/cons?
              - fit for?
            - `ignore`: 
              - skip/ deny new column added to current table until the table is full refreshed 
              - pros/ cons?
              - fit for?
    5. Microbatch
        - Similar with table and incremental
        - the strategy primarily similar with the incremental
          - the difference is on how they recall/ update the data - instead of using unique_key, they use --time_start and --time_end
          - Cheaper (query processing wise since just focused on time column instead of check one by one unique key)
          - Effective for long query data recall but not as long as --full-refresh (since it's just focus on certain period of time)

  3. How it configure?
    1. First option- and it's recommended (DRY): we can configure directly by dbt_project.yml and categorized based on schema (e.g. staging:view, intermediate:view, core: incremental, etc.)
    2. Second- for certain needs/condition - we can define on model-associated yml --> {{ configuration=(materialization: `<strategy>`)}}
  
## Snapshot
  1. What and Why
    - What: A method to capture information change toward a column(s)
    - Why we need it: Backup process once the data not equipped with cdc on the upstream but the dimension/data changing along the time
      How in Bolt: in Bolt, this case is not relevant due to there is change-data-capture on the upstream, so every event was recorded
  2. How:
    0. Define in snapshots - under yml
    1. Called through dbt snapshot -s `model_name.yml`
    2. Only focus on existing and future data - Further, past data wouldn't be available.
    3. 2 strategies:
        - check: focus on defined column - not sure is it check every single row or how
        - timestamp: focus on every single update on each data (e.g. `last_updated_at`) 
    
      Not sure: is the dbt check every single row `last_updated_at` or 1 table should be has only 1 `last_updated_at` (e.g. through max(`last_updated_at`))

## audit_helper


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

Row counts are equal (10,000,000 vs 10,000,000) and no row exists on only one side. At column level, schema and all 32 columns also matched (section 6.2).

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

## 6. audit_helper on DuckDB

Goal: use the `audit_helper` package to compare `fact_order` and `fact_order_v2`. Macros live in `dbt_packages/audit_helper/macros/`, one file per macro. I never edit them.

### 6.1 How I call a package macro

- Write a one-line call in `analyses/`.
- Run it with `dbt show -s <analysis name>`.
- Primary key argument name differs by macro:
  - `primary_key_columns` (list): `compare_and_classify_*` and `compare_which_*_differ`.
  - `primary_key` (single column): `compare_all_columns` and `compare_column_values`.
- My first attempt used the wrong one: `takes no keyword argument 'primary_key'`. Read the error literally and copy the real name from the macro file.

### 6.2 What worked

| Macro | Result |
|---|---|
| `compare_row_counts` | 10,000,000 vs 10,000,000 |
| `compare_relation_columns` (schema check) | 32 columns, same names, positions and types in both tables |
| `compare_all_columns` (value check) | all 32 columns: 10,000,000 perfect matches, 0 missing |

- This holds only when both tables have the same columns, and it describes `fact_order_v2` as it was before `delivery_fee` was commented out (see 6.4).
- Nulls only in `customer_rating` (3,592,803) and `delivery_time_min` (849,878), identical on both sides.

### 6.3 What failed or is not available

| Macro | Problem |
|---|---|
| `compare_and_classify_relation_rows` | Generated SQL uses `count(distinct a, b)`, which DuckDB rejects (`No function matches ... 'count(VARCHAR, BIGINT)'`). |
| `compare_all_columns` with a column missing on one side | `Binder Error: ... does not have a column named "delivery_fee"` (see 6.4). |
| `compare_which_relation_columns_differ` | Unknown, not tested. |
| `quick_are_relations_identical` | README says Snowflake and BigQuery only. |

**Fallback:** plain SQL `EXCEPT` in both directions (section 5).
- Limits: no modified/added/removed classification, and set semantics hide duplicate differences.
- Mitigation: also compare row counts (done).

### 6.4 Failure case: a column missing on one side

- `compare_relation_columns` showed `fact_order_v2` without `delivery_fee`.
  - Columns: 32 in `fact_order`, 31 in `fact_order_v2`.
  - `delivery_fee` is position 22 in A and empty in B (`has_ordinal_position = False`).
  - Every column after it shifts by one position.
- `compare_all_columns` then errored instead of reporting the missing column.
- Workaround: `exclude_columns = ['delivery_fee']`.
- Cause: **Fact:** I had commented out `f.delivery_fee` in `fact_order_v2.sql` (`-- , f.delivery_fee`) and kept it off while testing.
- Lesson: **run the schema check first, then the value check.**
- What happened when I turned the column back on is in chapter 7.

## 7. Schema drift in an incremental model (`on_schema_change`)

### 7.1 What happened

1. `fact_order_v2` existed as a table without `delivery_fee` (column commented out in the model).
2. I uncommented `f.delivery_fee` and ran a normal `dbt build`. It **failed**.
3. `dbt build --full-refresh` **worked**.

### 7.2 Why

- **Fact:** I never set `on_schema_change` in the model, `dbt_project.yml` or any `.yml` (grep over `.sql` and `.yml` found nothing). dbt therefore used the default, `ignore`.
- **Fact:** `ignore` means dbt does not compare the new query's columns with the existing table.
- **Hypothesis (I did not save the original error text):** the `MERGE` selected `delivery_fee` from the temp relation, but the existing target table had no such column, so DuckDB raised an error. This fits the `ignore` behavior.
- `--full-refresh` drops and rebuilds the table from the current SQL, so the column exists and the error disappears.

### 7.3 Options

| Value | New column in query | Column removed from query |
|---|---|---|
| `ignore` (default) | not checked, can error | not checked |
| `fail` | clear dbt error | clear dbt error |
| `append_new_columns` | `ADD COLUMN` on target | old column stays |
| `sync_all_columns` | added | dropped from target |

- None of the options backfill old rows. Existing rows get `NULL` for the new column. Only `--full-refresh` fills them again.
- `on_schema_change` is a model-level config (also settable in `dbt_project.yml` or a properties `.yml`).

### 7.4 Fix and result

```sql
{{
    config(
        materialized = 'incremental'
        , unique_key = 'order_id'
        , incremental_strategy = 'merge'
        , on_schema_change = 'append_new_columns'
    )
}}
```

- **Fact:** with `append_new_columns` and `delivery_fee` enabled, a normal `dbt build` (no `--full-refresh`) finished `PASS=1 ERROR=0`. `dbt.log` shows the `MERGE INTO "dbt"."main"."fact_order_v2"` ran.

### 7.5 Still to check

- **Unknown:** how many old rows have `delivery_fee = NULL`. Expected: rows outside the 3-day lookback.
  ```sql
  select count(*) as total, count(delivery_fee) as filled from main.fact_order_v2;
  ```
- After such a change, `fact_order_v2` no longer equals `fact_order` for old rows until a full refresh. Re-run the section 5 `EXCEPT` comparison after `--full-refresh`.
- Not tested: `fail`, `sync_all_columns`, removing a column.

### 7.6 Lessons

- `ignore` is not "dbt handles it". It means dbt does nothing, and a new column can break the run.
- Choose `on_schema_change` on purpose for every incremental model. `append_new_columns` is a safe default for facts. Use `fail` if silent schema changes are not acceptable.
- A new column that needs history means a full refresh or a targeted backfill.

## 8. Final model (test scaffold removed)

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

Config: `materialized = 'incremental'`, `unique_key = 'order_id'`, `incremental_strategy = 'merge'`, `on_schema_change = 'append_new_columns'` (added after the drift in chapter 7).

## 9. Mistakes and lessons

- Assumed data ended in September; it ends 2026-06-30. Check `max(date)` before designing a simulation.
- Ran the "pretend" build without `--vars`, so the filter did nothing. Verify with a `max(order_date)` check after every step.
- Tried to open the `.duckdb` file in the CLI while a `dbt` process held the lock (Hypothesis: the VS Code dbt extension). Use `dbt show --inline` instead.
- Run `compare_relation_columns` before `compare_all_columns`. A column missing on one side breaks the value check (6.4).
- Read the error message literally: "takes no keyword argument X" means the argument name is wrong; copy the real name from the macro file.
- Never setting `on_schema_change` is a decision too (it means `ignore`). See chapter 7.

## 10. Not proven yet

- **Late-arriving data.** The dataset has no late rows, so the 3-day lookback was not truly exercised. Possible follow-up: change one old source row, run incrementally, and check whether it updates; also try lookback 0 to show why it exists.
- `on_schema_change`: default `ignore` failed and `append_new_columns` worked for adding a column (chapter 7). Remaining checks are in 7.5.
- Full-refresh cadence for production is a decision, not a measurement. dbt guidance suggests weekly or monthly if size allows.

## 11. Next

- Snapshot `restaurant` into `dim_restaurant_scd2`.
- `delivery_fee` is restored and the model builds (chapter 7). Optionally run the NULL count and a `--full-refresh` + `EXCEPT` re-check.
- Optionally test `compare_which_relation_columns_differ` on DuckDB.
