# Chapter 2: Using Databricks

Open and login to your Databricks account:
Navigate to the SQL Warehouses and start it if not yet started.

In Databricks, go to Workspace and navigate to your user account.
Right-click to import a content from URL:
[**download load_raw.py**](https://github.com/lukebarousse/dbt_Analytics_Engineering_Course/blob/main/project_2/scripts/load_raw.py)

> **Check your catalog updated.**

> **Navigate to **SQL Editor** and make queries on the new tables.**

```sql
CREATE CATALOG IF NOT EXISTS dev;
CREATE CATALOG IF NOT EXISTS prod;
```

## Setup Repo

```bash
uv init
uv sync
```

> **Using Powershell, activate the environment**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

> **Add dbt to the dependencies**
```bash
uv add dbt
dbt --version
```

> **Modify your profiles.yml and configure your datasource and connection details to the Databricks warehouse.** Mine is under: C:\Users\\[user]\\.dbt\profiles.yml
- Find Connection details and use its configuration provided.
- Generate a token, in Databricks, go to **Settings** > **Developer** 
- **Manage** > **Access tokens** > **Generate new token**.
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
> **Modify the `dbt_project.yml` for the correct configuration.**

```bash
code .gitignore
```

> **Add the files and folders that are to be excluded in the repo.**

> **Test the setup**

```bash
dbt debug
dbt show --inline "SELECT COUNT(*) FROM raw.jobs.raw_job_postings"
```

> **Install an extension for Databricks queries from within VSCode:
`Databricks Driver for SQLTools`.**
- Add a new connection within that extension.
- Enter the credentials obtained from the Databricks Settings.
- Test and save that connections.
- Connect to all other schemas as necessary.

## The Three Layers
`Refer to dbt documentation`
- **Staging** - modular building blocs
- **Intermediate** - stacking layers of logic with clear and specific purpose
- **Marts** - bringing together our modular pieces into a wide, rick vision of the entities

> **Create the three layers in models folder.**
```bash
cd models
mkdir staging, intermediate, marts
```

> **Modify the dbt_project.yml to configure the models.**
```yml
models:
  analytics:
    staging:
      +materialized: view
      +schema: staging
    intermediate:
      +materialized: iew
      +schema: staging
    marts:
      +materialized: table
      +schema: staging
```

> **Create a sources.yml and mirror the Databricks structure.**
```bash
code models/sources.yml
```

> **Check the current structure.**
```bash
dbt ls
```

> **Create the staging model**
```bash
cd models
code staging/stg_job_postings.sql
dbt build
```
`If there are issues in creation, check the permissions for the user such as:`
- [OP_NOT_SUPPORTED_READ_ONLY] CreateNamespace true is not supported in read-only session mode. SQLSTATE: 42KD1`
  
  Go to Databricks SQL Editor to modify use of the catalog.

```sql
GRANT USE CATALOG ON CATALOG dev TO `joemar.brillo@outlook.com`;
GRANT CREATE SCHEMA ON CATALOG dev TO `joemar.brillo@outlook.com`;
```

> **Create the stg_job_skills model**
```bash
code models/staging/stg_job_skills.sql
dbt build
```

> **Create staging.yml**
```bash
code models/staging/staging.yml
dbt build
```

> Add the following within the dbt_project.yml to persist docs for our models
```yaml
models:
  analytics:
    +persist_docs:
      relation: true
      columns: true
```

```bash
dbt build
```
- Check the information schema now reflecting descriptions for columns for models.
```sql
select column_name, comment from dev.information_schema.columns;
```

## Jinja

> **Formats:**
- {{ expressions here }}
- {% statements here %}
- {# comments here #}

See [`stg_job_posting.sql`](analytics/models/staging/stg_job_postings.sql) for example

## Macros

> **Formats:**
```macro
{% macro <function_name>(params) %}
<Jinja statements here>
<or, Sql statements here>
{% endmacro %}
```

> **Create slugify.sql**
```bash
code macros/slugify.sql
```
To run it
```bash
dbt compile --inline "{{ slugify('Paid time off') }}"
```
> **Installing macros**
```bash
code packages.yml
dbt deps
```

> **From the dbt docs serve -> Macros sections, copy and paste the default__generate_schema_name macro to replace the generated schema:**
```bash
code macros/generate_schema_name.sql
dbt compile --inline "{{ generate_schema_name('staging', none) }}"
dbt build
```

> **Drop the old default_staging schema if needed**
```sql
DROP SCHEMA dev.default_staging;
```

> **Create a parse_salary macro**
```bash
code macros/parse_salary.sql
dbt compile --select stg_job_postings
dbt build
```

## The Star Schema
> **Add int_skill_observations.sql**
```bash
code models/intermediate/int_skill_observations.sql
```

> **Add intermediate.yml**
```bash
code models/intermediate/intermediate.yml
```

> **Create fact table**
```bash
code models/marts/fct_job_postings.sql
dbt build
```

> **Create marts.yml**
```bash
code models/marts/marts.yml
```

> **The seeds**
```bash
code seeds/skill_categories.csv
```

> **Update the dbt_project.yml to add seeds section:**

```bash
dbt seed
```

```bash
code models/marts/dim_company.sql
code models/marts/dim_skill.sql
code models/marts/bridge_job_skills.sql
```