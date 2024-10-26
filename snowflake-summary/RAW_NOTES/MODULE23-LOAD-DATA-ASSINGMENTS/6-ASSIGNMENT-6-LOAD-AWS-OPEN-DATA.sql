In this assignment, we will try to load aws
 open data set to snowflake data base.

Aws open data can be found in below location,
https://registry.opendata.aws/nyc-tlc-trip-records-pds/

Browse to this location, and try to understand the data.


EX:



aws s3 ls s3://nyc-tlc/trip\ data/






--> isso me deu uma longa lista de arquivos...










--> comando do professor:



For this exercise, you have to load, green taxi trip data. 
green_tripdata*
In your aws console list all the 
files in the location, s3://nyc-tlc/




aws s3 ls s3://nyc-tlc/trip\ data/ | grep green_tripdata







Because you don’t have any idea about the file 
which you are trying to load, it’s always good practice
 to copy a single file from s3 to local and check the data 
 and number of columns.







Write command to copy file , green_tripdata_2013-08.csv
 to your local system.




COMMAND:







aws s3 cp s3://nyc-tlc/trip\ data/green_tripdata_2014-01.parquet /home/arthur/Desktop/PROJETO-SQL-2/MODULE23-LOAD-DATA-ASSINGMENTS;











ok.... funcionou...




Open the file in excel and observe the data.






problema: os arquivos estao em PARQUET, e nao 


em csv...




usei uma extensao, parquet viewer, para visualizar esse arquivo...





agora ficou em um formato tabular...






AS COLUMNS:


VendorID
lpep_pickup_datetime
lpep_dropoff_datetime
store_and_fwd_flag
RatecodeID
PULocationID
DOLocationID
passenger_count
trip_distance
fare_amount
extra
mta_tax
tip_amount
tolls_amount
ehail_fee
improvement_surcharge
total_amount
payment_type
trip_type
congestion_surcharge





ok.. 20 columns...



2 columns datetime...













Now you should be having better understanding of data you are going to load.
So go ahead and create table in snowflake database to capture this data in table.











CREATE OR REPLACE TRANSIENT TABLE GREEN_TRIP_DATA
(
VendorID	NUMBER	NOT NULL,
lpep_pickup_datetime	TIMESTAMP_NTZ	,
lpep_dropoff_datetime	TIMESTAMP_NTZ	,
store_and_fwd_flag	VARCHAR(1)	,
RatecodeID	NUMBER	,
PULocationID	NUMBER	,
DOLocationID	NUMBER	,
passenger_count	NUMBER	,
trip_distance	FLOAT	,
fare_amount	FLOAT	,
extra	FLOAT	,
mta_tax	FLOAT	,
tip_amount	FLOAT	,
tolls_amount	FLOAT	,
ehail_fee	FLOAT	,
improvement_surcharge	FLOAT	,
total_amount	FLOAT	NOT NULL,
payment_type	NUMBER	,
trip_type	NUMBER,
FILE_NAME VARCHAR	 
)





Creating table is first step. But you have to create 
few more objects to facilitate loading data to snowflake.


1. It’s always good practice to create file format object, 

to parse the file you are loading. In this current scenario, you are trying to load PARQUET file.
   Go ahead and create PARQUET file format by name, aws_parquet_format











CREATE OR REPLACE FILE FORMAT aws_parquet_format
    TYPE=PARQUET








2. Create stage object pointing to, 
aws open data  s3 location
.
Create stage object by name ,
 aws_s3_open_data. Mention command below,



Remember, you should be attaching 
file format object to stage object.






 CREATE OR REPLACE STAGE AWS_S3_OPEN_DATA 
    URL='s3://nyc-tlc/trip\ data/'
    FILE_FORMAT=(
        FORMAT_NAME=aws_parquet_format
    )
 
    ;




COPY INTO DEMO_DB.PUBLIC.GREEN_TRIP_DATA 
FROM @DEMO_DB.PUBLIC.AWS_S3_OPEN_DATA
   PATTERN='green_tripdata_*.parquet';







   I hope, by now, you should be having your TABLE, FILE FORMAT OBJECT AND STAGE OBJECT ready.
ANALYSIS
Before we load the data, let’s try to do some analysis.
You can create a view on top
 of s3 data and query or you can query it
  directly. Your choice!!!!












CREATE OR REPLACE VIEW green_trip_view 
AS
SELECT * FROM @DEMO_DB.PUBLIC.AWS_S3_OPEN_DATA;






1. How many distinct green taxi trip data files are there ?
Write the command below:











SELECT 
COUNT(DISTINCT metadata$filename)
FROM 
    DEMO_DB.PUBLIC.GREEN_TRIP_VIEW;









    NAO CONSIGO FAZER SELECT EM NADA 



    DESSE BUCKET DO AWS,


    PQ ESTOU SEM PERMISSAO, APARENTEMENTE..






Failure using stage area. Cause:
 [Access Denied (Status Code: 403; Error Code:
  AccessDenied)]







                    Hint : Use, metadata$filename     build in column name. You can also use, pattern property. Refer link below,
https://docs.snowflake.com/en/user-guide/data-load-considerations-load.html






--> START LOAD:







It’s not a good practice to load all files
 at once to snowflake database.
You should first try 
loading single file to the table.
Refer this link below






https://docs.snowflake.com/en/sql-reference/sql/copy-into-table.html


Try to copy file , green_tripdata_2015-05.csv
  to the table.
Write your copy command below,













Hint : Use ON_ERROR =’CONTINUE’ to reject bad records.

Try to check if there is any rejected records.




Write command to capture rejected records,










If you are sure that, there is not many rejects, then copy all Green_trip* files to table.
Write your copy command below,





Hint : You should only copy  Green_trip* files to table. Use pattern option while copying.
Pattern should be something like, '.*green_tripdata.*csv'








Create file format object. Mention command below,

CREATE FILE FORMAT "DEMO_DB"."PUBLIC".aws_csv_format 
TYPE = 'CSV' 
COMPRESSION = 'AUTO' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1 
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
TRIM_SPACE = FALSE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');
Create stage object by name , aws_s3_open_data. Mention command below,

create or replace stage aws_open_data
url ='s3://nyc-tlc/trip\ data/'
file_format = aws_csv_format
How many distinct green taxi trip data files are there ?

Write the command below,

select distinct metadata$filename
from
@aws_open_data 
(pattern => '.*green_tripdata.*csv') 
Check how many records each, green_trip* file has. Which file has less number of records?

select distinct metadata$filename,count(*)
from
@aws_open_data 
(pattern => '.*green_tripdata.*csv') 
group by metadata$filename
Check total number of records you are going to load.

Write your query below for green_trip*

select count(*)
from
@aws_open_data
(pattern => '.*green_tripdata.*csv')
Try to copy file , green_tripdata_2015-05.csv to the table.

Write your copy command below,

copy into GREEN_TRIP_DATA
from(
select 
$1,
$2,
$3,
$4,
$5,
$6,
$7,
$8,
$9,
$10,
$11,
$12,
$13,
$14,
$15,
$16,
$17,
$18,
$19
from
@aws_open_data 
(file_format => AWS_OPEN_DATA_FORMAT,pattern => '.*green_tripdata.*csv'))
FILE ='green_tripdata_2015-05.csv'
ON_ERROR='CONTINUE'
Write command to capture rejected records,

select * from table(validate(<table_name>, job_id=>'<query_id>'));
