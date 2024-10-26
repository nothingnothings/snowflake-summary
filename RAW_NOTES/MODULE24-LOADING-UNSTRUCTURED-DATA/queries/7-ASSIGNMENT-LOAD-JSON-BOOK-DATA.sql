-- 1. Goal
-- In this assignment, we will try to understand approaches to load unstructured data in snowflake.
-- i. Upload data to s3.
-- ii. Push it to snowflake stage.
-- iii. Load data to snowflake.


-- 2. Preparation
-- Please download json data from below location,
-- https://drive.google.com/file/d/184SsnWNUfyoksqjXwl6WodXG2rzn0YNM/view?usp=sharing

-- Once downloaded, upload data to  your s3 location.
-- I assume, you have,
-- i. Integration object.
-- ii. Stage object.
-- iii. Json file format object.
    
-- Write command to upload data from local to s3 using aws cli.
--       aws s3 cp <youdr local path> s3://<your s3 path>

-- Create json file format,
-- CREATE OR REPLACE  FILE FORMAT "DEMO_DB"."PUBLIC".JSON_FORMAT 
-- type=JSON

      

--  Create table, 
    
--       CREATE OR REPLACE TRANSIENT TABLE BOOK_JSON_DATA
-- (
-- OID VARCHAR,
-- AUTHOR VARCHAR,
-- TITLE VARCHAR,
-- BOOKTITLE VARCHAR,
-- YEAR NUMBER,
-- TYPE VARCHAR)

SHOW STORAGE INTEGRATIONS;





CREATE OR REPLACE FILE FORMAT
DEMO_DB.FILE_FORMATS.MY_JSON_FORMAT
    TYPE=JSON;


ALTER STORAGE INTEGRATION S3_INTEGRATION
    SET STORAGE_ALLOWED_LOCATIONS=('s3://new-snowflake-course-bucket/CSV2/');



CREATE OR REPLACE STAGE JSON_S3_STAGE
    url='s3://new-snowflake-course-bucket/CSV2/'
    FILE_FORMAT=(
    FORMAT_NAME=DEMO_DB.FILE_FORMATS.MY_JSON_FORMAT
    )
    STORAGE_INTEGRATION=S3_INTEGRATION;







CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.BOOK_JSON_DATA (
OID VARCHAR,
AUTHOR VARCHAR,
TITLE VARCHAR,
BOOKTITLE VARCHAR,
YEAR NUMBER,
TYPE VARCHAR
);





3. Load data
As we have discussed earlier in the class, we can take below approaches to load unstructured data in snowflake,
1. Load directly to variant column from staging area and parse directly.
2. Load to variant column as staging table and parse and load to structured table.
3. Parse and load from external stage to snowflake internal stage and then copy to structured table.





-- copy from EXTERNAL STAGE TO INTERNAL TABLE STAGING AREA (csv files)....
COPY INTO @DEMO_DB.PUBLIC.%BOOK_JSON_DATA
    FROM (
    SELECT 
    $1:"_id"::STRING AS OID,
    $1:"author"::STRING AS AUTHOR,
    $1:"title"::STRING AS TITLE,
    $1:"booktitle"::STRING AS BOOKTITLE,
    $1:"year"::STRING AS YEAR,
    $1:"type"::STRING AS TYPE
    FROM @DEMO_DB.PUBLIC.JSON_S3_STAGE/dblp.json
    (FILE_FORMAT => DEMO_DB.FILE_FORMATS.MY_JSON_FORMAT)
    );


-- json files got converted into csv, automatically.
LIST @DEMO_DB.PUBLIC.%BOOK_JSON_DATA;



-- copy data/csv files from table staging area into normal table (snowflake), structured data.
-- NOW WE CAN USE "ON_ERROR='CONTINUE'", to have more details about rejected records and each error...
COPY INTO DEMO_DB.PUBLIC.BOOK_JSON_DATA
    FROM @DEMO_DB.PUBLIC.%BOOK_JSON_DATA
    FILE_FORMAT=(
    TYPE=CSV
    )
    ON_ERROR='CONTINUE';
    




-- some errors - "partially loaded"....


-- validate with "TABLE(VALIDATE(<table_id>, job_id=> <your_query_id>)"



SELECT * FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.BOOK_JSON_DATA, JOB_ID => '01ae75b2-0001-4832-0004-6d2a00013066'));



-- 3 REJECTED RECORDS:


-- Numeric value '["2009","2009"]' is not recognized
-- Numeric value '["1989","1989"]' is not recognized
-- Numeric value '["2013","2013"]' is not recognized







-- CREATE NEW TABLE, CONTAINING REJECTED RECORDS:




CREATE OR REPLACE TABLE REJECTED_BOOK_RECORDS 
AS 
SELECT
*
FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.BOOK_JSON_DATA, JOB_ID => '01ae75b2-0001-4832-0004-6d2a00013066'));



SELECT * FROM REJECTED_BOOK_RECORDS;




-- re-copy data, now with purge option (will purge internal table staging area):
TRUNCATE DEMO_DB.PUBLIC.BOOK_JSON_DATA;



COPY INTO DEMO_DB.PUBLIC.BOOK_JSON_DATA
    FROM @DEMO_DB.PUBLIC.%BOOK_JSON_DATA
    FILE_FORMAT=(
    TYPE=CSV
    )
    ON_ERROR='CONTINUE'
    PURGE=TRUE;
    




-- QUESTIONS:

-- Can i use ON_ERROR='CONTINUE' option to reject bad records on unstructured data?



You can, but it won't have any effect. The ON_ERROR=CONTINUE
option only has effects (return rejected records and error messages) 
when used to copy structured data (csv files, etc)...

Storing unstructured data in Variant data type and parsing for required columns is efficient approach ?

No, because our queries will become more processing-intensive 
and slower the more data we begin to store in tables of 
that column data type (we rely on Snowflake native parsing capabilities, which is not optimal).
