Execute below commands to complete this assignment,



Step 1 :

             Create clustered table as below,

create or replace TRANSIENT TABLE DEMO_DB.PUBLIC.PART (
	P_PARTKEY NUMBER(38,0),
	P_NAME VARCHAR(55),
	P_MFGR VARCHAR(25),
	P_BRAND VARCHAR(10),
	P_TYPE VARCHAR(25),
	P_SIZE NUMBER(38,0),
	P_CONTAINER VARCHAR(10),
	P_RETAILPRICE NUMBER(12,2),
	P_COMMENT VARCHAR(23)
) CLUSTER BY(P_TYPE,P_SIZE);
 
Insert into DEMO_DB.PUBLIC.PART
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART";
 


Step 2 :

              Write command to get clustering information over columns, P_TYPE and P_SIZE.

Questions for this assignment
For step 2, mention the command to get clustering information.


SELECT SYSTEM$CLUSTERING_INFORMATION('DEMO_DB.PUBLIC.PART', '(P_TYPE, P_SIZE)');




then, Mention total_constant_partition_count

The total_constant_partition_count is 0.


What is average depth ?



