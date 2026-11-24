{{ config(materialized='ephemeral')}}

SELECT
    job_id,
    job_title,
    company_name,
    job_location,
    job_schedule_type,
    job_work_from_home,
    has_no_degree_mentioned,
    has_health_insurance,
    has_dental_insurance,
    has_paid_time_off,
    salary_min,
    salary_max,
    salary_period,
    salary_currency,
    searched_at
from {{ ref('stg_job_postings') }}
where search_date <= cast('{{ var('as_of', run_started_at) }}' as date)
qualify row_number() over(
    partition by job_id
    order by searched_at desc
) = 1