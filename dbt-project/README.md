# dbt cert prep project

This is the Zomato dbt model set copied from the local `dbt-zomato-explore` workspace for Analytics Engineering practice. The intended pipeline is local CSV seeds → staging → intermediate → core → marts, using DuckDB.

The seven CSV seeds are kept locally under `seeds/` and ignored by Git because they total about 2.3 GB. The source copy remains in `dbt-zomato-explore/dbt/seeds/`. A fresh clone needs those files supplied separately before `dbt seed` or a full build can run.

## Local setup

1. Install compatible `dbt-core` and `dbt-duckdb` versions.
2. Copy `profiles.yml.example` to `profiles.yml`.
3. From this directory, run `dbt debug --profiles-dir .` and `dbt parse --profiles-dir .`.
4. After placing the CSV files in `seeds/`, run `dbt seed --profiles-dir .` and then work through the staging and downstream models.

The project is a migrated starting point. Seed types and model compatibility still need the planned DuckDB setup and repair pass before claiming a passing full build.
