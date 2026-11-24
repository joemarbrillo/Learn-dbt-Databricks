# Chapter 2: Using Databricks

Open and login to your Databricks account:
Navigate to the SQL Warehouses and start it if not yet started.

In Databricks, go to Workspace and navigate to your user account.
Right-click to import a content from URL:
[**download load_raw.py**](load_raw.py). This is a copy from Luke's repo.

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

> **Create few more dimension tables**
```bash
code models/marts/dim_company.sql
code models/marts/dim_skill.sql
code models/marts/bridge_job_skills.sql
```

## Models vs Analyses
```bash
code analyses/in_demand_skills.sql
dbt show --select in_demand_skills
```

` User var() function to pass variables such as {{ var("variable_name")}}`
```bash
dbt show --select in_demand_skills
dbt show --select in_demand_skills --vars 'job_title: Data Engineer'
```

## Unit Tests
- Generic - such as not_null, unique, accepted_values
- Singular - your own rule
- Unit tests - check the logic

### Generic tests

Add the following within the search_term column:
```yaml
data_tests:
  - accepted_values:
      arguments:
        values: ['Data Engineer']
```
And run a test
```bash
dbt test --select stg_job_postings
```
Add a data_tests for job_schedule_type with `warn` severity. The default severity is error.
```yaml
data_tests:
  - accepted_values:
      arguments:
        values: ['Part-time', 'Full-time', 'Contractor', 'Internship']
      config:
        severity: warn
```

`Relationships` - add data_tests for skill_id in bridge_job_skills table in marts schema.
```yaml
data_tests:
  - relationships:
      arguments:
        to: ref('dim_skill')
        field: skill_id
```
Confirm and test the changes:
```bash
dbt test
```

> **Let's create our own generic test**
```bash
code tests/generic/non_negative.sql
```

> **Use it** - `add them to their respective fields`
```yaml
data_tests:
  - non_negative
```

### Singular tests

Create a test to check validity of salaries
```bash
code tests/assert_salaries_sane.sql
dbt test --select assert_salaries_sane
```

### Unit tests

> **Add unit tests to the staging.yml for stg_job_postings model**
```yaml
unit_tests:
  - name: test_parse_salary_shape
    description: This handles a range, a single value, and no salary at all
    model: stg_job_postings
    given:
      - input: source('jobs', 'raw_job_postings')
        rows:
          - {job_id: 1, job_salary: "100K-160K a year"}
    expect:
      rows:
        - {job_id: 1, salary_min: 100000, salary_max: 1860000}
```

Run it
```bash
dbt test --select "test_type:unit"
```

## Snapshots

### SCD (Slowly Changing Dimensions)

- `Type 0` - fixed dimension (change is ignored)
- `Type 1` - overwrite (history is gone)
- `Type 2` - add new row (one row per version)
- `Type 3` - add new attribute (remembers exactly one change)
- `Type 4` - history table (current stays small; versions live aside)
- `Type 5` - type 1/2 hybrid 
- `Type 6` - type 1/2/3 hybrid

For dbt snapshots, it implements `Type 2` SCD.

> **Let's create a snapshot model**
```bash
code models/staging/stg_job_postings_current.sql
dbt show --select stg_job_postings_current
```

> **Query the search_date as parameter**
```bash
dbt show --select stg_job_postings_current --vars '{as_of:2025-09-01}'
```

> **Let's create the snapshots.yml file**

Use the template provided at the official dbt documentation website. Go to the  [snapshot template website.](https://docs.getdbt.com/reference/snapshot-configs?version=2)
```bash
code snapshots/snapshots.yml
dbt snapshot --vars '{as_of: 2025-07-01}'
```
Check that the new snapshot schema was generated.
dbt has added new columns:
- dbt_scd_id
- dbt_updated_at
- dbt_valid_from
- dbt_valid_to

## Incremental Models

- `append` - insert into
- `merge` - merge into
- `delete+insert` - delete -> insert
- `insert_overwrite` - insert overwrite
- `microbatch` - replace where 
```bash
dbt run --select fct_job_postings
```

Refer to the dbt official documentation for templates for incremental loads [`here`.](https://docs.getdbt.com/docs/build/incremental-models?version=2)

Update the fct_job_postings.
```jinja
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='job_id'
    )
}}
```

Go to the SQL editor for Databricks to check for history information
```sql
describe history dev.marts.fct_job_postings
```

```bash
dbt run --select fct_job_postings
```

> **Include the incremental check** if needed such as below:
```jinja
{% if is_incremental() %}

WHERE search_date > (select max(search_date) from {{ this }})

{% endif %}
```

Check some metrics in the warehouse
```sql
select operation,
operationMetrics['numOutputRows'],
operationMetrics['numSourceRows'],
operationMetrics['numTargetRowsUpdated'],
operationMetrics['numOutputRowsInserted']
from (describe history dev.marts.fct_job_postings)
where operation in ('CREATE OR REPLACE TABLE AS SELECT', 'MERGE');
```

> **Do a full refresh**
```bash
dbt run --full-refresh --select fct_job_postings
```


## Summary
### *dbt Commands*
- `dbt compile` - you get the SQL
- `dbt show` - you get the rows
- `dbt run` - 
- `dbt build` - 
- `dbt seed` - 
- `dbt docs generate` - 
- `dbt docs serve` - 
- `dbt snapshot` - 

> **Command options**:
  - --select
  - --full-refresh
  - --inline
  - --vars
