USE DATABASE PROD;

USE SCHEMA TRAILS;

CREATE OR REPLACE SECURE VIEW PATIENT_DATA COPY GRANTS AS
SELECT
PATIENT_NAME,
DOB,
DIAGNOSIS,
ADR_REDACT_F(ADR_LINE_1,POS) ADR_LINE_1,
ADR_REDACT_F(ADR_LINE_2,POS) ADR_LINE_2,
CITY,
ZIP,
STATE_BY_POS_REDACT_F(STATE,POS) STATE,
POS,
DEATH_CODE_DATE_REDACT_F(DIAGNOSIS,SERVICE_START_DATE) SERVICE_START_DATE_REDACT,
--SERVICE_START_DATE,
DEATH_CODE_DATE_REDACT_F(DIAGNOSIS,SERVICE_END_DATE) SERVICE_END_DATE,
--SERVICE_END_DATE,
PROVIDER_NAME
FROM PROD.TRAILS.PATIENT;



grant select on view patient_data to role accountadmin;
grant select on view patient_data to role analyst;
grant select on view patient_data to role contractor;





/******************** Views **************************/

USE DATABSE PROD;

USE SCHEMA TRAILS;

CREATE OR REPLACE FUNCTION "ZIP_REDACT_F"("ZIP" NUMBER(38,0))
RETURNS NUMBER(38,0)
LANGUAGE SQL
AS '
SELECT 
  case when current_role() in (''ANALYST'',''CONTRACTOR'') then 
        case when zip in (''967'', ''431'', ''967'' , ''965'' , ''963'', ''966'', ''945'', ''945'') then  ''000''
         else
         zip
             end       
    else
      zip
      end
   zip
  ';
  
  
CREATE OR REPLACE FUNCTION "STATE_BY_POS_REDACT_F"("STATE" VARCHAR(16777216), "POS" NUMBER(38,0))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS '
SELECT 
case when current_role() in (''CONTRACTOR'',''ANALYST'') then 
 case when (state =''AA'' and pos = ''4'') or (state =''DU'' and pos = ''9'') or (state =''GV'' and pos = ''33'') or (state =''MH'' and pos = ''55'') or (state =''NP'' and pos = ''56'') or (state =''OT'' and pos = ''9'') or (state =''OT'' and pos = ''9'') or (state =''TT'' and pos = ''4'')  then ''XX'' end
             
    else
    state
      end
   state
  ';
  

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
  
  
  
CREATE OR REPLACE FUNCTION "DIAGNOSIS_CODE_REDACT_F"("DIAGNOSIS_CODE" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS '
SELECT 
case when diagnosis_code in (''S55091D'', ''S82421H'', ''S37828D'', ''J239'', ''R019'') and current_role() in (''CONTRACTOR'',''ANALYST'') then substring(diagnosis_code,1,3)
             else
                case when diagnosis_code in (''Y09'', ''Y09'', ''V3101'', ''V3101'', ''79913'', ''Y389X1A'', ''E9688'') then ''00''
                 else
                   diagnosis_code
                    end
               end
   diagnosis_code
  ';
  

CREATE OR REPLACE FUNCTION "ADR_REDACT_F"("ADR" VARCHAR(16777216), "POS" NUMBER(38,0))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS '
SELECT 
  case when current_role() in (''ANALYST'',''CONTRACTOR'') then 
        case when pos in (''4'',''9'',''33'',''55'',''56'',''9'',''4'') then  NULL
         else
         Adr
             end       
    else
      Adr
      end
   Adr
  ';
  