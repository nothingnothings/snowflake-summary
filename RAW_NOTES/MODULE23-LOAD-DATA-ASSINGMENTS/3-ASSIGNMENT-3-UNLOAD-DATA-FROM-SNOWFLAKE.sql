1. goals



In this assignment we will try to cover below scenarios,
A. Creating named stage and unload data.



CREATE OR REPLACE TABLE TAXI_DRIVE (
    xxx yyyy,
    zzz www
)

CREATE OR REPLACE STAGE DEMO_DB.PUBLIC.STAGE_UNLOAD;



COPY INTO @DEMO_DB.PUBLIC.STAGE_UNLOAD
    FROM DEMO_DB.PUBLIC.TAXI_DRIVE;









B. Unload selected fields
C. Best practice after doing unload.
D. Download data to local system.
E. Calculate overall cost for the activity we performed.





      Question: in the above steps, we have
       not mentioned or created file format object.
        Even without file format object copy
       command seems to work. How it’s possible ?








--unload as parquet file:
COPY INTO @DEMO_DB.PUBLIC.STAGE_UNLOAD
    FROM DEMO_DB.PUBLIC.TAXI_DRIVE
    FILE_FORMAT=(TYPE=PARQUET);







-- xml file:
COPY INTO @DEMO_DB.PUBLIC.STAGE_UNLOAD
    FROM DEMO_DB.PUBLIC.TAXI_DRIVE
    FILE_FORMAT=(TYPE=XML);






-- AVRO file:


COPY INTO @DEMO_DB.PUBLIC.STAGE_UNLOAD
    FROM DEMO_DB.PUBLIC.TAXI_DRIVE
    FILE_FORMAT=(TYPE=AVRO);



-- JSON 
copy into @data_unload/taxi_unload/JSON_
from
taxi_drive
       file_format=(type=JSON)









Once you unload data to staging area from snowflake, 
it’s always a best practice to count
 the records in snowflake 
 table and records in snowflake staging area.


Count records in table and stage :










SELECT COUNT(*) FROM taxi_drive;

RECORDS:



SELECT COUNT(*) FROM @data_unload/taxi_unload;



RECORDS:





List files in staging area,

list @data_unload/taxi_unload;












    3. Unload only selected columns.
You can always unload only few selected column values.
You can apply filter condition and join conditions while doing unload.



Execute below copy command:


COPY INTO @data_unload/taxi_unload/select_
from
(
  SELECT
  trip_id,
  call_type
  FROM taxi_drive
);








LIST @taxi_unload/select_









Count records in table and stage :

    select count(*) from taxi_drive

Mention records count : 

   select count(*) from @data_unload/taxi_unload/select_

Mention records count :










You should also note that, it’s possible to filter data, aggregate data and join data before doing upload.
You can try and check below copy command





EX:









copy into @data_unload/taxi_unload/select_
from
(
  select
  a.trip_id,
  b.call_type
  from
  taxi_drive a,
  taxi_drive b
  where a.origin_call = b.origin_call
  and a.call_type =’Z’
  limit 1000
)
OVERWRITE=’TRUE’








-- WITHOUT OVERWRITE, WE'LL GET AN ERROR....







-- 4. Download DATA to local system.
-- From web console you can download data up to ~100MB. If you want to download your table data more than this, then you have to use get command with SNOWSQL.

-- get @taxi_unload/select_ file:///data-vol/unload/

--          Once downloaded, it’s always a best practice to remove files from the staged area.
--            Otherwise, storage cost will be added to snowflake bill.












-- THE COMMAND IS 

-- ""GET""



-- Remove the files from staged location:




           rm @data_unload/taxi_unload/select_




WITH WAREHOUSE_COST AS
(
select start_time::date as usage_date,
       warehouse_name,
       sum(credits_used) as total_credits_used,
       sum(credits_used) * 3600 total_active_time,
       (sum(credits_used))*1.94 COST_IN_DOLLAR
from snowflake.account_usage.warehouse_metering_history
--where start_time >= date_trunc(day, current_date)
group by 1,2
),
QUERY_COST AS
(
select
QUERY_TYPE,
SUM((TOTAL_ELAPSED_TIME/1000)) ACTIVE_TIME,
SUM((TOTAL_ELAPSED_TIME/1000)*0.0003+CREDITS_USED_CLOUD_SERVICES) ACTUAL_COST,
SUM((TOTAL_ELAPSED_TIME/1000)*0.0003+CREDITS_USED_CLOUD_SERVICES)*1.94 COST_IN_DOLLAR
from table(information_schema.QUERY_HISTORY_BY_WAREHOUSE())
where TOTAL_ELAPSED_TIME>0
group by  QUERY_TYPE
),
ACTUAL_GIVEN AS (
SELECT CRITERIA,ACTIVE_TIME,COST,COST_IN_DOLLAR
FROM
(
SELECT 'ACTUAL' CRITERIA , SUM(ACTIVE_TIME) ACTIVE_TIME, SUM(ACTUAL_COST) COST,SUM(COST_IN_DOLLAR) COST_IN_DOLLAR FROM QUERY_COST
UNION
SELECT 'GIVEN' CRITERIA , SUM(total_active_time) ACTIVE_TIME, SUM(total_credits_used) COST,SUM(COST_IN_DOLLAR) COST_IN_DOLLAR FROM WAREHOUSE_COST
)
  )
SELECT CRITERIA,ACTIVE_TIME,COST,COST_IN_DOLLAR FROM  ACTUAL_GIVEN
UNION
SELECT 'IDEL_TIME_COST' CRITERIA , MAX(ACTIVE_TIME)-MIN(ACTIVE_TIME) ACTIVE_TIME ,MAX(COST)-MIN(COST) COST,(MAX(COST)-MIN(COST))*1.94 COST_IN_DOLLAR FROM ACTUAL_GIVEN



ACTUAL	106.168	0.0358104	0.069472176
GIVEN	24,948.9129888	6.930253608	13.44469199952
IDEL_TIME_COST	24,842.7449888	6.894443208	13.37521982352

















WITH WAREHOUSE_COST AS
(
select start_time::date as usage_date,
       warehouse_name,
       sum(credits_used) as total_credits_used,
       sum(credits_used) * 3600 total_active_time,
       (sum(credits_used))*1.94 COST_IN_DOLLAR
from snowflake.account_usage.warehouse_metering_history
--where start_time >= date_trunc(day, current_date)
group by 1,2
),
QUERY_COST AS
(
select
QUERY_TYPE,
SUM((TOTAL_ELAPSED_TIME/1000)) ACTIVE_TIME,
SUM((TOTAL_ELAPSED_TIME/1000)*0.0003+CREDITS_USED_CLOUD_SERVICES) ACTUAL_COST,
SUM((TOTAL_ELAPSED_TIME/1000)*0.0003+CREDITS_USED_CLOUD_SERVICES)*1.94 COST_IN_DOLLAR
from table(information_schema.QUERY_HISTORY_BY_WAREHOUSE())
where TOTAL_ELAPSED_TIME>0
group by  QUERY_TYPE
),
ACTUAL_GIVEN AS (
SELECT CRITERIA,ACTIVE_TIME,COST,COST_IN_DOLLAR
FROM
(
SELECT 'ACTUAL' CRITERIA , SUM(ACTIVE_TIME) ACTIVE_TIME, SUM(ACTUAL_COST) COST,SUM(COST_IN_DOLLAR) COST_IN_DOLLAR FROM QUERY_COST
UNION
SELECT 'GIVEN' CRITERIA , SUM(total_active_time) ACTIVE_TIME, SUM(total_credits_used) COST,SUM(COST_IN_DOLLAR) COST_IN_DOLLAR FROM WAREHOUSE_COST
)
  )
SELECT CRITERIA,ACTIVE_TIME,COST,COST_IN_DOLLAR FROM  ACTUAL_GIVEN
UNION
SELECT 'IDEL_TIME_COST' CRITERIA , MAX(ACTIVE_TIME)-MIN(ACTIVE_TIME) ACTIVE_TIME ,MAX(COST)-MIN(COST) COST,(MAX(COST)-MIN(COST))*1.94 COST_IN_DOLLAR FROM ACTUAL_GIVEN















QUESTIONS.
In the above data upload scenario, you might have faced error while upload JSON data.
But it’s possible to upload table data in 
snowflake as JSON file.
Go to doc link,
https://docs.snowflake.com/en/sql-reference/functions/object_construct.html
Read through it and write down the copy command to upload table data as json file below,




-- What is your observation after trying
--  to upload AVRO, JSON and XML data from 
--  snowflake to internal stage.



Table data can be converted/sent as parquet data,
in snowflake...  but if  you try with other unstructured 
file formats, it won't work.





You can upload JSON data from snowflake table to internal staging area. Can you please mention the command  used ?




The command is:


COPY INTO @data_unload/taxi_unload/
FROM 
(
    SELECT object_construct(*) FROM taxi_drive
)
file_format=(TYPE=JSON);









object construct function:

Returns an OBJECT constructed from the arguments.

See also:
OBJECT_CONSTRUCT_KEEP_NULL

Syntax
OBJECT_CONSTRUCT( [<key1>, <value1> [, <keyN>, <valueN> ...]] )

OBJECT_CONSTRUCT( * )
Returns
The data type of the returned value is OBJECT.


