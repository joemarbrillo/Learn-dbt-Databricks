-- -- select count(*) from dev.default_staging.stg_job_postings;
-- -- describe raw.jobs.raw_job_postings;

-- select job_salary_2, job_salary
-- from dev.staging.stg_job_postings where job_salary is not null
-- limit 5


-- -- 43.7573.75 an hour'
describe dev.staging.stg_job_postings;

"col_name","data_type","comment"
"job_id","string","The scrapers posting id"
"job_title","string","Posting title as scraped/"
"company_name","string","Employer name, trimmed."
"job_location","string","Posting location as scraped"
"source_platform","string","Posting platform (job_via with the 'via ' replaced)"
"job_posted_at","string",""
"job_schedule_type","string","As scraped; 12,252 nulls stay null - documented"
"job_work_from_home","boolean","If flagged remote"
"has_no_degree_mentioned","boolean","One of the job extensions"
"has_health_insurance","boolean","One of the job extensions"
"has_dental_insurance","boolean","One of the job extensions"
"has_paid_time_off","boolean","One of the job extensions"
"searched_at","timestamp","Scrape timestamp (search_time renamed)"
"search_date","date","Scrape day."
"search_term","string","The role the scraper searched for"
"search_location","string","Location paremet the scraper searched under."
"job_salary","string",""
"salary_min","decimal(26,2)","Extracted minimum salary"
"salary_max","decimal(26,2)","Extracted maximum salary"
"salary_avg","decimal(31,6)","Average salary"
"salary_period","string",""
"salary_currency","string","Salary currency"
