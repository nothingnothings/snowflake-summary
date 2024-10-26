Prerequisite : 

Please go through lecture 50 from section 10 to complete this assignment.

Install SnowCLI and login to snowflake.  Go through lecture 7 section 2 for more information.

USE DATABASE DEMO_DB



Step 1 :

Download data from resource ( Crash_data.csv ).

CREATE OR REPLACE TABLE demo_db.public.crash_data
(
master_record_number number,
year number,
month number,
day number,
accident_date date,
weekend varchar,
hour number,
collision_type varchar(5),
injury_type varchar,
primary_factor varchar,
reported_location varchar
);



Step 2 :

Use put command to upload data to crash_data table ( table stage )

-- in SNOWSQL
snowsql -a <account_identifier> -u nothingnothings

-- in SNOWSQL
put file:///home/arthur/Desktop/PROJETO-SQL-2/MODULE15-LOADING-DATA-INTO-INTERNAL-STAGE/data-to-be-loaded/crash_data.csv @demo_db.public.%crash_data;


Step 3 :

Write copy command to load data from table stage to snowflake table.


COPY INTO demo_db.public.crash_data
FROM @demo_db.public.%crash_data
FILE_FORMAT=(
    SKIP_HEADER=1
    TYPE=CSV
    FIELD_DELIMITER=','
)
ON_ERROR='CONTINUE'



Questions for this assignment
Write put command to load data from local system to table stage.

Write copy command to load data from table stage to snowflake table.

Download resource files