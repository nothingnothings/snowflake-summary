Step 1 :

You are asked to take row sample of table, "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF100TCL"."WEB_RETURNS" .

You should select 10% of total records randomly as sample.

Create a table by name , DEMO_DB.PUBLIC.WEB_RETURNS_ROWSAMPLE from the sample.

Mention table size.



Step 2 :

For the same table, "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF100TCL"."WEB_RETURNS" take block sample.

You should select 10% of total records randomly as sample.

Create a table by name , DEMO_DB.PUBLIC.WEB_RETURNS_BLOCKSAMPLE from the sample.

Mention table size.



Step 3 :

Which sampling query came back quick?

Questions for this assignment
Mention your command for step1. And mention below table size as well.

Mention your command for step 2. And mention below table size as well.

Mention your comments for question on step 3.

















CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.WEB_RETURNS_ROWSAMPLE
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_RETURNS SAMPLE ROW(10);
-- time: about 11 minutes 
-- table-size: 32gb


CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.WEB_RETURNS_BLOCKSAMPLE
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_RETURNS SAMPLE SYSTEM(10);
-- time: 4m 15s
-- table-size: 29.6gb



-- The system/block query was significantly faster.


