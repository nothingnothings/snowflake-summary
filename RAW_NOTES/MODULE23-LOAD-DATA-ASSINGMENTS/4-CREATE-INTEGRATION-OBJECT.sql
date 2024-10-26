In this assignment you will be creating integration object. Integration object helps to make
 secure connection with aws s3.








 Download the document and follow to steps
  to create integration object.

Once creation of integration object is complete, create,

   1. Stage object by name my_s3_stage.

   2. File format object by name my_s3_csv_format.

Assume url for s3 is , 's3://hartfordstar2/'









CREATE OR REPLACE STORAGE INTEGRATION EXAMPLE_INTEGRATION
    TYPE=EXTERNAL_STAGE
    STORAGE_PROVIDER=S3
    ENABLED=TRUE;
    -- STORAGE_AWS_ROLE_ARN= 'arn:aws:iam::269021562924:role/new-snowflake-access'
    -- STORAGE_ALLOWED_LOCATIONS 


CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.MY_S3_CSV_FORMAT
    TYPE='CSV';


CREATE OR REPLACE STAGE DEMO_DB.PUBLIC.S3_STAGE 
        url='s3://hartfordstar2/'
        FILE_FORMAT=(
            FORMAT_NAME=DEMO_DB.PUBLIC.MY_S3_CSV_FORMAT
        )
        STORAGE_INTEGRATION=EXAMPLE_INTEGRATION

    
