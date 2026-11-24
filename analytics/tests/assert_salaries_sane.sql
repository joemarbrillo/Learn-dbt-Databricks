{{ config(severity='warn') }}

SELECT
job_id,
search_term,
job_title,
salary_min,
salary_max,
salary_period,
salary_currency
 from dev.staging.stg_job_postings
 where salary_period = 'year'
 and COALESCE(salary_max, salary_min) >= 1000000
 and salary_currency = 'USD'