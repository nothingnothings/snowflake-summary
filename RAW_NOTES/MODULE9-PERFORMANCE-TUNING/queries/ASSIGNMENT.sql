
USE DATABASE DEMO_DB;

ALTER WAREHOUSE COMPUTE_WH
SET WAREHOUSE_SIZE= XLARGE;





Please follow below steps to complete this assignment,

Step 1 :

-- CREATE TABLE DEMO_DB.PUBLIC.LINEITEM AS
-- SELECT * FROM
-- "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF100"."LINEITEM";
-- Before you run below query wait for 2 to 3 mins. Snowflake will take some time to update it's metadata.

-- select *
-- from snowflake.information_schema.table_storage_metrics
-- where table_name = 'LINEITEM';
-- From the output of above query, record,

-- Mention active bytes :

-- Mention time travel bytes :












-- MORAL: MELHOR EXECUTAR TUDO EM A SINGLE TRANSACTION,

-- EM VEZ DE EXECUTAR 
-- TUDO 


-- COM DIFERENTES STATEMENTS ESPARSOS (


--     economizamos COSTS COM STORAGE, 

--     COM TIME TRAVEL BYTES...
-- )
