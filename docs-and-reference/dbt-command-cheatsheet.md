# dbt commands: daily reference

Run these from `dbt-cert-prep/dbt-project/` with the venv active. In this setup, `dbt debug` succeeds and `dbt seed` runs without `--profiles-dir`, so the examples omit that option.

| Command | What it does |
| --- | --- |
| `dbt --version` | Shows installed dbt Core and adapter versions. |
| `dbt debug --profiles-dir .` | Checks project configuration and the DuckDB connection. |
| `dbt parse` | Reads project files and checks whether dbt can understand the project; it does not build tables. Think of it like dbt inspecting a recipe book: it checks that recipes and cross references make sense before cooking. |
| `dbt ls` | Lists resources dbt recognizes, such as models, seeds, and tests. |
| `dbt seed` | Loads CSV files from `seeds/` into DuckDB tables. |
| `dbt run` | Builds models; does not run data tests. |
| `dbt test` | Runs data and unit tests. |
| `dbt build` | Runs selected seeds, models, snapshots, and tests in dependency order. |
| `dbt source freshness` | Checks whether configured sources have fresh data. Relevant once source freshness is configured. |
| `dbt docs generate` | Generates documentation and lineage artifacts; use `dbt docs serve` to view them locally. |

To focus on one model, add `--select int_order_financials` to commands such as `dbt run`, `dbt test`, or `dbt build`.

## What does “parse” mean?

Parsing is dbt's **reading and organizing step**. It reads SQL, YAML, project settings, and Jinja such as `ref()`, then builds a map of project resources and their dependencies. The recipe-book analogy: dbt checks that each recipe is readable and that references to other recipes point somewhere real. It does not cook anything or create model tables. `dbt parse` is useful for catching project-structure and configuration problems early; `dbt run` or `dbt build` actually executes the work.

- Parse (atau sering disebut parsing / **penguraian**) adalah proses menganalisis rangkaian simbol, teks, atau data secara sistematis untuk memecahnya menjadi bagian-bagian yang lebih kecil dan mengubahnya ke dalam format yang terstruktur agar mudah dipahami serta diproses oleh komputer atau sistem


