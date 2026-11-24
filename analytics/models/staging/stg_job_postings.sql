{% set extension_keywords=[
        "No degree mentioned",
        "Health insurance",
        "Dental insurance",
        "Paid time off"]
%}

with source AS (
    select *
    from {{ source('jobs', 'raw_job_postings') }}
    where error is not true
    and job_id is not null
), 
parsed as (
    select *,
        FROM_JSON(job_extensions_raw, 'array<string>') as job_extensions
    from source
),
cleaned as (
    select
        job_id,
        job_title,
        trim(company_name) as company_name,
        job_location,
        regexp_replace(job_via, 'via ', '') as source_platform,
        job_posted_at,
        job_schedule_type,
        job_work_from_home,
        {%- for keyword in extension_keywords %}
        ARRAY_CONTAINS(
            job_extensions,
            '{{ keyword }}'
        ) AS has_{{ slugify(keyword) }}
        {{- "," if not loop.last -}}
        {% endfor %},
        search_time as searched_at,
        search_date,
        search_term,
        search_location,
        job_salary,
        {{ parse_salary('min', job_salary) }} AS salary_min,
        {{ parse_salary('max', job_salary) }} AS salary_max,
        ({{ parse_salary('min') }} + {{ parse_salary('max') }}) / 2 as salary_avg,
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency
    from parsed
)
select * from cleaned