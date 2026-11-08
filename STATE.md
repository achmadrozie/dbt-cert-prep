# STATE

Last updated: 2026-11-08

## Where I am
- Active module: **M1 Testing depth** (originally planned for weeks 1-2 from 3 Nov 2026)
- M0 baseline: done on 3 Nov 2026. Rough score ~3.5/16 (governance, state, and testing weakest). Details in the Project doc `m0-baseline-scorecard`.
- Unknown: whether PR #0 (README + `profiles.yml.example`) is done.

## Schedule (revised 2026-11-07)
- M1 Testing: 9-13 Nov | M2 Incremental + snapshots: 16-19 Nov | M3 CI/CD + state (DuckDB): 20-26 Nov | M4 Governance: 27 Nov - 1 Dec
- 3-5 Dec: baseline re-take + practice tests. Gate: consistently >=75% before the exam.
- **Exam: Mon 7 Dec 2026.** Sat 5 Dec light review only, Sunday off.
- M5 Airflow parked until after the cert (optional). Case study README + Medium after the exam.

## Next action (just one)
- [ ] Mon 9 Nov: finish the DuckDB seed/model setup, then start M1 Loop A: first unit test for `int_order_financials`.
- Check on Tue 10 Nov evening: is one unit test written and running? If yes, the setup works, leave it alone. If no, fix that step only, not the whole plan.
- Optional, flex block only: 45-min gap map (study guide topics vs M1-M4). No new docs before PR #1 exists.

## Decisions
- 2026-11-07: One local folder is the source of truth. VS Code, Claude Code, and the Claude app are just windows into it. Medium is a published copy.
- 2026-11-08: Use `dbt-cert-prep` as the new repo root and `dbt-project/` as its dbt project. Copy models and local seeds from `dbt-zomato-explore`; use DuckDB. CSV seeds stay local and are ignored by Git because of their size.
- 2026-11-07: No separate `practice/` folder; practice work = PRs in `dbt-project/`.
- 2026-11-07: Repo files are written in English.

- 2026-11-07: Scope tightened. Cert exam moved to 7 Dec 2026; M1-M4 before it; Airflow (M5) parked since the cert does not test it. Exam only goes ahead if practice tests are >=75%, otherwise shift one week.

## Blockers / open questions
- Resolve before M1 Loop A: finish seed/staging/downstream validation and establish the new GitHub remote.
- Check dbt Labs reschedule and retake-wait rules before booking the exam (Unknown).
- dbt repo: local `dbt-cert-prep` initialized as a fresh repo; GitHub remote still pending.
- Warehouse for this practice project: DuckDB.
- Hours: decided 2026-11-07 to run 5 days x 6h (4h morning core + 2h afternoon flex, stop by ~15:00). Saturday off/light, Sunday off. Module dates stay fixed; extra hours = buffer, not extra scope. Tripwire (check every Friday): <7h sleep two days in a row, studying from panic/self-anger, or flex block skipped from exhaustion two days in a row -> drop to 4 days x 4-5h. First checkpoint: Fri 13 Nov.
- OMSA Spring 2027 (class starts 11 Jan 2027): finish the cert before that.

## Short log
- 2026-11-08: Migrated the local Zomato dbt project into `dbt-project/`, including models and local seed CSVs. Renamed dbt project/profile, added a safe profile example, and initialized the parent repository. Full DuckDB validation is the next setup step.
- 2026-11-03: Assessment + curriculum, M0 baseline done.
- 2026-11-07: Workspace structure cleanup.
- 2026-11-07: Reviewed AE Readiness docs, tightened scope (exam 7 Dec, M1-M4 first, Airflow parked), moved to 5x6h with tripwires, built `docs-and-reference/dbt-island-map.html` (A3 landscape overview; also published as an artifact). Planning is done; no more setup until PR #1. Reworking dbt testing notes in the Claude app (not yet in the repo).
