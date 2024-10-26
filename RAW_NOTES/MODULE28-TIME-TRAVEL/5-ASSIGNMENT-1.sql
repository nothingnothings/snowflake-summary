In this assignment, we make changes to table and do time travel.







Prerequisite:                  

You should be having snowflake trial account created.

                     Use below role and database to do this experiment,

                           USE ROLE ACCOUNTADMIN.

                           USE DATABASE DEMO_DB.

                           USE default `COMPUTE_WH` XS warehouse for this experiment.

                           Please go through lecture, Time travel demo and article, More on time travel before starting this assignment.

Please follow below steps to complete this assignment,

Step 1 :

Create table,

CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART
AS
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART"


Step 2 :

Execute :

Note query id for each of these executions.

UPDATE DEMO_DB.PUBLIC.PART
SET P_SIZE='700'
WHERE P_PARTKEY='15032619';
 
Query id-------?

UPDATE DEMO_DB.PUBLIC.PART
SET P_SIZE='701'
WHERE P_PARTKEY='15032622';
 
Query id-------?


Step 3 :

Time travel 10 mins back from current time. Write your query below.



Step 4 :

Travel back to state of table before execution of second update statement.

Mention your query below.



Step 5 :

After some time business asks to you time travel and revert back the changes you did on the table.

Basically you should bring back PART table to it's original state before execution of those update statements.

How you do that ? Mention your solution below.



Questions for this assignment
Mention below your solution for step 3.

Mention below your solution for step 4.

Mention below your solution for step 5.



















CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART
AS
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART";



-- queryId --> 01ae7ba1-0001-4833-0000-00046d2af7c9
UPDATE DEMO_DB.PUBLIC.PART
SET P_SIZE='700'
WHERE P_PARTKEY='15032619';


-- queryId ---> 01ae7ba1-0001-4833-0000-00046d2af7cd
UPDATE DEMO_DB.PUBLIC.PART
SET P_SIZE='701'
WHERE P_PARTKEY='15032622';



-- time travel 10 mins back 
SELECT * FROM DEMO_DB.PUBLIC.PART AT(offset=> -60 * 10);


-- time travel to before dml operation, based on queryId
SELECT * FROM DEMO_DB.PUBLIC.PART BEFORE(statement=> '01ae7ba1-0001-4833-0000-00046d2af7cd');



-- CREATE BACKUP TABLE, COPY TIME-TRAVELLED DATA INSIDE IT; THEN TRUNCATE ORIGINAL TABLE AND INSERT DATA FROM BACKUP TABLE INTO IT...
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART_BKP
AS 
SELECT * FROM DEMO_DB.PUBLIC.PART BEFORE(statement => '01ae7ba1-0001-4833-0000-00046d2af7c9');


TRUNCATE DEMO_DB.PUBLIC.PART;


INSERT INTO DEMO_DB.PUBLIC.PART 
SELECT * FROM DEMO_DB.PUBLIC.PART_BKP;

