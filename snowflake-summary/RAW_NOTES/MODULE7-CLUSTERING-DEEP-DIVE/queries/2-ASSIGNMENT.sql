Please follow below steps to complete the assignment,

Step 1 :

             Create table executing below statement, 

CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART (
	     P_PARTKEY NUMBER(38,0),
	     P_NAME VARCHAR(55),
	     P_MFGR VARCHAR(25),
	     P_BRAND VARCHAR(10),
	     P_TYPE VARCHAR(25),
	     P_SIZE NUMBER(38,0),
	     P_CONTAINER VARCHAR(10),
	     P_RETAILPRICE NUMBER(12,2),
	     P_COMMENT VARCHAR(23) );



Step 2 : The above table will always be filtered or joined 
by columns, P_TYPE and P_SIZE.

               Keeping above statement in mind.
                Write query to load data into PART table from,

               "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART"





INSERT INTO DEMO_DB.PUBLIC.PART
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART"
ORDER BY p_type, p_size;