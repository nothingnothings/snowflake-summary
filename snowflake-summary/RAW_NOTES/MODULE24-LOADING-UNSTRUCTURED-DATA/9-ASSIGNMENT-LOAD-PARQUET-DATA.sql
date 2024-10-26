Prerequisites :

Please go through above videos before taking this assignment.



Please download below document and follow the steps to solve this assignment.





Questions for this assignment:



Can you reject bad records using ON_ERROR copy options ?









1. Goals
In this assignment , we will load parquet file from s3 to snowflake table.


A. Understand limitation while copying parquet file.
B. Learn to parse parquet file.









-- 2. PREPARATION
-- Let’s upload data as parquet
--  format from snowflake to s3. We will load this
--   data again back to snowflake. During the process
--    we will see different challenges.

-- Create file format,


CREATE OR REPLACE FILE FORMAT "DEMO_DB"."PUBLIC".MY_ PARQUET _FORMAT
TYPE= PARQUET
COMPRESSION = 'AUTO'






Upload data to s3 as parquet file,
COPY INTO @DEMO_DB.PUBLIC.RAVEN_POC_STAGE/CUSTOMER_PARQUET/
FROM
(
SELECT
  C_CUSTOMER_SK	,
C_CUSTOMER_ID	,
C_CURRENT_CDEMO_SK	,
C_CURRENT_HDEMO_SK	,
C_CURRENT_ADDR_SK	,
C_FIRST_SHIPTO_DATE_SK	,
C_FIRST_SALES_DATE_SK	,
C_SALUTATION	,
C_FIRST_NAME	,
C_LAST_NAME	,
C_PREFERRED_CUST_FLAG	,
C_BIRTH_DAY	,
C_BIRTH_MONTH	,
C_BIRTH_YEAR	,
C_LOGIN	,
C_EMAIL_ADDRESS	,
C_LAST_REVIEW_DATE	
FROM DEMO_DB.PUBLIC.CUSTOMER_TEST
)
file_format = DEMO_DB.PUBLIC.MY_PARQUET_FORMAT
Header = true
Overwrite = true



















3. Query and load data to snowflake table.
Let’s query uploaded data from snowflake,
SELECT $1	 
FROM @DEMO_DB.PUBLIC.RAVEN_POC_STAGE/CUSTOMER_PARQUET1/
(file_format => DEMO_DB.PUBLIC.MY_PARQUET_FORMAT)

Parse file,
SELECT $1:C_CUSTOMER_SK	,
$1:C_CUSTOMER_ID	,
$1:C_CURRENT_CDEMO_SK	,
$1:C_CURRENT_HDEMO_SK	,
$1:C_CURRENT_ADDR_SK	,
$1:C_FIRST_SHIPTO_DATE_SK	,
$1:C_FIRST_SALES_DATE_SK	,
$1:C_SALUTATION	,
$1:C_FIRST_NAME	,
$1:C_LAST_NAME	,
$1:C_PREFERRED_CUST_FLAG	,
$1:C_BIRTH_DAY	,
$1:C_BIRTH_MONTH	,
$1:C_BIRTH_YEAR	,
$1:C_BIRTH_COUNTRY	,
$1:C_LOGIN	,
$1:C_EMAIL_ADDRESS	,
$1:C_LAST_REVIEW_DATE	 
FROM @DEMO_DB.PUBLIC.RAVEN_POC_STAGE/CUSTOMER_PARQUET/
(file_format => DEMO_DB.PUBLIC.MY_PARQUET_FORMAT)

Create table as below,
create or replace TRANSIENT TABLE CUSTOMER_PARQUET (
	C_CUSTOMER_SK NUMBER(5,0),
	C_CUSTOMER_ID VARCHAR(16),
	C_CURRENT_CDEMO_SK NUMBER(38,0),
	C_CURRENT_HDEMO_SK NUMBER(38,0),
	C_CURRENT_ADDR_SK NUMBER(38,0),
	C_FIRST_SHIPTO_DATE_SK NUMBER(38,0),
	C_FIRST_SALES_DATE_SK NUMBER(38,0),
	C_SALUTATION VARCHAR(10),
	C_FIRST_NAME VARCHAR(20),
	C_LAST_NAME VARCHAR(30),
	C_PREFERRED_CUST_FLAG VARCHAR(1),
	C_BIRTH_DAY NUMBER(38,0),
	C_BIRTH_MONTH NUMBER(38,0),
	C_BIRTH_YEAR NUMBER(38,0),
	C_LOGIN VARCHAR(13),
	C_EMAIL_ADDRESS VARCHAR(50),
	C_LAST_REVIEW_DATE VARCHAR(10)
);
Try to copy uploaded data to CUSTOMER_PARQUET table.
COPY INTO CUSTOMER_PARQUET
FROM
(
SELECT 
$1:C_CUSTOMER_SK,
$1:C_CUSTOMER_ID,
$1:C_CURRENT_CDEMO_SK,
$1:C_CURRENT_HDEMO_SK,
$1:C_CURRENT_ADDR_SK,
$1:C_FIRST_SHIPTO_DATE_SK,
$1:C_FIRST_SALES_DATE_SK,
$1:C_SALUTATION,
$1:C_FIRST_NAME,
$1:C_LAST_NAME,
$1:C_PREFERRED_CUST_FLAG,
$1:C_BIRTH_DAY,
$1:C_BIRTH_MONTH,
$1:C_BIRTH_YEAR,
$1:C_LOGIN,
$1:C_EMAIL_ADDRESS,
$1:C_LAST_REVIEW_DATE	 
FROM @DEMO_DB.PUBLIC.RAVEN_POC_STAGE/CUSTOMER_PARQUET/
)
file_format = DEMO_DB.PUBLIC.MY_PARQUET_FORMAT
ON_ERROR = 'CONTINUE'

Can you mention for which column you are facing the error.
Column name : Can you


Can you reject bad records using ON_ERROR copy options ?
Note your observation below,








NO, YOU CANNOT. THe copy command only works when 

you are not copying unstructured files/data (
    thats the reason we preferably copy 

    to internal table staging area before 
    we run the copy command, with ON_ERROR='CONTINUE',
    to 

    copy data into snowflake table....
)