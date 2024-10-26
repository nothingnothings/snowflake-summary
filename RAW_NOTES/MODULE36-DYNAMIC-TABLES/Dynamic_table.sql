/***********************************************************************/
/*** Lecture : Introduction on views   ***/

CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.CALL_CENTER
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER;

CREATE OR REPLACE VIEW DEMO_DB.PUBLIC.CALL_CENTER_VW
as
SELECT * FROM DEMO_DB.PUBLIC.CALL_CENTER
where cc_division='6';

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER
where cc_division='6';

update DEMO_DB.PUBLIC.CALL_CENTER
set cc_employees = '988007687'
where cc_division='6';

select * from DEMO_DB.PUBLIC.CALL_CENTER_VW;


/*************************************************************************/
/*** Lecture : Dynamic table introduction   ***/

create or replace table demo_db.public.lineitem
as
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM;

CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.LINEITEM_DYN
  TARGET_LAG = '20 minutes'
  WAREHOUSE = compute_wh
  AS
  select
  l_returnflag,
  l_linestatus,
  sum(l_quantity) as sum_qty,
  sum(l_extendedprice) as sum_base_price,
  sum(l_extendedprice * (
1
 - l_discount)) as sum_disc_price,
  sum(l_extendedprice * (
1
 - l_discount) * (
1
 + l_tax)) as sum_charge,
  avg(l_quantity) as avg_qty,
  avg(l_extendedprice) as avg_price,
  avg(l_discount) as avg_disc,
  count(*) as count_order
from demo_db.public.lineitem
where  l_shipdate <= date '1998-12-01'
group by  l_returnflag,  l_linestatus
order by  l_returnflag,  l_linestatus;


SELECT * FROM DEMO_DB.PUBLIC.LINEITEM_DYN;

ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.LINEITEM_DYN REFRESH;

/*************************************************************************/
/*** Lecture : Dynamic table under the hood part 1  ***/

/***** Create sample table from sample data ********/
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.CALL_CENTER
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER;

/***** Create dynamic table *********/
CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN
  TARGET_LAG = '1 minute'
  WAREHOUSE = compute_wh
  AS
SELECT * FROM DEMO_DB.PUBLIC.CALL_CENTER
   
ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN REFRESH;


/*************************************************************************/
/*** Lecture : Dynamic table under the hood part 2  ***/

INSERT INTO DEMO_DB.PUBLIC.CALL_CENTER
SELECT * FROM DEMO_DB.PUBLIC.CALL_CENTER where cc_call_center_sk=3;

update DEMO_DB.PUBLIC.CALL_CENTER
set cc_call_center_id ='testing dyn'
where cc_call_center_sk=1;

delete from DEMO_DB.PUBLIC.CALL_CENTER
where cc_call_center_sk=5;

delete from DEMO_DB.PUBLIC.CALL_CENTER_DYN
where cc_call_center_sk=2;

/*************************************************************************/
/*** Lecture : Target Lag  ***/
/*** Full refresh vs dynamic refresh ***/

CREATE TABLE  DEMO_DB.PUBLIC.CALL_CENTER_2 CLONE DEMO_DB.PUBLIC.CALL_CENTER

CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN_REFRESH
  TARGET_LAG = '1 minute'
  WAREHOUSE = compute_wh
  AS
SELECT * FROM DEMO_DB.PUBLIC.CALL_CENTER
UNION ALL
SELECT * FROM DEMO_DB.PUBLIC.CALL_CENTER_2 where cc_state='TN'

ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN_REFRESH REFRESH;

SELECT * FROM DEMO_DB.PUBLIC.CALL_CENTER_2

delete from DEMO_DB.PUBLIC.CALL_CENTER_2 where cc_call_center_sk=5

insert into DEMO_DB.PUBLIC.CALL_CENTER_2
select * from DEMO_DB.PUBLIC.CALL_CENTER where cc_call_center_sk=2


/*************************************************************************/
/*** Lecture : Target Lag  ***/

CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN_REFRESH_2
  TARGET_LAG = '1 minute'
  WAREHOUSE = compute_wh
  AS
SELECT A.cc_call_center_sk*5 sum_col, A.* FROM DEMO_DB.PUBLIC.CALL_CENTER A
 INNER JOIN DEMO_DB.PUBLIC.CALL_CENTER_2 B
 ON A.cc_call_center_sk = B.cc_call_center_sk

 ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN_REFRESH_2 REFRESH;


/********/

 CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN_REFRESH_GRP
  TARGET_LAG = '1 minute'
  WAREHOUSE = compute_wh
  AS
SELECT cc_call_center_sk,count(*) cnt FROM DEMO_DB.PUBLIC.CALL_CENTER 
group by cc_call_center_sk

 ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.CALL_CENTER_DYN_REFRESH_GRP REFRESH;


/*********************************************************************/
/*** Lecture : Scenario normal way  ***/

/***** Create stage table and final table  *********/
CREATE TABLE DEMO_DB.PUBLIC.CUSTOMER_STG
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

CREATE TABLE DEMO_DB.PUBLIC.ORDERS_STG
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS;

CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.FINAL_CUST_DATA
(
C_CUSTKEY VARCHAR,
C_NAME VARCHAR,
C_ADDRESS VARCHAR,
O_ORDERSTATUS VARCHAR,
O_ORDERPRIORITY VARCHAR
)

/************** Join stage tables and create intermediate table ***************/

CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA
AS
SELECT A.C_CUSTKEY, A.C_NAME, A.C_ADDRESS,B.O_ORDERSTATUS,B.O_ORDERPRIORITY FROM 
DEMO_DB.PUBLIC.CUSTOMER_STG A
INNER JOIN
DEMO_DB.PUBLIC.ORDERS_STG B
ON A.C_CUSTKEY = B.O_CUSTKEY;


/********************* Merge table to final table ***************************/

MERGE INTO DEMO_DB.PUBLIC.FINAL_CUST_DATA tgt
USING
DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA stg
ON STG.C_CUSTKEY = TGT.C_CUSTKEY
WHEN MATCHED THEN UPDATE SET
tgt.C_NAME = stg.C_NAME,
tgt.C_ADDRESS = stg.C_ADDRESS,
tgt.O_ORDERSTATUS = stg.O_ORDERSTATUS,
tgt.O_ORDERPRIORITY = stg.O_ORDERPRIORITY
WHEN NOT MATCHED THEN INSERT(C_CUSTKEY,C_NAME,C_ADDRESS,O_ORDERSTATUS,O_ORDERPRIORITY)
VALUES(stg.C_CUSTKEY,stg.C_NAME,stg.C_ADDRESS,stg.O_ORDERSTATUS,stg.O_ORDERPRIORITY)

/**************************************************************************/
/**************************************************************************/

/*** Lecture : Scenario Using dynamic table  ***/

CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA_DYN_REFRESH
  TARGET_LAG = '1 minute'
  WAREHOUSE = compute_wh
  AS
    SELECT A.C_CUSTKEY, A.C_NAME, A.C_ADDRESS,B.O_ORDERSTATUS,B.O_ORDERPRIORITY,B.o_orderkey FROM 
    DEMO_DB.PUBLIC.CUSTOMER_STG A
    INNER JOIN
    DEMO_DB.PUBLIC.ORDERS_STG B
    ON A.C_CUSTKEY = B.O_CUSTKEY;

ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA_DYN_REFRESH REFRESH;

SELECT * FROM DEMO_DB.PUBLIC.CUSTOMER_STG WHERE C_NATIONKEY=

delete from  DEMO_DB.PUBLIC.CUSTOMER_STG WHERE C_NATIONKEY=6

SELECT count(*) FROM DEMO_DB.PUBLIC.CUSTOMER_STG

SELECT count(*) FROM DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA_DYN_REFRESH


/**************************************************************************/
/*** Lecture : Creating dependency in dyanamic table  ***/
/*** Lecture : Downstream  ***/

CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.LINEITEM
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM

select * from DEMO_DB.PUBLIC.LINEITEM limit 100

delete from DEMO_DB.PUBLIC.LINEITEM where l_orderkey= 2952839

CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.CUST_ORDER_LINEITEM_DYN
TARGET_LAG = '1 minute'
WAREHOUSE = compute_wh
AS
SELECT A.C_CUSTKEY, A.C_NAME, A.C_ADDRESS,A.O_ORDERSTATUS,A.O_ORDERPRIORITY FROM DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA_DYN_REFRESH A
INNER JOIN 
DEMO_DB.PUBLIC.LINEITEM B
ON A.o_orderkey = B.L_ORDERKEY

select * from DEMO_DB.PUBLIC.CUST_ORDER_LINEITEM_DYN

ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.INTERMEDIATE_CUST_DATA_DYN_REFRESH REFRESH;

select * from DEMO_DB.PUBLIC.LINEITEM limit 100

delete from 
DEMO_DB.PUBLIC.LINEITEM where l_orderkey = 2952838

/**************************************************************/







 
   
