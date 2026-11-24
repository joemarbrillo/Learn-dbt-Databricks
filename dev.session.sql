-- select count(*) from dev.default_staging.stg_job_postings;
-- describe raw.jobs.raw_job_postings;

select job_salary_2, job_salary
from dev.staging.stg_job_postings where job_salary is not null
limit 5


-- 43.7573.75 an hour