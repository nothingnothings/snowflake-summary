Prerequisites :

Please go through above docx before taking this assignment.



Download the document below and follow the instructions to solve this assignment.

Questions for this assignment
In our previous demo, we had already gone through similar exercise on book data.

Keeping that in mind, can you define your approach to load this data to snowflake table ?

Create,

1. File format object.

2. Stage object.

3. Execute copy command.

Paste your solution below,





In our previous demo, we had already gone through similar exercise on book data.

Keeping that in mind, can you define your approach to load this data to snowflake table ?

Create,

1. File format object.

2. Stage object.

3. Execute copy command.

Paste your solution below,










In this assignment, we will be loading unstructured.
i. You will understand how to parse and load unstructured data to snowflake.











Let’s assume a business scenario, where you got twitter data in aws s3.
Your job is to load this data to snowflake database. 
Data can be found in below location,
https://drive.google.com/file/d/12dWBwgWLReXncB5omUYi7jF_5ekDm_Yb/view?usp=sharing

Your job is to,
1. Copy this data to aws s3.
2. From s3 copy this data to snowflake table. 








--> we copy file from local filesystem 

to aws,

with this command:




aws s3 cp /home/arthur/Downloads/twitter.json.tar.gz s3://new-snowflake-course-bucket/CSV2/





THE FILES ARE IN .json.tar.gz format...



--> .json.tar.gz format doesnt work..



I extracted the tar, then recompressed in gzip format...









--> so, we need to define "COMPRESSION=GZIP"...









EX:






CREATE OR REPLACE FILE FORMAT MY_JSON_FORMAT
    TYPE=JSON
    COMPRESSION=GZIP;




CREATE OR REPLACE STAGE JSON_S3_STAGE
    url='s3://new-snowflake-course-bucket/CSV2/'
    FILE_FORMAT=(
    FORMAT_NAME=DEMO_DB.FILE_FORMATS.MY_JSON_FORMAT
    )
    STORAGE_INTEGRATION=S3_INTEGRATION;











-- CREATE FINAL TABLE:








CREATE OR REPLACE TRANSIENT TABLE TWITTER_PARSED 
(
    OID	VARCHAR(16777216),
    TEXT	VARCHAR(16777216),
USER_NAME	VARCHAR(16777216),
FOLLOWERS_COUNT	NUMBER(38,0),
FRIENDS_COUNT	NUMBER(38,0),
LOCATION	VARCHAR(16777216),
DESCRIPTION	VARCHAR(16777216)
);







-- COPY FROM EXTERNAL S3 STAGE TO INTERNAL TABLE STAGING AREA...
COPY INTO @DEMO_DB.PUBLIC.%TWITTER_PARSED
    FROM (
        SELECT 
        $1:_id."$oid" AS OID,
        $1:text AS TEXT,
        $1:user.name AS USER_NAME,
        $1:user.followers_count AS FOLLOWERS_COUNT,
        $1:user.friends_count AS FRIENDS_COUNT,
        $1:user.location AS LOCATION,
        $1:user.description AS DESCRIPTION
        FROM @DEMO_DB.PUBLIC.JSON_S3_STAGE/twitter.twitter2.json.gz
    );





LIST @DEMO_DB.PUBLIC.%TWITTER_PARSED;

REMOVE @DEMO_DB.PUBLIC.%TWITTER_PARSED;


SELECT 
*
FROM @DEMO_DB.PUBLIC.%TWITTER_PARSED
LIMIT 100;



-- COPY FROM INTERNAL TABLE STAGING AREA INTO TABLE ITSELF
COPY INTO DEMO_DB.PUBLIC.TWITTER_PARSED
    FROM (
        SELECT 
        $1 AS OID,
        $2 AS TEXT,
        $3 AS USER_NAME,
        $4 AS FOLLOWERS_COUNT,
        $5 AS FRIENDS_COUNT,
        $6 AS LOCATION,
        $7 AS DESCRIPTION
        FROM @DEMO_DB.PUBLIC.%TWITTER_PARSED
    )
    ON_ERROR='CONTINUE';
    PURGE=TRUE;
