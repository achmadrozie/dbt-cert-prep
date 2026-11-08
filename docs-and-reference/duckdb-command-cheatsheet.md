# DuckDB commands: first steps

DuckDB is a local SQL database. In this project, dbt uses the `dbt-duckdb` adapter to write tables into the database file configured in `profiles.yml` (currently `dbt.duckdb`). Unlike Snowflake or Databricks, there is no separate warehouse service to start for this local setup.

If the DuckDB CLI is installed, run these from `dbt-cert-prep/dbt-project/`:

| Command | What it does |
| --- | --- |
| `duckdb dbt.duckdb` | Opens the project database file in the DuckDB CLI. |
| `.help` | Lists CLI commands. |
| `.tables` | Lists tables and views. |
| `.schema orders` | Shows the SQL definition of the `orders` table. |
| `DESCRIBE orders;` | Shows columns and types. |
| `SELECT * FROM orders LIMIT 5;` | Previews five rows. |
| `SELECT COUNT(*) FROM orders;` | Counts rows. |
| `SHOW DATABASES;` | Shows attached databases. |
| `SHOW SCHEMAS;` | Shows available schemas. |
| `.quit` | Exits the CLI. |

SQL commands end with `;`; CLI commands beginning with `.` do not. Tables appear after `dbt seed` or `dbt run` creates them. If `duckdb` is not found, the CLI is not installed; `dbt-duckdb` can still use DuckDB through Python.
