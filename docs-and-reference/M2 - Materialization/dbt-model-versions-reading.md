# dbt Model Versions: A Short Reading Guide

For: Rozie · Companion to "dbt Materializations: A Reading Guide" · Written Nov 2026 from my `fact_order` v1/v2 experiment
Length: about 2 A4 pages. Not re-checked against docs.getdbt.com in this session, so doc-based claims are tagged **Docs (recall)**.

Tags: **Fact** = observed in my own runs. **Docs (recall)** = from dbt docs as I remember them, not tested. **Unknown** = not verified.

## 1 · The problem it solves

A model has consumers (dashboards, other teams, downstream models). I want to make a **breaking change**: rename or drop a column, change a type, change the grain, change a metric definition. If I edit in place, every consumer breaks at once. If I create `fact_order_new` by hand, nobody knows which one is official.

**Model versions** let `v1` and `v2` live side by side. Consumers move one at a time, then `v1` is retired.

Not breaking, so no versioning needed: adding a column (that is `on_schema_change`), or an internal model only I use.

### Example from my project

`fact_order.sales_amount` is used by a mart (`SUM(sales_amount)`), a BI dashboard ("Total Sales") and ad-hoc analyst queries. I want to rename it to `gross_sales_amount`.

- **Edit in place:** all three break at the same moment ("column not found"). None of them had time to change.
- **`fact_order_new` by hand:** nothing breaks, but there are two similar tables. Nobody knows which is official or when the old one dies.
- **Model versions:** v1 keeps `sales_amount`, v2 has `gross_sales_amount`. One name, a marked latest, and consumers migrate one by one.

| Change | Old consumers |
|---|---|
| Rename or drop a column | break with an error |
| Change a type | can break |
| Change grain or metric definition | **no error, numbers silently change** (the most dangerous) |
| Add a column | safe |

### Versioning = gradual sunset

It is a deprecation lifecycle, not just a version label. It gives three things:
- **Coexistence:** v1 and v2 live together, so nothing breaks suddenly.
- **Official marker:** `latest_version` says which one is recommended.
- **Deadline:** `deprecation_date` on v1 warns consumers still using it. **Docs (recall)**, not tested.

Without the deadline it is only "two versions forever".

Limit: versioning only covers the dbt side. A BI dashboard outside dbt is not notified automatically. Telling its users is a team process, not a dbt feature.

## 2 · Mental model

One model name, many versions. The name is shared; the version is the extra address.

```
fact_order
 ├─ v1  -> file fact_order_v1.sql   -> table fact_order_v1
 └─ v2  -> file fact_order_v2.sql   -> table fact_order   (latest)
```

`ref('fact_order')` with no version goes to `latest_version`. `ref('fact_order', v=1)` pins a version.

## 3 · Config (what I ran)

In the model's properties `.yml`, `versions:` is a key **inside** the model (same level as `name:`), not a new list item:

```yaml
models:
  - name: fact_order
    latest_version: 2
    columns: ...            # shared by all versions
    versions:
      - v: 2
        defined_in: fact_order_v2   # SQL file name, no .sql
        config:
          alias: fact_order         # warehouse table name
      - v: 1                        # defined_in omitted: default is fact_order_v1.sql
```

## 4 · Three names, three jobs

Easy to mix up. This was most of my debugging.

| Name | What it is | Where it comes from |
|---|---|---|
| **Model name** | What `ref()` uses: `ref('fact_order', v=2)` | `name:` in yml |
| **File name** | Where the SQL lives | `defined_in`, default `<model>_v<v>.sql` |
| **Table name** | What appears in DuckDB/Snowflake | `alias`, default `<model>_v<v>` |

- **Fact:** `ref('fact_order_v2')` fails once versioning is on. `fact_order_v2` is a file name, not a model name.
- **Fact:** `dbt build -s fact_order_old` matched nothing (that was my first name for the v1 file). `-s` uses `fact_order_v1` or `fact_order.v1`.
- **Fact:** `fact_order_v2` worked as a selector only because the file name happened to equal the version name.
- **Docs (recall):** `v` can be a number or a string, but the `_v<value>` pattern in default names and selectors stays.
- Simplest setup (what I use now): name files `fact_order_v1.sql` and `fact_order_v2.sql`, and skip `defined_in`.

## 5 · Gotchas I hit

1. **`versions:` indentation.** Writing `- versions:` made a second list item under `models`. Error: `list element for 'models' does not have a name attribute`.
2. **`latest_version` needs a `versions:` block.** Only `latest_version: 2` is not enough.
3. **`defined_in` must match the real file name.** I renamed `fact_order.sql` and the yml still pointed at the old name. Warning: `Did not find matching node for patch with name 'fact_order'`.
4. **Analyses and tests with old refs break parse.** Plain `ref('fact_order')` now means the latest version. Compare old vs new with `v=1` and `v=2`.
5. **Stale parse cache.** After removing versioning, dbt said `fact_order.v2 ... is not in the graph`. Fix: `dbt --no-partial-parse parse`.
6. **A new alias means a new table.** v1 now builds to `fact_order_v1`, which did not exist. Audit macros then saw no columns and `dbt show` failed with `syntax error at or near "limit"`. Build the version first.
7. **Reusing an alias reuses the table.** v2 (incremental) with `alias: fact_order` merged into the old `fact_order` table. For a clean build: `dbt build -s fact_order_v2 --full-refresh`.

## 6 · When to use, when not to

**Use when**
- The model is shared (BI, other teams, other projects) and the change is breaking.
- Consumers need a migration window.
- Paired with governance: contracts and `public` access (M4). **Docs (recall)**

**Do not use when**
- The model is internal, or all consumers can change in one PR.
- The change is additive (new column).
- The result is identical and only the build changes. My `fact_order` v2 (table to incremental, same data) is this case. In production I would just change the materialization. Here it is a practice run.

## 7 · Retiring a version

- **Docs (recall):** `deprecation_date` on the old version produces warnings for consumers still using it.
- Migrate consumers to `v=2` one by one, then delete v1 and its entry in `versions:`.
- **Unknown:** how `deprecation_date` behaves on dbt-duckdb, and how `include`/`exclude` of columns per version behaves. Not tested.

## 8 · Check-yourself

1. What does `ref('fact_order')` return when `latest_version: 2`? What about `ref('fact_order', v=1)`?
2. Name the three names (model, file, table) and where each is set.
3. Why would `-s` with a file name like `fact_order_old` match nothing?
4. Is adding a column a reason to create v2?
5. v2 uses `alias: fact_order` and v1 has no alias. Which table does v1 build to?

## 9 · Where this sits

Part of **M4 governance**, next to contracts and access. Here it is only a first experiment: `fact_order` v1/v2.
