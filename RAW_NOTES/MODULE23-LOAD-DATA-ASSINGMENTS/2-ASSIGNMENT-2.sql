CREATE TABLE HR_EMP_DATA
(
Emp_ID	VARCHAR,
Name_Prefix	VARCHAR,
First_Name	VARCHAR,
Middle_Initial	VARCHAR,
Last_Name	VARCHAR,
Gender	VARCHAR,
E_Mail	VARCHAR,
Father_Name	VARCHAR,
Mother_Name	VARCHAR,
Mother_Maiden_Name	VARCHAR,
Date_of_Birth	VARCHAR,
Time_of_Birth	VARCHAR,
Age_in_Yrs	VARCHAR,
Weight_in_Kgs	VARCHAR,
Date_of_Joining	VARCHAR,
Quarter_of_Joining	VARCHAR,
Half_of_Joining	VARCHAR,
Year_of_Joining	VARCHAR,
Month_of_Joining	VARCHAR,
Month_Name_of_Joining	VARCHAR,
Short_Month	VARCHAR,
Day_of_Joining	VARCHAR,
DOW_of_Joining	VARCHAR,
Short_DOW	VARCHAR,
Age_in_Company	VARCHAR,
Salary	VARCHAR,
Last_Hike	VARCHAR,
SSN	VARCHAR,
Phone 	VARCHAR,
Place_Name	VARCHAR,
County	VARCHAR,
City	VARCHAR,
State	VARCHAR,
Zip	VARCHAR,
Region	VARCHAR,
User_Name	VARCHAR,
Password	VARCHAR
);






-- Table 2 :
CREATE TABLE CREDIT_CARD
(
Date	VARCHAR,
Description	VARCHAR,
Deposits	VARCHAR,
Withdrawls	VARCHAR,
Balance	VARCHAR
);






-- named staging area - internal

CREATE OR REPLACE STAGE HR_CREDIT_STAGE;

-- IN SNOWSQL
put file:///home/arthur/Desktop/PROJETO-SQL-2/MODULE23-LOAD-DATA-ASSINGMENTS/HR_CREDIT.csv @DEMO_DB.PUBLIC.HR_CREDIT_STAGE;






CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.CSV_FORMAT
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    NULL_IF=('NULL','null')
    EMPTY_FIELD_AS_NULL=TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH=TRUE
    COMPRESSION=GZIP;


ALTER STAGE HR_CREDIT_STAGE
    SET FILE_FORMAT=(
    FORMAT_NAME=DEMO_DB.PUBLIC.CSV_FORMAT
    );



-- will return "partially loaded" - rows loaded 984, errors 1008 
COPY INTO DEMO_DB.PUBLIC.HR_EMP_DATA
    FROM @DEMO_DB.PUBLIC.HR_CREDIT_STAGE
    FILE_FORMAT=(
        ERROR_ON_COLUMN_COUNT_MISMATCH=TRUE
        FIELD_OPTIONALLY_ENCLOSED_BY='"'
    )
    ON_ERROR='CONTINUE';




-- Query and check records in HR_EMP_DATA
SELECT * FROM HR_EMP_DATA 
LIMIT 100;





-- check rejected records 

SELECT * FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.HR_EMP_DATA, job_id => '01ae6481-0001-4850-0004-6d2a00011136'));




-- Execute copy command to load data to CREDIT_CARD table
COPY INTO  CREDIT_CARD
      from @DEMO_DB.PUBLIC.HR_CREDIT_STAGE
      file_format = (FORMAT_NAME ='csv_format'  ERROR_ON_COLUMN_COUNT_MISMATCH=TRUE  field_optionally_enclosed_by='"')
      ON_ERROR = 'CONTINUE'
      ENFORCE_LENGTH=TRUE;

TRUNCATE TABLE CREDIT_CARD;


SELECT * FROM CREDIT_CARD;




-- check rejected records 
SELECT * FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.CREDIT_CARD, job_id => '01ae6493-0001-4831-0000-00046d2ae275'));



Try to improvise the copy command. You have to enable few more options to maintain data integrity.





