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
        regexp_replace(job_via, 'via ', '') as job_via,
        job_posted_at,
        job_salary,
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
        search_location
    from parsed
)
select * from cleaned