In this assignment, try to disable time travel on snowflake table.




Please follow below steps,

Step 1 :

CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART
AS
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART"
Step 2 :

Write command to disable time travel on this table.

Questions for this assignment
Disable time travel on PART table. Mention your command below.









ALTER TABLE DEMO_DB.PUBLIC.PART
SET DATA_RETENTION_TIME_IN_DAYS=0;