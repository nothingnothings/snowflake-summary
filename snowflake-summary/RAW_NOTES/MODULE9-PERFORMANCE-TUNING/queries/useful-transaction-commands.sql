/************************************** SESSION 1 ***********************/

    -- Create virtual warehouse

    create or replace warehouse know_architecture_1 with
    warehouse_size='X-SMALL'
    auto_suspend = 180
    auto_resume = true
    initially_suspended=true;


    -- Create test database and table

    CREATE DATABASE SAMPLE_DATABASE

    CREATE OR REPLACE TRANSIENT TABLE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
    AS
    SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10000.CUSTOMER;

    DESC TABLE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER1

    SELECT * FROM SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER LIMIT 100

    -- CREATE TRANSIENT TABLE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER1 CLONE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
    -- CREATE OR REPLACE TRANSIENT TABLE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER CLONE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER1

    UPDATE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
    SET C_MKTSEGMENT='FURNI'
    WHERE C_MKTSEGMENT='FURNITURE';

    UPDATE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
    SET C_MKTSEGMENT='FURNI'
    WHERE C_MKTSEGMENT='FURNITST';

/****************** Transaction in snowflake ****************/

        begin name t4;

        UPDATE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
        SET C_MKTSEGMENT='FURNI'
        WHERE C_MKTSEGMENT='FURNITURE';


        select current_transaction();

        select to_timestamp_ltz(1582939729441, 3) as transaction_timestamp;

        rollback

        commit 

        SELECT COUNT(*) FROM 
        SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
        WHERE C_MKTSEGMENT='FURNITURE'

UPDATE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
SET C_CUSTKEY='7141371290'
WHERE C_CUSTKEY='714137122'



/************************************** SESSION 2 ***********************/

-- Execute update in parallel to first session

UPDATE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
SET C_MKTSEGMENT='FUR'
WHERE C_MKTSEGMENT='FURNITURE';

-- Try executing drop during execution

drop table SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER

-- undrop  SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER


select * from SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER


   /********************* Check and remove database locks ****************/

        SHOW LOCKS

        SELECT SYSTEM$ABORT_TRANSACTION('1582941819111')
        SELECT SYSTEM$CANCEL_QUERY('0192901b-02d4-cb81-0000-000f7303334d');


        -- Show open transactions with session id & user

        show transactions in account;


        -- Kill all queries for the session

        select SYSTEM$CANCEL_ALL_QUERIES(66354094085);


        -- Abort session

        select SYSTEM$ABORT_SESSION(481060103470)
        
   /********************* Check account parameters ****************/ 

        show parameters
        
        
/********************************* SESSION 3 ***************************/

INSERT INTO SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
SELECT * FROM SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER1 WHERE C_MKTSEGMENT='FURNITURE' LIMIT 1000000;


SELECT COUNT(*) FROM 
SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER
WHERE C_MKTSEGMENT='FURNITURE'