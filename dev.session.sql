-- select count(*) from dev.default_staging.stg_job_postings;
-- describe raw.jobs.raw_job_postings;

select column_name, comment from dev.information_schema.columns
where table_name='raw_job_postings';