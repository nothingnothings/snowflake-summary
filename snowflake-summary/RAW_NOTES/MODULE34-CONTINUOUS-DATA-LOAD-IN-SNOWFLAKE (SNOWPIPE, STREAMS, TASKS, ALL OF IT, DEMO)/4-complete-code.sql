-- --- Create integration object 
-- CREATE OR REPLACE STORAGE INTEGRATION S3_INTEGRATION
--     TYPE=EXTERNAL_STAGE
--     STORAGE_PROVIDER=S3
--     ENABLED=TRUE
--     STORAGE_AWS_ROLE_ARN='<your_aws_arn_here>'
--     STORAGE_ALLOWED_LOCATIONS=('s3://new-snowflake-course-bucket/CSV3/');

SHOW STORAGE INTEGRATIONS;




ALTER STORAGE INTEGRATION S3_INTEGRATION 
SET STORAGE_ALLOWED_LOCATIONS=('s3://new-snowflake-course-bucket/CSV3/');





DESC INTEGRATION S3_INTEGRATION;





-- Create file format
CREATE OR REPLACE FILE FORMAT CSV_FILE_FORMAT
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    NULL_IF=('NULL', 'null')
    EMPTY_FIELD_AS_NULL=TRUE;






-- Create stage 
CREATE OR REPLACE STAGE SNOW_STAGE
STORAGE_INTEGRATION=S3_INTEGRATION
URL='s3://new-snowflake-course-bucket/CSV3/'
FILE_FORMAT=(
    FORMAT_NAME=CSV_FILE_FORMAT
);








-- Create snowflake table
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.STAGING_TABLE
    (
 Summons_Number	 Number	,
Plate_ID	Varchar	,
Registration_State	 Varchar	,
Plate_Type	 Varchar	,
Issue_Date	DATE	,
Violation_Code	 Number	,
Vehicle_Body_Type	 Varchar	,
Vehicle_Make	 Varchar	,
Issuing_Agency	 Varchar	,
Street_Code1	 Number	,
Street_Code2	 Number	,
Street_Code3	 Number	,
Vehicle_Expiration_Date	 Number	,
Violation_Location	 Varchar	,
Violation_Precinct	 Number	,
Issuer_Precinct	 Number	,
Issuer_Code	 Number	,
Issuer_Command	 Varchar	,
Issuer_Squad	 Varchar	,
Violation_Time	 Varchar	,
Time_First_Observed	 Varchar	,
Violation_County	 Varchar	,
Violation_In_Front_Of_Or_Opposite	 Varchar	,
House_Number	 Varchar	,
Street_Name	 Varchar	,
Intersecting_Street	 Varchar	,
Date_First_Observed	 Number	,
Law_Section	 Number	,
Sub_Division	 Varchar	,
Violation_Legal_Code	 Varchar	,
Days_Parking_In_Effect	 Varchar	,
From_Hours_In_Effect	 Varchar	,
To_Hours_In_Effect	 Varchar	,
Vehicle_Color	 Varchar	,
Unregistered_Vehicle	 Varchar	,
Vehicle_Year	 Number	,
Meter_Number	 Varchar	,
Feet_From_Curb	 Number	,
Violation_Post_Code	 Varchar	,
Violation_Description	 Varchar	,
No_Standing_or_Stopping_Violation	 Varchar	,
Hydrant_Violation	 Varchar	,
Double_Parking_Violation	 Varchar ,
Latitude  Varchar,
Longitude Varchar,
Community_Board  Varchar,
Community_Council  Varchar, 
Census_Tract  Varchar,
BIN  Varchar,
BBL  Varchar,
NTA  Varchar
    );






            -- (uses column data of other table to create table, very handy)
-- Create snowflake tables to load data for LC and NJ cities 
CREATE OR REPLACE TRANSIENT TABLE LC_PARKING LIKE STAGING_TABLE;
CREATE OR REPLACE TRANSIENT TABLE NJ_PARKING LIKE STAGING_TABLE;




TRUNCATE TABLE SNOWPIPE.PUBLIC.LC_PARKING;
TRUNCATE TABLE SNOWPIPE.PUBLIC.NJ_PARKING;


SELECT * FROM DEMO_DB.PUBLIC.STAGING_TABLE;

SELECT * FROM DEMO_DB.PUBLIC.LC_PARKING;
SELECT * FROM DEMO_DB.PUBLIC.NJ_PARKING;















CREATE OR REPLACE PIPE DEMO_DB.PUBLIC.SNOWPIPE
    AUTO_INGEST=TRUE
AS COPY INTO DEMO_DB.PUBLIC.STAGING_TABLE -- meat of the pipe (wrapped part)
    FROM @demo_db.public.SNOW_STAGE/CSV3/
    ON_ERROR='CONTINUE' -- very important
    FILE_FORMAT=(
        FORMAT_NAME=CSV_FILE_FORMAT
        ERROR_ON_COLUMN_COUNT_MISMATCH=FALSE
    );




SHOW PIPES;
SHOW TASKS;


ALTER TASK TGT_MERGE SUSPEND;







SELECT SYSTEM$PIPE_STATUS('snowpipe');
















SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME=>'DEMO_DB.PUBLIC.SNOWPIPE',
        START_TIME=>DATEADD(hour, -4, current_timestamp())
    )
);


SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME=>'DEMO_DB.PUBLIC.SNOWPIPE',
    )
);




SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME=>'DEMO_DB.PUBLIC.SNOWPIPE',
        start_time=>TO_DATE(CURRENT_TIMESTAMP())
    )
);





 --- CREATE STREAM OBJECTS (one for 
---  each final table) TO CAPTURE CHANGES IN STAGING TABLE...

CREATE OR REPLACE STREAM LC_PARKING_STREAM
ON TABLE DEMO_DB.PUBLIC.STAGING_TABLE;


CREATE OR REPLACE STREAM NJ_PARKING_STREAM 
ON TABLE DEMO_DB.PUBLIC.STAGING_TABLE;






-- CREATE TASK TO CAPTURE ONLY LC CITY DATA...
CREATE OR REPLACE TASK DEMO_DB.PUBLIC.LC_PARKING 
    WAREHOUSE=COMPUTE_WH
    SCHEDULE='1 MINUTE'
WHEN 
    SYSTEM$STREAM_HAS_DATA('LC_PARKING_STREAM')
AS 
INSERT INTO SNOWPIPE.PUBLIC.LC_PARKING
SELECT * FROM DEMO_DB.PUBLIC.LC_PARKING_STREAM
WHERE REGISTRATION_STATE='LC';








-- START TASK 
ALTER TASK LC_PARKING RESUME;









-- CREATE TASK TO CAPTURE ONLY NJ CITY DATA...
CREATE OR REPLACE TASK DEMO_DB.PUBLIC.NJ_PARKING 
    WAREHOUSE=COMPUTE_WH
    SCHEDULE='1 MINUTE'
WHEN 
    SYSTEM$STREAM_HAS_DATA('NJ_PARKING_STREAM')
AS 
INSERT INTO SNOWPIPE.PUBLIC.NJ_PARKING
SELECT * FROM DEMO_DB.PUBLIC.NJ_PARKING_STREAM
WHERE REGISTRATION_STATE='NJ';





ALTER TASK NJ_PARKING RESUME;









SELECT * FROM DEMO_DB.PUBLIC.NJ_PARKING;

SELECT * FROM DEMO_DB.PUBLIC.LC_PARKING;

SELECT * FROM DEMO_DB.PUBLIC.STAGING_TABLE;








TRUNCATE TABLE DEMO_DB.PUBLIC.STAGING_TABLE;


SHOW TASKS;


