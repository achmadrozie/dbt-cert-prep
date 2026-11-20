# STATE

Last updated: 2026-11-20

## Where I am
- Active module: **M3 CI/CD + state**, branch `m3-ci-cd`. Loop A state and defer exploration completed locally; next: clone and CI design.
- M1 Testing depth: **done** per Rozie (19 Nov): unit tests, custom generic tests, singular test, where, warn_if/error_if, store_failures, freshness, quiz 12 Nov, testing strategy draft `m1_testing_strategy.md`, commit "m1 submission". The "still to verify" list in `m1_action_items.md` is an old note, not a current gap. Only open item: confirm the testing strategy file location if a PR is wanted.
- M0 baseline: done on 3 Nov 2026. Rough score ~3.5/16 (governance, state, and testing weakest). Details in the Project doc `m0-baseline-scorecard`.
- Unknown: whether PR #0 (README + `profiles.yml.example`) is done.

## Schedule (revised 2026-11-07)
- M1 Testing: 9-13 Nov | M2 Incremental + snapshots: 16-19 Nov | M3 CI/CD + state (DuckDB): 20-26 Nov | M4 Governance: 27 Nov - 1 Dec
- 3-5 Dec: baseline re-take + practice tests. Gate: consistently >=75% before the exam.
- **Exam: Mon 7 Dec 2026.** Sat 5 Dec light review only, Sunday off.
- M5 Airflow parked until after the cert (optional). Case study README + Medium after the exam.

## Next action (just one)
- [ ] Continue M3 with clone: distinguish creating a relation in the dev schema from defer rewriting upstream `ref()` addresses. Keep local manifest snapshots under git-ignored `dbt-project/state/` and `dbt-project/prod-artifacts/`.
- Sun is off.

## Decisions
- 2026-11-19: `core` default materialization changed from `incremental` to `table` in `dbt_project.yml`. Reason: dim_* and fact_order_item inherited `incremental` without `unique_key` or `is_incremental()`, so each run appended all rows again (dim_restaurant doubled to 297,082 rows). Only `fact_order_v2` opts in to incremental in its own `config()`. Rule: dimensions without a reliable change timestamp = table; big append-only facts = incremental; history = snapshot.
- 2026-11-19: The 31 failing relationship tests came from a stale `dim_restaurant` (id `567335` was edited to `567335696969` in an M1 experiment). Fixed by rebuilding; relationship tests pass.
- 2026-11-19: `fact_order_v2` full-refresh + EXCEPT vs v1 = 0/0, 10M rows, 10M distinct order_id (recorded in `incremental_proof.md` section 5).
- Practical: `dbt seed` on 45MB-1.2GB CSVs is very slow (Python/agate), and a Ctrl+Z-suspended dbt keeps the DuckDB lock; the VS Code `dbt lsp` also holds it briefly. CI in M3 must use a small data subset.
- 2026-11-07: One local folder is the source of truth. VS Code, Claude Code, and the Claude app are just windows into it. Medium is a published copy.
- 2026-11-08: Use `dbt-cert-prep` as the new repo root and `dbt-project/` as its dbt project. Copy models and local seeds from `dbt-zomato-explore`; use DuckDB. CSV seeds stay local and are ignored by Git because of their size.
- 2026-11-07: No separate `practice/` folder; practice work = PRs in `dbt-project/`.
- 2026-11-07: Repo files are written in English.

- 2026-11-14: Incremental `fact_order_v2` (merge, 3-day lookback, `on_schema_change = 'append_new_columns'`) proven equal to the full table (EXCEPT 0 vs 0, 10M rows). Details: `docs-and-reference/M2 - Materialization/incremental_proof.md`.
- 2026-11-14: Snapshot `dim_restaurant_scd2` uses `strategy: check` on `restaurant_name, city, rating`. Why `check`: I only care about changes in those 3 columns. Why not `timestamp`: the source file is not updated regularly and has no `updated_at` column.
- 2026-11-14 (open): Model versions (`fact_order` v1/v2) were tried early: `fact_order.yml` has `latest_version: 2`, v2 = `fact_order_v2.sql` (incremental), v1 = `fact_order_v1.sql`. Versions are M4 scope, and M4 expects a real breaking change (column rename, v1 deprecated), while my v2 only changes materialization (no consumer-visible change, so it is not a real use of versions). Options: (a) keep versions config in the M2 PR, (b) move it to M4 and keep M2 to plain incremental. Recommended: (b). Decide when ready; the reading guide stays as a note either way.
- 2026-11-07: Scope tightened. Cert exam moved to 7 Dec 2026; M1-M4 before it; Airflow (M5) parked since the cert does not test it. Exam only goes ahead if practice tests are >=75%, otherwise shift one week.

## Blockers / open questions
- Resolve before M1 Loop A: finish seed/staging/downstream validation and establish the new GitHub remote.
- Check dbt Labs reschedule and retake-wait rules before booking the exam (Unknown).
- dbt repo: GitHub remote exists (`origin` = achmadrozie/dbt-cert-prep); only `main` branch so far. Start using one branch + PR per module from M3.
- Warehouse for this practice project: DuckDB. Only one process can hold `dbt.duckdb` at a time; kill stuck `dbt` processes if a lock error appears.
- Hours: decided 2026-11-07 to run 5 days x 6h (4h morning core + 2h afternoon flex, stop by ~15:00). Saturday off/light, Sunday off. Module dates stay fixed; extra hours = buffer, not extra scope. Tripwire (check every Friday): <7h sleep two days in a row, studying from panic/self-anger, or flex block skipped from exhaustion two days in a row -> drop to 4 days x 4-5h. First checkpoint: Fri 13 Nov.
- OMSA Spring 2027 (class starts 11 Jan 2027): finish the cert before that.

## Short log
- 2026-11-20: Compared `state:modified` and `state:modified+`; changed `fact_order_item` selected its downstream mart. Compiled with defer against a manifest pointing to `main`; local `dev` parents won by default, while `--favor-state` resolved them to `main`. Built `prod` successfully and saved its manifest as a new baseline; no nodes selected against that baseline before another code change.
- 2026-11-19 (end of day): M2 closed (incremental proof, snapshot SCD2 proof, `core` default fixed to table). M3 branch + action items + reading guide created. Felt overwhelmed by the state/defer reading late in the day; stopped on purpose. Restart from Loop A, one concept at a time.
- 2026-11-19: Reviewed M2 notes against the plan's "Done when" (runtime table + audit match: met). Listed close-out items above. Added audit_helper recap to `incremental_proof.md` (review found 2 things to fix, see next action). Checked M1 status from `m1_action_items.md`.
- 2026-11-14: M2 mostly done. Incremental proof written; `on_schema_change` learned from a real failure (default `ignore` broke when `delivery_fee` was added; `append_new_columns` fixed it). Snapshot built and SCD2 history checked by me (not re-verified in this session; DuckDB was locked by another process). Tried model versions early (reading guide written). audit_helper: `compare_and_classify_relation_rows` fails on DuckDB, used `EXCEPT` fallback. Lessons: `-s` selects by resource name, not file name; `dbt --no-partial-parse parse` fixes stale-cache errors; editing a seed `id` makes a new key, so edit tracked columns instead.
- 2026-11-08: Migrated the local Zomato dbt project into `dbt-project/`, including models and local seed CSVs. Renamed dbt project/profile, added a safe profile example, and initialized the parent repository. Full DuckDB validation is the next setup step.
- 2026-11-03: Assessment + curriculum, M0 baseline done.
- 2026-11-07: Workspace structure cleanup.
- 2026-11-07: Reviewed AE Readiness docs, tightened scope (exam 7 Dec, M1-M4 first, Airflow parked), moved to 5x6h with tripwires, built `docs-and-reference/dbt-island-map.html` (A3 landscape overview; also published as an artifact). Planning is done; no more setup until PR #1. Reworking dbt testing notes in the Claude app (not yet in the repo).
