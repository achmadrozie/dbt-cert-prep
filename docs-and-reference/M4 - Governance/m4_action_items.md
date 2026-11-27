# M4 · Governance — Action Items

Planned window: 27 Nov - 1 Dec 2026 (revised dates not decided). Branch: `m4-governance`. Output: one PR + short notes.

Reading: [dbt-governance-reading.md](dbt-governance-reading.md).

## Problem

Consumers (marts, BI, an AI agent) need a promise that a model's shape will not change silently.

## How each loop works

1. Read the section.
2. Claude asks; I explain my plan.
3. Claude reviews.
4. I build it.

## Loops

| Loop | Section | Build | Done when |
|---|---|---|---|
| **A** contracts + constraints | 1 | Contract + constraints on `fact_order` and `fact_order_item` | Build passes; a deliberate type mismatch fails it; I can explain contract vs constraint vs test |
| **B** versions + deprecation | 2 | `fact_order` v2 renames a column; v1 gets a `deprecation_date` | Both versions build; downstream models still work; breaking-change check shown with `--state` |
| **C** access + groups | 3 | One group; at least one `private` model | A forbidden `ref()` fails at parse (then removed) |
| **D** exposures | 4 | Streamlit app and AI text-to-SQL | `dbt ls -s +exposure:<name>` lists their upstream |
| **E** wrap-up | - | My notes, PR, CI green, merge | Merged |

Short on time: keep A and B full; make C and D small.

## Things to know before building

- `fact_order` is already versioned (v1 = `fact_order_v1`, v2 = `fact_order_v2`, incremental, alias `fact_order`).
- Four marts use `ref('fact_order')` or `ref('fact_order_item')`.
- A contract needs a `data_type` for **every** column.
- CI has no `--state`, so it will not detect a breaking change where SQL and YAML are both edited. Comparing manifests only needs a parse, not data, so this can be added later (optional).
- Close the editor's dbt extension if a DuckDB lock error appears.

## Done when (M4)

- A column type change cannot slip through: mismatch fails the build, and a versioned breaking change is reported against a baseline.
- I can explain in 2 minutes: contract vs test, versions, access vs grants, exposures.

## Out of scope

dbt Mesh across projects, database `grants`, Semantic Layer changes.
