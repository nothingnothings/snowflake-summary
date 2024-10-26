use role ACCOUNTADMIN;

grant create function on schema trails to role security_officer;
grant create view on schema trails to role security_officer;


use role securityadmin;

create role function_grants;



grant function_grants to role accountadmin
grant select on view patient_data to role accountadmin;
grant select on view patient_data to role analyst;
grant select on view patient_data to role contractor;


use database prod;
usr schema trails;


CREATE OR REPLACE FUNCTION "DEATH_CODE_DATE_REDACT_F"("DIAGNOSIS_CODE" VARCHAR(16777216), "SERVICE_DATE" DATE)
RETURNS DATE
LANGUAGE SQL
AS '
select
case when current_role() in (''ANALYST'',''CONTRACTOR'',''ACCOUNTADMIN'')  then 
        case when diagnosis_code in (''G9382'',''O312'',''O3120'',''O3120X1'',''7681'',''39791'') then  service_date+uniform(5, 14, random()) 
         else
          service_date
           end
else service_date
end service_date
  ';
  

grant usage on function prod.trails.DEATH_CODE_DATE_REDACT_F(VARCHAR,DATE) to role function_grants;

grant function_grants to role accountadmin;
  
  
SELECT
PATIENT_NAME,
DOB,
DIAGNOSIS,
ADR_LINE_1,
ADR_LINE_2,
CITY,
ZIP,
STATE,
POS,
DEATH_CODE_DATE_REDACT_F(DIAGNOSIS,SERVICE_START_DATE) SERVICE_START_DATE_REDACT,
SERVICE_START_DATE,
DEATH_CODE_DATE_REDACT_F(DIAGNOSIS,SERVICE_END_DATE) SERVICE_END_DATE,
SERVICE_END_DATE,
PROVIDER_NAME
FROM PROD.TRAILS.PATIENT;


