# M3 · CI/CD + dbt state — Action Items

Window: 20-26 Nov 2026 (4 builder days; Sunday off). Output: **PR #3** + `docs/ci_strategy.md`. Branch: `m3-ci-cd`.

Tags: **Fact** = observed or in docs. **Hypothesis** = reasoned, not verified. **Unknown** = to test.

## 1. Problem

Today "correct" means "it runs on my laptop". A team needs every PR checked automatically, without rebuilding everything (my `orders` seed alone is 1.2 GB and `dbt seed` takes minutes).

Senior question this module answers: *"How do you know a PR is safe to merge, and how do you keep that check fast and cheap?"*

## 2. Where it fits

```text
PR opened -> lint (SQLFluff) -> build ONLY what changed (state:modified+) -> tests -> green/red on the PR -> merge
                                       ^ needs main's manifest.json as the "before" picture
```

Analogy: a spell-check that only re-reads the paragraphs you edited, comparing against the last published version (the manifest from `main`).

## 3. Concepts to learn (read in this order, max ~20 min each)

1. **dbt state**: `manifest.json` describes the project at one moment. `--state <dir>` points dbt at another manifest; `state:modified+` = changed nodes and everything downstream. (docs: "About state")
2. **`--defer`**: build only the changed models and read unchanged upstream models from the other environment instead of rebuilding them. (docs: "Defer")
3. **`dbt clone`**: copy (or zero-copy) existing relations into the PR schema. (docs: "dbt clone")
4. **`dbt retry`**: rerun only what failed or was skipped from the last run (reads `run_results.json`). (docs: "dbt retry")
5. **`--empty`**: run models against empty inputs to validate SQL and joins without cost. (docs: "--empty")
6. **GitHub Actions basics**: workflow, job, step, runner, artifact, cache, `on: pull_request`.
7. **SQLFluff**: lint rules, `.sqlfluff` config, dbt templater.

Main reading: [dbt-state-defer-clone-reading.md](dbt-state-defer-clone-reading.md) (6 pages, same format as the M2 materialization guide). The links below are the primary sources.

### Reading links (URLs checked on 2026-11-19; page contents not read in full)

| # | Topic | Link |
|---|---|---|
| 1 | About local state (`--state`, `state:modified`) | https://docs.getdbt.com/reference/node-selection/state-selection |
| 2 | Defer | https://docs.getdbt.com/reference/node-selection/defer |
| 3 | `dbt clone` | https://docs.getdbt.com/reference/commands/clone |
| 4 | `dbt retry` | https://docs.getdbt.com/reference/commands/retry |
| 5 | `--empty` (section "The `--empty` flag") | https://docs.getdbt.com/reference/commands/build |
| 6 | Understanding GitHub Actions | https://docs.github.com/en/actions/get-started/understand-github-actions |
| 7 | SQLFluff | https://docs.sqlfluff.com/en/stable/ |

Also: dbt Learn, *Advanced Deployment* (https://learn.getdbt.com).

## 4. Design constraints specific to my setup (decide early)

- **Data size.** CI cannot seed 2 GB of CSV. CI needs a small sample. (Fact: CSV seeds are git-ignored.) *Decision needed:* how to get a sample into CI (committed sample CSVs under a CI seed path, or a generated sample).
- **`--defer` on DuckDB.** Defer needs the unchanged upstream relations to exist somewhere the CI run can read. A fresh CI runner has an empty DuckDB file, so there may be nothing to defer to. **Hypothesis:** with a small sample the cheapest correct approach is to build everything in CI, and use state/defer only locally or via an uploaded database artifact. *Test early (Loop A).*
- **`dbt clone` on dbt-duckdb.** Fact (docs): zero-copy clone is listed for Snowflake, Databricks and BigQuery; other platforms fall back to a pointer view (`select * from` the source). **Hypothesis:** on DuckDB it creates views, not copies. Unknown: whether dbt-duckdb supports the command at all. Test in Loop A.
- **Single-process lock.** DuckDB allows one process; a CI job runs one dbt command at a time. Locally, close the VS Code dbt extension while testing (it holds the lock).

## 5. Loops

**Loop A: state locally (day 1).** Save a manifest from `main` (`target/manifest.json` -> a `state/` folder, git-ignored). Change one staging model. Run `dbt ls -s state:modified+ --state state/` and explain why each node is listed. Then try `dbt build -s state:modified+ --defer --state state/ --empty`. Note what works on DuckDB and what does not (defer, clone).
Done when: I can explain `state:modified` vs `state:modified+` and what `--defer` needs.

**Loop B: CI data + lint (day 2).** Decide and build the small-data path. Add `.sqlfluff` and lint the project; fix or configure rules, do not mass-reformat in this PR.
Done when: `sqlfluff lint` passes locally on changed files and a CI sample dataset builds in under a few minutes.

**Loop C: GitHub Actions (day 3).** `.github/workflows/ci.yml`: checkout -> Python + dbt-duckdb -> `dbt deps` -> lint -> build on the sample. Add `manifest.json` from `main` as an artifact for state comparison if the design from Loop A needs it. PR template.
Done when: a PR runs the workflow end to end.

**Loop D: red then green (day 4).** Break something on purpose (e.g. a failing test), show CI red, fix it, show green. Screenshot both. Also exercise `dbt retry` on a failed run.
Done when: red and green PR checks exist (portfolio evidence).

**Loop E: write-up (<= 1 hour).** `docs/ci_strategy.md`: what runs on each PR, why `state:modified+`, what defer/clone/retry/`--empty` are for, what did NOT work on DuckDB and why.

## 6. PR #3 description template

```markdown
## Problem
PRs were validated by "works on my laptop".
## Changes
- ci.yml (lint -> build sample), PR template, .sqlfluff
- state/defer/retry usage documented
## Evidence
- red run and green run links/screenshots
## What I am unsure about
```

## 7. Done when (M3)

- PR #3 merged, `docs/ci_strategy.md` exists.
- One PR shows red then green in CI.
- I can explain in 2 minutes: state vs defer vs clone vs retry vs `--empty`, and why CI uses a data sample.

## 8. Out of scope

Governance (M4), Airflow (M5), Snowflake CI, production deployment jobs, cost tuning.

## 9. Open decisions (do not decide now)

- Sample data approach for CI (Loop B).
- Whether state/defer is demonstrated in CI or only locally, given DuckDB (Loop A result).
- M1 PR #1 and M2 are on `main` without PRs. From M3 on: one branch + one PR per module.
