# Chapter 2: Using Databricks

Open and login to your Databricks account:
Navigate to the SQL Warehouses and start it if not yet started.

In Databricks, go to Workspace and navigate to your user account.
Right-click to import a content from URL:
[download load_raw.py](https://github.com/lukebarousse/dbt_Analytics_Engineering_Course/blob/main/project_2/scripts/load_raw.py)

> Check  your catalog updated.

> Navigate to SQL Editor and make queries on the new tables.

```sql
CREATE CATALOG IF NOT EXISTS dev;
CREATE CATALOG IF NOT EXISTS prod;
```

## Setup Repo

```bash
uv init
uv sync
```

> Using Powershell, activate the environment
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

> Add dbt to the dependencies
```bash
uv add dbt
dbt --version
```

> Modify your profiles.yml and configure your datasource and connection details to the Databricks warehouse. Mine is under: C:\Users\\[user]\\.dbt\profiles.yml
- Find Connection details and use its configuration provided.
- Generate a token, in Databricks, go to Settings > Developer 
- Manage > Access tokens > Generate new token.
- Give it a name such as: dbt-databricks-pipeline
- Select BI Tools for scope.
- Generate and copy the token.

## Create the dbt project
```bash
mkdir analytics
cd analytics
mkdir models, seeds, macros, analyses, tests, snapshots
code dbt_project.yml
```
> Modify the dbt_project.yml for the correct configuration.

```bash
code .gitignore
```

> Add the files and folders that are to be excluded in the repo.

> Test the setup

```bash
dbt debug
dbt show --inline "SELECT COUNT(*) FROM raw.jobs.raw_job_postings"
```

> Install an extension for Databricks queries from within VSCode:
`Databricks Driver for SQLTools`.
- Add a new connection within that extension.
- Enter the credentials obtained from the Databricks Settings.
- Test and save that connections.
- Do for all other schemas as necessary.

