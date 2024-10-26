Step 1 :  Create table executing below command,

            CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART
            AS
            SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART";





USE DATABASE DEMO_DB;



  CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART
            AS
            SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART";

SELECT * FROM DEMO_DB.PUBLIC.PART LIMIT 10;



SHOW TABLES LIKE 'PART';




-- Step 2 : 

--               Create another table 

-- DEMO_DB.PUBLIC.PART_CLUSTERED  from DDL of above table created.

--               you can get DDL by executing:
              
select get_ddl('TABLE','DEMO_DB.PUBLIC.PART');

  -- Apply clustering by column, P_TYPE and P_SIZE.

create or replace TRANSIENT TABLE PART_CLUSTERED ( P_PARTKEY NUMBER(38,0), P_NAME VARCHAR(55), P_MFGR VARCHAR(25), P_BRAND VARCHAR(10), P_TYPE VARCHAR(25), P_SIZE NUMBER(38,0), P_CONTAINER VARCHAR(10), P_RETAILPRICE NUMBER(12,2), P_COMMENT VARCHAR(23), STRING_SEARCH VARCHAR(16777216) ) CLUSTER BY (p_type, p_size);




Step 3 :

              -- Insert data into DEMO_DB.PUBLIC.PART_CLUSTERED after applying clustered key.




INSERT INTO DEMO_DB.PUBLIC.PART_CLUSTERED
SELECT * FROM 
DEMO_DB.PUBLIC.PART;







Step 4 : Compare query performance between clustered and  normal table.

               -- 1. 
               
               SELECT * FROM DEMO_DB.PUBLIC.PART
               WHERE P_TYPE ='LARGE BURNISHED BRASS' and p_size=50;

                -- micro partitions scanned:
                    

                -- ANSWER:    243

                
                SELECT * FROM DEMO_DB.PUBLIC.PART_CLUSTERED
                WHERE P_TYPE LIKE'LARGE BURNISHED' and p_size=50;


                -- micro partitions scanned: 


                -- ANSWER: 259


-- the syntax you used to created clustered table. 


ANSWER: 

-- create or replace TRANSIENT TABLE PART_CLUSTERED ( P_PARTKEY NUMBER(38,0), P_NAME VARCHAR(55), P_MFGR VARCHAR(25), P_BRAND VARCHAR(10), P_TYPE VARCHAR(25), P_SIZE NUMBER(38,0), P_CONTAINER VARCHAR(10), P_RETAILPRICE NUMBER(12,2), P_COMMENT VARCHAR(23), STRING_SEARCH VARCHAR(16777216) ) CLUSTER BY (p_type, p_size);




-- NON CLUSTER: 370

-- CLUSTERED: 70

                