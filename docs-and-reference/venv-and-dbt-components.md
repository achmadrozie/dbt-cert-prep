# Venv, dbt Core, and dbt DuckDB

**Venv** is a Python feature that creates a local folder (usually `.venv/`) for a project's Python packages. Activating it makes the terminal use the Python and packages in that folder. It isolates package versions; it does not contain the dbt models or the DuckDB database. Unlike Docker, it does not isolate the operating system.

**`dbt-core`** is the main dbt engine. It reads `dbt_project.yml`, models, seeds, and tests; resolves dependencies such as `ref()`; and runs the workflow.

**`dbt-duckdb`** is the adapter that lets dbt Core connect to and execute SQL in DuckDB. A different database needs a different adapter, such as `dbt-snowflake`.

In this workspace, `.venv/` holds the installed tools, `dbt-project/` holds the project files, and the DuckDB database holds the built data:

```text
dbt-project files → dbt-core → dbt-duckdb → DuckDB database
```

The venv is local and can be recreated, so it should stay out of Git.

## Creating and activating the venv

```bash
cd /Users/achmadrozie/Workstation/dbt-cert-prep
python3 -m venv .venv
source .venv/bin/activate
```

- `cd` moves the terminal into this project folder.
- `-m` tells Python to run a **module**; `venv` is Python's built-in module for creating virtual environments.
- `.venv` is the name of the folder to create. The leading dot makes it a hidden folder on macOS.
- `bin/activate` is a file created inside `.venv/`. The `bin/` folder holds the venv's commands and scripts.
- `source` runs `activate` in the **current terminal**, so later `python`, `pip`, and `dbt` commands use this venv. Run `deactivate` when finished.
