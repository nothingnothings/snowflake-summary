XSMALL , 'X-SMALL'
SMALL
MEDIUM
LARGE
XLARGE , 'X-LARGE'
XXLARGE , X2LARGE , '2X-LARGE'
XXXLARGE , X3LARGE , '3X-LARGE'
X4LARGE , '4X-LARGE'

CREATE OR REPLACE WAREHOUSE know_architecture_1 with
warehouse_size='X-SMALL'
auto_suspend = 180
auto_resume = true
initially_suspended=true;

CREATE OR REPLACE TRANSIENT TABLE SUPPLIER AS SELECT * FROM SNOWFLAKE_SAMPLE_DATA."TPCH_SF10000"."SUPPLIER";

-- Case 1

-- Create cluster and do select * from a table.--

select * from SUPPLIER_CLONE;

-- Case 2

/* Create cluster and do select * from a table. run without disabling the cache and run after disabling the cache*/

select * from SUPPLIER_CLONE

Show parameters

alter session set USE_CACHED_RESULT = FALSE

-- Case 3

/* Rerun the query immediatly. Data will be fetched from virtual warehouses*/

select * from SUPPLIER

-- Case 4

/* Suspend warehouse wait for 2 mins and execute the query */

alter warehouse know_architecture_1 suspend

select * from SUPPLIER 

-- Case 4

--

alter warehouse know_architecture_1 suspend

select * from SUPPLIER LIMIT 1000

-- select * from table(information_schema.warehouse_load_history(date_range_start=>dateadd('hour',-1,current_timestamp())));


--select * from table(information_schema.warehouse_metering_history(dateadd('sec',-500,current_date()),current_date()));

--select * from table(information_schema.warehouse_metering_history(current_date()));