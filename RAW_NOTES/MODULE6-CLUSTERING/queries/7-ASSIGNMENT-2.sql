-- Please follow below steps to 
-- complete this assignment,
-- Step 1 :
-- Execute below query and create table,

CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.PART AS
SELECT *,
    P_BRAND || '#' || P_PARTKEY STRING_SEARCH
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1000"."PART";


-- Step 2 :
--              Execute below query,

SELECT *
FROM DEMO_DB.PUBLIC.PART
WHERE p_partkey = 65985958;


-- Record partitions scanned,


-- 180 partitions scanned for where p_partkey=65985958;


-- Step 3 :

            --  Execute below query,

             SELECT * FROM DEMO_DB.PUBLIC.PART
             WHERE STRING_SEARCH='Brand#45#65985958';


        -- Record partitions scanned: 

        -- 243 scanned for STRING_SEARCH.







-- 3. Even though both queries 
-- returns same result. Why there 
-- is a difference in micro partitions scanned ? 
-- Leave your comments below.


--- ANSWER:


    -- Snowflake scans micro partitions
    --  well if you use numeric values as
    --   filter than string value. Over 
    --   numeric values snowflake will
    --    maintain stats internally about min,
    --     max values. Which helps to scan micro
    --      partitions easily.