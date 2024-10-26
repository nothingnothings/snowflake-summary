Prerequisites :

Please go through above lectures before taking this assignment.



Follow below steps to complete this assignment,

Step 1 :

Find below requirements,

aws s3 : s3://mybucket/snowpipe/

stage object name : my_pipe_stage.

integration object name : my_s3_int.

File format name : my_s3_csv_format.

Target table : EMP_SNOWPIPE.



Step 2 :

Using details in step 1, write command to create stage object , my_pipe_stage.




CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.MY_S3_CSV_FORMAT
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    FIELD_OPTIONALLY_ENCLOSED_BY='"';


CREATE OR REPLACE STORAGE INTEGRATION MY_S3_INT
    STORAGE_PROVIDER=S3
    ENABLED=TRUE
    TYPE=EXTERNAL_STAGE
    STORAGE_AWS_ROLE_ARN='<your_aws_role_arn>'
    

CREATE OR REPLACE STAGE MY_PIPE_STAGE
    URL='s3://mybucket/snowpipe/'
    FILE_FORMAT=(
        FORMAT_NAME=DEMO_DB.PUBLIC.MY_S3_CSV_FORMAT
    )
    STORAGE_INTEGRATION=MY_S3_INT;



CREATE OR REPLACE PIPE DEMO_DB.PUBLIC.MY_SNOWPIPE 
    AUTO_INGEST=TRUE
    AS 
    COPY INTO DEMO_DB.PUBLIC.EMP_SNOWPIPE
    FROM @DEMO_DB.PUBLIC.MY_PIPE_STAGE;
    




Step 3 :

Create snowpipe by name, my_snowpipe using above details. Snowpipe should load data to emp_snowpipe table.

Mention your syntax below.

Questions for this assignment
Mention your syntax for step 2.




CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.MY_S3_CSV_FORMAT
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    FIELD_OPTIONALLY_ENCLOSED_BY='"';


CREATE OR REPLACE STORAGE INTEGRATION MY_S3_INT
    STORAGE_PROVIDER=S3
    ENABLED=TRUE
    TYPE=EXTERNAL_STAGE
    STORAGE_AWS_ROLE_ARN='<your_aws_role_arn>'
    

CREATE OR REPLACE STAGE MY_PIPE_STAGE
    URL='s3://mybucket/snowpipe/'
    FILE_FORMAT=(
        FORMAT_NAME=DEMO_DB.PUBLIC.MY_S3_CSV_FORMAT
    )
    STORAGE_INTEGRATION=MY_S3_INT;











Mention your syntax for step 3.





CREATE OR REPLACE PIPE DEMO_DB.PUBLIC.MY_SNOWPIPE 
    AUTO_INGEST=TRUE
    AS 
    COPY INTO DEMO_DB.PUBLIC.EMP_SNOWPIPE
    FROM @DEMO_DB.PUBLIC.MY_PIPE_STAGE;
    

