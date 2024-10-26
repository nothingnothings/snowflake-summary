-- STEP 1 :

--             Download the file attached to the resource.

-- STEP 2 :

            -- Create table as



CREATE OR REPLACE TRANSIENT TABLE TOBACCO

(

        Year       NUMBER ,

        Quarter NUMBER(1,0) ,

        LocationAbbr VARCHAR(2) ,

        LocationDesc VARCHAR(50) ,

        TopicDesc VARCHAR ,

        MeasureDesc VARCHAR(50) ,

        DataSource VARCHAR(3) ,

        ProvisionGroupDesc VARCHAR(50) ,

        ProvisionDesc VARCHAR(50) ,

        ProvisionValue VARCHAR ,

        Citation VARCHAR ,

        ProvisionAltValue NUMBER ,

        DataType VARCHAR ,

        Comments VARCHAR ,

        Enacted_Date DATE ,

        Effective_Date DATE ,

        GeoLocation ARRAY ,

        DisplayOrder NUMBER ,

        TopicTypeId VARCHAR(3) ,

        TopicId VARCHAR(100) ,

        MeasureId VARCHAR(20) ,

        ProvisionGroupID VARCHAR(10) ,

        ProvisionID NUMBER

);



-- STEP 3:

--    Create a named stage by name, My_internal_stage.

--    Create a file format by name My_csv_format.

-- STEP 4 :

--     Login to snowsql and upload data from your local system to the named stage.

snowsql -a uu18264.us-east-2.aws -u nothingnothings

put file:///home/arthur/Downloads/CDC_STATE_System_Tobacco_Legislation_-_Smokefree_Indoor_Air.csv @demo_db.public.my_internal_stage;

-- STEP 5 :

--    1. Write SQL query to check uploaded data in the named stage(internal stage).  ( You should write it in web console.)

   LIST @DEMO_DB.PUBLIC.MY_INTERNAL_STAGE;


   2. Count the number of records in staging area. Without loading data to a snowflake

   SELECT 
COUNT(*)
FROM @DEMO_DB.PUBLIC.MY_INTERNAL_STAGE;

count:
611,526



STEP 6:

   > Write copy command to load data from named stage to table.

                 While Loading data using copy command please apply below transformation to `LocationAbbr` column.
                
                if LocationAbbr='GU' then code it as GK.

                 This condition you should apply within copy command only.




    CREATE OR REPLACE TABLE save_copy_errors
     AS SELECT *
      FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.TOBACCO, JOB_ID=>'01ae5a2a-0001-464c-0000-00046d2a2479'));



    ALTER STAGE DEMO_DB.PUBLIC.MY_INTERNAL_STAGE
        SET COPY_OPTIONS=(
        ON_ERROR='CONTINUE'
        )
        FILE_FORMAT=(
            FORMAT_NAME=DEMO_DB.FILE_FORMATS.MY_CSV_FORMAT
        );



    COPY INTO DEMO_DB.PUBLIC.TOBACCO
    FROM @DEMO_DB.PUBLIC.MY_INTERNAL_STAGE;





    COPY INTO DEMO_DB.PUBLIC.TOBACCO
    FROM (
        SELECT
        T.$1,
        T.$2,
        iff(T.$3='GU','GK',T.$3),
        T.$4,
        T.$5,
        T.$6,
        T.$7,
        T.$8,
        T.$9,
        T.$10,
        T.$11,
        T.$12,
        T.$13,
        T.$14,
        T.$15,
        T.$16,
        T.$17,
        T.$18,
        T.$19,
        T.$20,
        T.$21,
        T.$22,
        T.$23
        FROM @DEMO_DB.PUBLIC.MY_INTERNAL_STAGE AS T
    );




    CREATE OR REPLACE TABLE save_copy_errors
     AS SELECT *
      FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.TOBACCO, JOB_ID=>'01ae644d-0001-4831-0000-00046d2ae1d9'));







--   > You should not use any inline copy options in copy command like on_error, pattern etc... you should set these properties within stage object itself.

--    > If you face any errors allow records to get rejected.

--    > Collect all rejected records. How many 
--    rejected records are created and what is the rejection reason.

    1,898,658

    reason ->  Numeric value '20GRP' is not recognized (wrong data type, string in numeric value)

--    > Create a separate table by name, TOBACCO_REJECTED to keep all rejected records.




-- STEP 7 :

--    Mention all the reasons for records rejection.

    Numeric value '20GRP' is not recognized (wrong data type, string in numeric value)


    Error parsing JSON: 11/01/1987


    and many more....


-- STEP 8:

--     remove the uploaded file in named staging area.


    rm @demo_db.public.my_internal_stage;


-- Questions for this assignment
-- When you create a table a default staging area is assigned to the table. Can you mention a few drawbacks of using table staging area versus named staging area?


The main drawback is that any files uploaded to that table staging area cannot be 
used in copy commands targetting other tables, and files in one table staging area 
cannot be moved to another table staging area/internal staging area.

If a person doesnt have access to a given table, he/she also wont have access 
to its respective table staging area.

Access Control in named staging areas is more flexible and reliable (we can grant and 
revoke permissions to roles/users, etc.)


-- When you upload data from local system to staging area which compression format is used.

Gzip. (.gz)

-- When you try to execute copy command multiple times after copying your data. Will the data again get copied ? if not why.

If you are trying to copy the same file over and over, No, it wont. The only way 
to bypass this restriction is by defining "FORCE=TRUE" in the COPY command.


-- For how long rejected records will be available in snowflake? what command you use to retrieve rejected records in snowflake.


14 days. The command is 

SELECT *
      FROM TABLE(VALIDATE(<table_name>, JOB_ID=>'<your_query_id>'));



-- How many rejected records you got in your first run.

Only 196 rows were loaded, 611526 rows were parsed, and 611,330 rows errored-out.

-- How you analyze the reason for rejection.  Please mention your analysis.


1) Reading the value of the column "ERROR" in the rejected table 

2) running a query using distinct on that column,
such as:

SELECT DISTINCT(ERROR) FROM rejected_tobacco;

3) analyze each error and it's cause.



Write command to list files in staging area.


LIST @demo_db.public.my_internal_stage;
