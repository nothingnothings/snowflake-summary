Perquisite :

                    You should be having snowflake trial account created.

                     Use below role and database to do this experiment,

                           USE ROLE ACCOUNTADMIN;

                           USE DATABASE DEMO_DB;

                           USE  XL cluster for this experiment.








Please follow below steps to complete this assignment,

Step 1 :

-- If you have already created above
--  table from previous assignment, skip below command

-- CREATE TABLE DEMO_DB.PUBLIC.LINEITEM AS
-- SELECT * FROM
-- "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF100"."LINEITEM";



Add hash column and create new table,

CREATE TABLE DEMO_DB.PUBLIC.LINEITEM_HASH
AS
SELECT * ,hash(*) column_hash
FROM DEMO_DB.PUBLIC.LINEITEM;


-- EXPLICACAO

-- hash(*) column_hash: 
-- This part of the query calculates a 
-- hash value for all the columns in the source
--  table for each row. The hash(*) function 
--  generates a hash value based on all the columns' 
--  values in that row. The calculated hash values are
--   then included in the result set as a new column 
--   named column_hash.





-- NAO É UMA BOA IDEIA ARMZENAR HASHES EM BANCOS DE DADOS...
