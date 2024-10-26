-- REVIEWING SYNTAX, TIPS AND TRICKS OF ENTIRE SECOND COURSE -- 



-- MODULE 1 --


-- M1 - Warehouses, Cost Monitoring Queries and General Syntax


-- Snowflake is designed for OLAP (Analytics) 
-- and OLTP (Transactional) workloads.

-- Each Snowflake Account is provisioned in a 
-- single geographic region.

-- Warehouse means a group of nodes 
-- and clusters which  helps to process the data. It is 
-- a named abstraction for one or more compute nodes.

-- In most cases, compute costs, when using Snowflake normally, are higher
-- than storage costs (5-6 times the storage cost, generally).

--  The credit consumption by the compute layer in
--  Snowflake is primarily based on Warehouse 
--  size and the amount of data processed.

-- To choose the correct size of our Warehouse, we should experiment
-- with a representative query of a workload on a variety of sizes, to find
-- the one that correctly matches the desired run-times.

-- Development teams should use same Warehouse during development, to maximize 
-- caching and reduce processing costs.

-- For the Development Warehouse, we should set auto-suspend to 15 minutes, to 
-- maximize the Virtual Warehouse local cache (which is cleared everytime our Warehouse 
-- is shutdown/suspended); this is the better practice, even if our Warehouse stays on for
-- a while longer, as developers will constantly run queries on this Warehouse and utilize its 
-- cache.

-- To optimize the number of parallel operations for a load, 
-- Snowflake recommends aiming to produce data files roughly 100-250 MB (or larger)
--  in size compressed. Loading very large files (e.g. 100 GB or larger) is not recommended. 
-- If you must load a large file, carefully consider the ON_ERROR copy option value.

-- If enabled, periodic rekeying happens every 12 months.

-- The minimum Snowflake edition that 
-- customers planning on storing protected 
-- information in Snowflake should consider for 
-- regulatory compliance (HIPAA) is "Business Critical".

-- In your system, your Databases must have unique identifiers,
-- you cannot have two databases named "AUDIENCE_LAB", for example.

Q: "A data engineer is running some transformation jobs
using a M virtual warehouse. The virtual warehouse seems
to be suspending between the jobs, making subsequent
jobs take longer. What could be the issue? Choose one correct value."


A: The Virtual Warehouse AUTO_SUSPEND property (seconds) is 
set too low. - If the AUTO_SUSPEND property is
set too low this can cause the virtual warehouse to go into
the suspended state quicker than is desired. This can cause
subsequent jobs to run slower because virtual warehouse will purge
 their cache when suspended.




-- Example Syntax:




-- Creating a warehouse, to run queries:
CREATE OR REPLACE WAREHOUSE example_main with
warehouse_size='X-SMALL'
auto_suspend = 180
auto_resume = true
initially_suspended=true;

-- Warehouse Sizes. For each increase in size, the compute costs per hour (credits) are doubled.

-- XSMALL , 'X-SMALL'  1
-- SMALL    2
-- MEDIUM   4
-- LARGE    8
-- XLARGE , 'X-LARGE'   16
-- XXLARGE , X2LARGE , '2X-LARGE'   32
-- XXXLARGE , X3LARGE , '3X-LARGE'  64
-- X4LARGE , '4X-LARGE'     128

-- Snowflake Credit Cost varies by Region and Provider (AWS, Azure, GCP)

-- Force resume a warehouse. "OPERATE" privileges are needed to run this query.
ALTER WAREHOUSE example_main RESUME;

-- Force suspend a warehouse. "OPERATE" privileges are needed to run this query. Warehouse will only suspend after it has finished running its queries.
ALTER WAREHOUSE example_main SUSPEND;

-- Statements to check what was executed in a warehouse (metadata, ACCOUNTADMIN needed):
SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_LOAD_HISTORY(DATE_RANGE_START=>DATEADD('HOUR',-1,CURRENT_TIMESTAMP())));

SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(DATEADD('SEC',-500,CURRENT_DATE()),CURRENT_DATE()));

SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(CURRENT_DATE()));



-- General Cost Monitoring queries (ACCOUNTADMIN needed):



-- Table storage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

-- How much is queried in databases 
SELECT COUNT(*) FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY;

-- View how many queries and how much credits are associated to each database
SELECT 
    DATABASE_NAME,
    COUNT(*) AS NUMBER_OF_QUERIES,
    SUM(CREDITS_USED_CLOUD_SERVICES)
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
GROUP BY DATABASE_NAME;

-- Usage of credits by warehouses // Grouped by warehouse
SELECT
WAREHOUSE_NAME,
SUM(CREDITS_USED)
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
GROUP BY WAREHOUSE_NAME;

-- Usage of credits by warehouses // Grouped by warehouse & day
SELECT
DATE(START_TIME),
WAREHOUSE_NAME,
SUM(CREDITS_USED)
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
GROUP BY WAREHOUSE_NAME,DATE(START_TIME);





-- Great advantages of Snowflake:

-- 1) Warehouses are always available, and are decoupled from storage

-- 2) Excellent storage of metadata information (we can leverage that metadata to timetravel, build streams, dashboards, and more)





-- Creating Databases, Schemas and Tables - Permanent, Transient and Temporary.

-- Shows the DATA DEFINITION LANGUAGE COMMAND (sql text) that was used to create this specific table
SELECT get_ddl('TABLE','<database.schema.table>');

-- Databases
CREATE OR REPLACE DATABASE DEMO_DB; -- PERMANENT (fail-safe, retention period of 0-90 days. 0 disables it)

CREATE OR REPLACE TRANSIENT DATABASE DEMO_DB; -- TRANSIENT (no fail-safe, max retention of 1 day, can be disabled) -- all objects inside of database will be transient

CREATE OR REPLACE TEMPORARY DATABASE DEMO_DB; -- TEMPORARY (session-only, no fail-safe, no retention) -- all objects inside of database will be temporary

-- Schemas
CREATE OR REPLACE SCHEMA DEMO_DB.SOME_SCHEMA; -- PERMANENT 

CREATE OR REPLACE TRANSIENT SCHEMA DEMO_DB.SOME_SCHEMA; -- TRANSIENT 

CREATE OR REPLACE TEMPORARY SCHEMA DEMO_DB.SOME_SCHEMA; -- TEMPORARY 

-- Tables
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.SOME_TABLE ( -- PERMANENT
    FIELD_A STRING NOT NULL, -- "not null" is the only constraint that is enforced, in Snowflake. All other constraints (even primary/foreign keys) are not enforced, and only kept as metadata
    FIELD_B NUMBER,
    FIELD_C DATE,
    FIELD_D VARIANT,
 --   CONSTRAINT PK_FIELD_A_ID PRIMARY KEY (FIELD_A) -- Does not exist in Snowflake (the only constraint that is enforced is NOT NULL).
); 

CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.SOME_TABLE ( -- TRANSIENT 
    FIELD_A STRING NOT NULL, -- "not null" is the only constraint that is enforced, in Snowflake. All other constraints (even primary/foreign keys) are not enforced, and only kept as metadata
    FIELD_B NUMBER,
    FIELD_C DATE,
    FIELD_D VARIANT
);  

CREATE OR REPLACE TEMPORARY TABLE DEMO_DB.PUBLIC.SOME_TABLE ( -- TEMPORARY
    FIELD_A STRING NOT NULL, -- "not null" is the only constraint that is enforced, in Snowflake. All other constraints (even primary/foreign keys) are not enforced, and only kept as metadata
    FIELD_B NUMBER,
    FIELD_C DATE,
    FIELD_D VARIANT
) 




-- Selecting data from tables. While in development, always use LIMIT clause, to reduce compute usage. Your result set must not exceed 10.000 rows, preferably.
SELECT * FROM SUPPLIER LIMIT 100;




-- MODULE 2 --


-- M2 - Caching and Query Profile Analyzing

-- Snowflake's architecture can be best described 
-- as shared disk.

-- In Query Profile:


-- 1) PROCESSING 

-- 2) LOCAL DISK I/O -- Local Storage Disk Layer -- Virtual Warehouse Machines' Disks. Compute spent to pull data from the select Warehouse's cache.

-- 3) REMOTE DISK I/O  -- Data Storage Layer. Compute spent to pull data from the deepest layer of snowflake.

-- 4) SYNCHRONIZATION 

-- 5) INITIALIZATION

-- 6) PERCENTAGE SCANNED FROM CACHE -- from 0 to 100% -- Cached Result Set Utilization (stored in Cloud Services Layer)





-- When a query is reused (Result set cache), no compute clusters (virtual warehoues) are used, as the result is fetched from the Cloud Services Layer.

-- Scanned Bytes = 0 --> Means that a result set, in the Cloud Services Layer, was used. No compute cost.


-- When a Warehouse is suspended, all Warehouse-internal caching is PURGED 
-- (but the Cloud Services Layer caching is not affected by this purge. CS layer result set cache, on the 
-- other hand, lasts for 24 hours).

-- Warehouse-internal retrieval of data by the usage of result caching is slower than the retrieval of data by usage of Cloud Services Layer result set caching
-- (the retrieval is slower because of processes of data encryption/decryption when transferring the data between the layers)





-- How layers and result set fetching (and caching) work:

-- 

-- RESULT CACHE (cloud services layer)
--     ^
-- LOCAL DISK CACHE (warehouse layer)
--     ^
-- REMOTE DISK (data storage layer, actual databases)

--


-- Manually disable Cloud Services Layer Caching Area (not recommended)
 ALTER SESSION 
 SET USE_CACHED_RESULT=FALSE;

-- Cloud Services Layer Result Set Cache lasts for 24 hours after a given query has been executed.



-- The default auto-suspend time is 600 seconds (10 minutes of inactivity suspends the warehouse).
-- Setting auto-suspend to 0 is not recommended (unless we have a workload of continuous usage) - Costs get huge, specially if we have larger warehouses.
ALTER WAREHOUSE <warehouse_name>
SET AUTO_SUSPEND=600;



-- During development activities, we should raise the auto-suspend period to at least 15 minutes (if warehouse is being heavily used), to maximize usage of warehouse caching.
ALTER WAREHOUSE <warehouse_name>
SET AUTO_SUSPEND=900;


-- If multiple user groups are working on the same set of tables (ex: pixel users and audience lab users are using the "TROVO" table), it may 
-- be a good idea to have both user groups use the same warehouse (maximize utilization of caching, to reduce costs).


-- If a given table is updated, its previous result set (of "SELECT *", for example) will not be used in future queries.


-- It is better to run multiple data altering statements in a single go (in a single transaction), instead of running them one by one, to reduce storage costs (failsafe)
-- and use result set caching to its fullest potential (if we run 5 update statements in a single day, updating a single row each time, the previous result set
-- will always be discarded, even if only a single record was altered/added/removed)





-- MODULE 3 --


-- M3 - Clustering -- 

-- Snowflake partitions files loaded into it automatically, but you can still
-- define custom cluster keys ("automatic_clustering", as it is called).

-- The recommended maximum number of columns (or expressions) defined per custom clustering key,
-- according to Snowflake, is 3 or 4.

-- Clustering is used to eliminate/avoid unrequired micro-partitions 
-- during queries (process called "pruning").

-- Micro-partitions, themselves, are immutable; cannot be modified 
-- once they have been created.

-- Micro-partitions are approximately 16MB in size.

-- The maximum compressed row size in Snowflake is 16MB.

-- The main system function used to retrieve clustering information
-- for a given column/columns is "SYSTEM$CLUSTERING_INFORMATION(<table_identifier>)"

-- Clustering Tips:


-- 1) Clustering is the process of grouping of records inside micro-partitions.

-- 2) Clustering is done automatically by Snowflake, using the order in which the data was inserted as basis.

-- 3) You can override the automatic clustering done by snowflake, by providing custom cluster keys.

-- 4) Clustering enforces a reordering of the rows in your table. This reordering will ALWAYS happen AFTER (gradually) each time data is loaded/updated in your table. 
-- This can be bad for costs in large tables, if you frequently update, as there will be a considerable amount of compute power cost each time there is a need for a reorder,
-- each time there is an update.

-- 5) "Natural Clustering" is determined by the order in which the 
--     data is loaded (and should always be preferred, instead of custom
--     clustering, as it is cheaper).



-- Basic Syntax - Custom Clustering:



-- Create Table with Clustering:
CREATE TABLE EMPLOYEE (TYPE, NAME, COUNTRY, DATE) CLUSTER BY (DATE);


-- Alter already existing table, apply Clustering (will force the reordering of rows, in the table
-- Always be wary of the size of your table, as the compute cost for this reordering can be high):
ALTER TABLE EMPLOYEE CLUSTER BY (DATE);

-- This command is deprecated, as reclustering, nowadays, is done automatically by Snowflake itself.
ALTER TABLE TEST RECLUSTER;





-- In real life scenarios, your tables will have thousands of micro partitions.
-- These partitions will overlap with one another.
-- If there is more overlap, Snowflake has to scan through every one of these partitions (bad thing).
-- The degree of overlap, in Snowflake, is measured by the term "micro-partition depth"...
-- Our objective, to have effective clustering, is to have a high amount of "Constant Micro Partitions" (these are the partitions
-- that have already been clustered, whose micro-partition depth is equal to 1. 1 is the limit, we can't cluster 
-- more than that ).


-- How to check cluster status of a table:
-- "automatic_clustering" --> its value only will be "ON" if we apply custom clustering, by some column, in our table.
SHOW TABLES LIKE '<table_name>';

-- Shows if table is clustered (has cluster keys) or not ('000005 (XX000): Invalid clustering keys or table CUSTOMER_NOCLUSTER is not clustered')
SELECT SYSTEM$CLUSTERING_INFORMATION('<database.schema.table>');

-- Shows clustering keys of your table (if they exist/are applied)
SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_CLUSTERED');


-- {   "cluster_by_keys" : "LINEAR(C_MKTSEGMENT)",  
--  "total_partition_count" : 421,   
--  "total_constant_partition_count" : 0,   
--  "average_overlaps" : 420.0,  
--   "average_depth" : 421.0,  
--    "partition_depth_histogram" : 
--    {     "00000" : 0,     "00001" : 0,     "00002" : 0,     "00003" : 0,     "00004" : 0,     "00005" : 0,     "00006" : 0,     "00007" : 0,     "00008" : 0,     "00009" : 0,     "00010" : 0,     "00011" : 0,     "00012" : 0,     "00013" : 0,     "00014" : 0,     "00015" : 0,     "00016" : 0,     "00512" : 421   },   "clustering_errors" : [ ] }


-- Has two main uses: 1) Shows clustering information of given column in your table. 2) If a clustering key has not been applied on that column, Snowflake runs a simulation
-- of how well that column would perform, if used as a clustering key, without really applying it (but we should be careful, as this simulation is not always accurate).
SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_CLUSTERED','(C_MKTSEGMENT)');

-- Example of a test that shows a bad clustering key idea:
SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_NO_CLUSTER', '(C_MKTSEGMENT, C_CUSTKEY)');

-- {   "cluster_by_keys" : "LINEAR(C_MKTSEGMENT, C_CUSTKEY)", 
--   "notes" : "Clustering key columns contain high cardinality
--    key C_CUSTKEY which might result in expensive re-clustering. 
--    Please refer to 
-- https://docs.snowflake.net/manuals/user-guide/tables-clustering-keys.html 
-- for more information.",   
-- "total_partition_count" : 420,   
-- "total_constant_partition_count" : 0,  
--  "average_overlaps" : 419.0,  
--   "average_depth" : 420.0,   
--   "partition_depth_histogram" : {    
--      "00000" : 0,
--      ...    
--      "00512" : 420   },   "clustering_errors" : [ ] }


-- It is also possible to check/test Clusters applied on multiple columns at once.
SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_NO_CLUSTER', '(C_MKTSEGMENT, C_CUSTKEY)');

-- It is also possible to cluster by PART of a column's value, such as a part of a date (ex: cluster by only the years, and not dates).
ALTER TABLE SAMPLE_DATABASE.PUBLIC.CUSTOMER_NOCLUSTER CLUSTER BY (C_MKTSEGMENT, substring(TO_DATE(date), 2)); -- we get "19" and "20", because of the "19XX" and "20XX" format.



-- Clustering Precautions (all requirements must be met, only then can we consider clustering):


-- 1) Clustering should not be applied to every table in a system.

-- 2) Table must be very large (multiple terabytes, large number of micro-partitions).

-- 3) The queries must be mostly SELECTIVE, and must frequently only read a small
-- percentage of rows (which means a small percentage of micro-partitions).

-- 4) Queries run on the table should frequently SORT the data (ORDER BY clauses).

-- 5) Most queries SELECT and SORT BY on the same few columns.

-- 6) The table must be queried (SELECT) frequently, but UPDATED infrequently.

-- 7) Clustering keys should be columns without high cardinality (avoid using IDs as clustering keys)

-- Before clustering, Snowflake recomemends that we test a representative set of queries on the table, 
-- to have more info about the performance of the query, what can be done, etc. Also use the "cluster test", seen above.




-- In what columns should we apply clustering?

-- 1) Columns frequently used with the "WHERE" clause in our queries.

-- 2) Columns frequently used with JOIN clause (as relational columns) and that do not have a high cardinality (ex: "Department_Id", and we have only 10 departments)

-- 3) The order specified in our clustering is also important, and is considered by Snowflake. 
-- Our columns, in the cluster key, should follow the order:
-- "Less cardinality" (unique values) -> "More cardinality" (unique values). 
-- It should be ordered like this because it is easier to group data by lesser amounts of distinct values.



-- How do we obtain the cardinality of a given column?


-- Run these commands:


-- Get total amount of records in a table (X)
SELECT COUNT(*) FROM <table_name>;

-- Get amount of distinct values for a column, in a table (Y).
SELECT COUNT(DISTINCT <col_name>) FROM <table_name>;

-- Divide Y by X:
SELECT Y/X; ---- example of output: 0.15555555555 (high cardinality, 15%).












-- MODULE 4 -- 


-- M4 - Improve performance without clustering --



-- The "auto-arrange" enforced, "under the hood", by the clustering feature of Snowflake
-- can be done by us, manually; We only need to order our rows by the would-be clustering keys, while our data is being loaded into a table/we are creating a table:
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.CUSTOMER_ORDER_BY_EXAMPLE
AS 
SELECT * fROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER
ORDER BY C_MKTSEGMENT;

-- Checking Clustering Information (we will already have a high constant partition count, for that column. Data will already be arranged, without clustering)
SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_ORDER_BY_EXAMPLE', '(C_MKTSEGMENT)');



-- Even if we DO apply custom clustering in a table, using Column X as a Cluster Key, we should, in the future, always use ORDER BY with that column
--  when loading our data into that table, as that will help save costs with compute 
-- (Snowflake won't have to rearrange the micropartitions, in the backend, automatically).



-- Still, this strategy is not the same as Clustering (won't be as beneficial).
-- Micro partitions in back-end will remain well grouped, yes, but there won't 
-- be a re-grouping of ALL micro-partitions based on every instance of recently loaded data. With this strategy,
-- the old micro-partitions won't be regrouped considering this new data. However, even so, the new data that is loaded into the 
-- table will have a better grouping, by itself, and that will improve your query times.






-- MODULE 5 -- 


-- M5 - Virtual Warehouses and Scaling Policies -- 




-- 1) They are essentially EC2 machines, running in the background.


-- 2) We can assign Warehouses to different users.


-- 3) If individual queries are too slow (complex individual queries), one strategy is to increase the size of our Warehouse.


-- 4) Auto-Scale Mode -- always recommended.

-- 4.1) To use it, we must specify a "minimum cluster count" (default: 1) and "maximum cluster count"...

-- 4.2) We must also be careful with the Auto-Scaling, as it can increase our costs considerably.


-- 5) Maximized Mode -- We enable this mode when we define the same values for "minimum warehouse count" and "maximum warehouse count". In this mode,
-- when the warehouse is started, Snowflake forces the initialization of all clusters, so that maximum resources are always available 
-- while the warehouse is running.

-- 5.1) This option should be used if you always have queries running in parallel, without varying traffic. 

-- 5.2) This mode can be viable, but you must have a lot of thought regarding the compute cost per hour and your bill.




-- Scaling Policy:




-- 1) "How many queries should be queued up, by Snowflake, to have an actual additional cluster started up?"

-- 2) "If no workload is present in it, when should a warehouse be suspended?"

-- 3) The scaling policy options, "Economy" and "Standard", are used for different use-cases/scenarios.

-- 3.1) Standard - The moment a query gets into a queue (a queue is formed), snowflake immediately creates copies of your cluster, to resolve this query.

-- 3.2) Economy -  Snowflake spins up additional clusters only if it estimates there's enough load to keep the clusters busy for at least 6 minutes.

-- 4) Snowflake checks, minute-by-minute, if the load in each warehouse's least loaded cluster
-- could be redistributed to other clusters, without spinning up the cluster again.
-- In each plan, the trigger to suspend a cluster is: 

-- 4.1) Standard - after 2-3 consecutive successful checks .

-- 4.2) Economy - after 5-6 consecutive successful checks. (time until clusters shuts down is longer, to keep cluster running and preserve credits)

-- 5) Essentially, "Economy" saves cost in the case of short spikes, but the user
-- may experience short to moderate queues, and delayed query execution.




-- MODULE 6 --




-- M6 - Performance Tuning --







-- The objective is to retrieve result sets more quickly.

-- In traditional databases (mySQL, PostgreSQL), we:


-- 1) Add indexes and primary keys.

-- 2) Create table partitions 

-- 3) Analyze query execution plan 

-- 4) Remove unecessary full table scans

-- 5) Verify optimal index usage

-- 6) Use hints to Tune Oracle SQL

-- 7) Self-order the table joins.



-- However, in Snowflake, a big part of optimization is done automatically.



-- What we must do is use Snowflake smartly.

-- Everything in Snowflake generates cost; me must not generate costs unecessarily.



-- In Snowflake, there is:


-- 1) No indexes.

-- 2) No primary/foreign key constraints.

-- 3) No constraints, besides "NOT NULL".

-- 4) No need for transaction management, as there is no Buffer Pool.

-- 5) No "out of memory" exceptions.




-- Ways to improve performance, in general:


-- 1) The less columns selected, the better (avoid the "*").

-- 2) If we are developing, we should use the same virtual warehouse, to save costs (usage of cached result sets).

-- 3) If we are running extremely large queries, a good idea is to break up the query in smaller logical units,
-- always trying to store the result of subqueries in transient/temporary tables, to save processing/compute costs.

-- 4) We should apply ORDER BY on our data, by the columns most used with WHERES and JOINS, before loading it 
-- into our tables. If we do so, even if we eventually apply clustering, in the future, the costs to reorder the 
-- table considering the clustering keys won't be as high, as the micropartitions
-- in the table will already be ordered, to some extent.

-- 5) If possible, when needed (too much queries at the same time, but not necessarily 
-- complex queries), always try to increase the max cluster count (multi-cluster warehouse)
-- instead of increasing the warehouse size (ex: from LARGE to XLARGE), as the costs will be much cheaper. This is 
-- also better than creating multiple warehouses (ex: multiple large warehouses) to do the same type of job/workload.

-- 6) If we are updating our data, it is always better to run the UPDATES on our staging tables (incremental data, 
--    smaller record collection), as the processing costs and time will be reduced, when compared to updating that data/
--    records in the main/production Table (where there's a huge data set, and time/processing will be high, to update only a few 
--    records, out of millions of records).

-- 7) If we are to use WHERE filters in complex queries, we should always use them 
--    as EARLY as possible, to improve pruning for subsequent processing steps such as "GROUP BY"


-- Snowflake treats transactions differently, but still satisfies the 4 A.C.I.D principles.




-- In Snowflake, update operations are a combination between DELETE and INSERT operations.






-- About update statements, ALWAYS BE CAREFUL. Two rules:



-- 1) Before running an update statement, check how many records are in your table, and how 
-- many of them would be impacted by the change. If 80% of the records would be impacted by the change,
-- you could/should consider recreating the entire table, with the correct data (because the total cost will probably 
-- be less than the UPDATE of all those records); alternatively, you could first DELETE all rows (truncate), to then 
-- INSERT the records with the correct/updated data (this also will be cheaper).

-- 2) When you are trying to DELETE or UPDATE rows in your tables, always try to use numeric columns as identifiers/
-- WHERE filters, because Snowflake's scanning mechanism is better suited/optimized for numbers (strings are a bad choice, 
-- for these operations).





-- To view queries blocked by other queries:
SHOW LOCKS;

-- Abort a transaction/statement (all statements, by themselves, are transactions).
SELECT SYSTEM$ABORT_TRANSACTION(<your_transaction_id>)

-- Cancel a query. mid-execution.
SELECT SYSTEM$CANCEL_QUERY(<your_query_id>)

-- Show open transactions with SESSION ID AND USER.
SHOW transactions IN account;

-- Kill all queries for the session.
SELECT SYSTEM$CANCEL_ALL_QUERIES(<your_session_id>);

--Aborts a session in our system.
SELECT SYSTEM$ABORT_SESSION(<your_session_id>)

-- How long can queries stay queried up (waiting for another query)?
SHOW PARAMETERS; -- "LOCK_TIMEOUT" -> is the amount of time allowed(1 hour and 10 minutes, basically).









-- MODULE 7 -- 



-- M7 - Snowsight (Graphical User Interface) and Dashboards



-- Some of your compute cost will always be associated to idle time. 
-- We should view that idle time in a dashboard, to optimize our Snowflake usage.



-- Metadata tables will be used to build the dashboard. The metadata tables used are:


-- 1) WAREHOUSE_METERING_HISTORY (view) 

-- 2) QUERY_HISTORY (view)

-- 3) WAREHOUSE_EVENTS_HISTORY (view) --> provides info about "when warehouse was suspended, when warehouse was started" (we can calculate idle time upon that).






-- This query can only be run with the "ACCOUNTADMIN" role. - We can use this query to view the amount of credits consumed
-- (and if we multiply by 2, 3, 4, we can get the amount of dollars spent, instead of credits).
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY;

-- Returns a lot of metadata info about our queries. 
-- "Bytes_spilled_to_local_storage" and "bytes_spilled_to_remote_storage" --> if these values are high, the query is very performance-intensive.
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY;

-- With this query, we can check when our warehouse was resumed, and when it was suspended. 
-- We can calculate the idle time, and check if our warehouses are being used appropriately.
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_EVENTS_HISTORY
ORDER BY TIMESTAMP ASC;




-- For dashboard panel creation codes (in your worksheets), check Module 10 - Snowsight and Warehouse Dashboard.



-- In our worksheets, we can use "DYNAMIC FILTERS", accessed by the syntax ":filter_name". We can also create Custom filters, using the GUI.


-- To create and use a Dynamic Filter in the code of one of our worksheets, we must:

-- 1) Click in the small lines icon, in the upper-left corner of the worksheet editor page.

-- 2) Type the filter name and identifier ("example_filter" and ":example_filter", or "my_warehouse" and ":my_warehouse")

-- 3) Choose the warehouse that will run this filter.

-- 4) Click "Write query" 

-- 5) In this modal, you need to write a SELECT query that will retrieve the values that will be selectable, in the future,
-- with this filter, in the upper-left corner.

-- 5.1) Example: we want to have an option to select a warehouse, using our custom filter. For that, we need all the different warehouses of 
-- our system in a result set, so we write this: "SELECT DISTINCT warehouse_name FROM snowflake.account_usage.warehouse_metering_history;"

-- 5.2) With a list of possible values provided, by the running of this query, we have a checkbox that lets us choose between single 
-- values and "multiple values can be selected"

-- 6) Finally, with this dynamic filter created, we can apply it on any of our worksheets, if we use the syntax ":filter_name" (ex: "my_warehouse")

-- 6.1) Example of syntax usage:

SELECT SUM(COST) COST
FROM OVERVIEW
WHERE CRITERIA='SNOWFLAKE_WAREHOUSE_COST'
AND WAREHOUSE_NAME=:my_warehouse; -- custom filter (created by us) example.
  -- AND WAREHOUSE_NAME='COMPUTE_WH'; -- Example of possible value, inserted in the dynamic filter placeholder, by the Snowflake GUI.

-- 7) This feature of Dynamic Filters can also be used in our dashboards, to "filter by warehouse", or "filter by date", and other custom filters.





-- To create dashboards, we need to create them first, and then add our worksheets, as panels, to them.


-- Some quirks/tips:


-- 1) Once a worksheet is converted into a panel, it can't be reverted into a worksheet, so save your queries, beforehand, in other places.

-- 2) You should have a single query/statement per worksheet.

-- 3) The worksheets' names are always used as panel names, so name your worksheets accordingly.

-- 4) Each time we open our dashboard, the queries of the panels will be reexecuted (and will query the metadata tables).






-- How to read and analyze some of the dashboards' data:


-- 0) Remember, we can check utilization of warehouses by days/periods; for that, we must use the dynamic filters.

-- 1) "GB Written" --> if this number is greater than "GB written to result", this means our warehouse is being 
-- used mainly to load data into tables.

-- 2) "GB Written to result" --> if this number is greater than "GB Written", this means our warehouse is 
-- being used mainly to retrieve result sets with SELECT (select queries, Tableau, Snowflake web console).

-- 3) "GB Scanned" --> This number is usually accompanied by "GB Written to result" (SELECT queries). If this number 
-- is high and we have no "GB Written to result" (0 as a value), this means that some query was aborted whilst running (
-- bytes were scanned, but no result was retrieved; even if no result was retrieved, we'll have been charged by Snowflake all the same, for
-- the compute power).

-- 4) Warehouse classification:
-- 3.1) Very Active === Warehouses that are idle 25% of the time or less.
-- 3.2) Active === Warehouses that are between 25% and 75% of the time idle.
-- 3.3) Dormant === Warehouses that are 75% or more of the time idle.

-- 5) You should be wary of each type of data use, and its values. If the values are too high, it may indicate a serious problem with your queries:

    -- 5.1) "GB Written" too high - This means that a lot of data is being inserted/updated on Snowflake. You should think about costs with storage,
    -- both active bytes, time travel bytes and failsafe bytes, which can generate a very high combined cost. You must ensure that this is really business 
    -- critical data, and not junk data.

    -- 5.2) "GB Written to result" too high - This means that your queries are probably written incorrectly, and are retrieving/writing data to the Snowflake 
    -- Web Console (which is a very bad thing, because the console/GUI can only show up to 1.5 million records per query; the rest of the records is not 
    -- shown/outputted). Consider running aggregations (like SUM() or COUNT()) to produce your results, as that won't envolve the write of unecessary 
    -- data in the Snowflake Web Console. Your result set must not exceed 10.000 rows, preferably.

    -- 5.3) "GB Scanned" too high - This may indicate that you wrote inefficient queries, that they are pulling almost all of the records in the table,
    -- or scanning almost all partitions.

-- 6) "GB_SPILLED_TO_LOCAL_STORAGE" too high, in a query - This means that your query is too demanding, works with too much data, and the current 
-- warehouse is not able to support/execute your queries satisfactorily. You should use a larger warehouse, or process your data in smaller batches.

https://github.com/dbt-labs/docs.getdbt.com/discussions/1550

"One of the biggest killers of performance in Snowflake is queries spilling to either local or remote storage.
This happens when your query processes more data than your virtual warehouse can hold in memory,
and is directly related to the size of your warehouse."


-- Possible Solutions:

-- A) Throw resources at it, and hope it goes away. This will cost you money, but can be a
-- quick fix if you need a solution ASAP. The amount of memory that Snowflake has available
-- for a given query is governed by warehouse size, so if you up the warehouse, you up your
-- memory.


-- B) Process your data in smaller chunks. By limiting the amount of data that a query
-- processes you can potentially prevent spilling anything to local/remote storage.


-- C) Watch out for big CTEs. (WITH clauses in our SELECTs) If you're processing a ton of data
-- in multiple CTEs in the same query, there's a good chance you'll hit this problem. 
-- Since CTEs process their results in memory, it hogs that resource for the query. 
-- Try converting your largest CTEs into views and see if that solves the problem.



-- 7) "GB SPILLED TO REMOTE STORAGE" too high, in a query - Same thing as Point 6, your query is probably too demanding. The assigned compute 
-- may not be enough.




-- MODULE 8 --




-- M8 - Query Acceleration Service (QAS)






-- How to enable (SQL code):

CREATE WAREHOUSE <warehouse_name>
ENABLE_QUERY_ACCELERATION = TRUE
QUERY_ACCELERATION_MAX_SCALE_FACTOR = <num>;

ALTER WAREHOUSE <warehouse_name>
SET ENABLE_QUERY_ACCELERATION = TRUE
QUERY_ACCELERATION_MAX_SCALE_FACTOR = <num>; -- multiplier


"It can accelerate parts of the query workload in a warehouse. When it is enabled for a warehouse,
it can improve overall warehouse performance by reducing the impact of outlier queries, which are queries 
that use more resources than the typical query. The query acceleration service does this by offloading 
portions of the query processing work to shared compute resources that are provided by the service.
It can handle workloads more efficiently by performing more work in parallel and reducing the Walltime
spent in scanning and filtering".




-- The usage of QAS can be cheaper than increasing the size of your warehouse, but it can still be expensive (or even more expensive,
-- if used incorrectly).



-- This service indirectly improves the speed of our read operations.


-- It is best used to improve execution times of queries that spend a lot of time/processing with "REMOTE DISK I/O" (extracting data out of 
-- the deepest layer of Snowflake, in the AWS S3 Blob storage).



-- One of QAS' advantages is its flexibility, which is greater than the increase/decrease of a warehouse's size.


-- Its flexibility is provided by the "Scale Factor", 
-- a COST CONTROL mechanism that allows you to set an upper bound 
-- on the amount of compute resources a warehouse can LEASE 
-- (Snowflake borrows us machines, for the sole 
-- purpose of increasing query speed) for query 
-- acceleration. This value is used as a MULTIPLIER 
-- based on WAREHOUSE SIZE and COST.



-- Example: scale factor of 5 for a MEDIUM-sized warehouse --> this means that this warehouse can borrow 
-- resources up to 5 times its size. (and 5 times the cost, totalling up to 20 credits per hour, 4 x 5).



-- This means that QAS is essentially a multiplier, based on the currently selected warehouse size.

-- It should be used when query takes more time with "Remote Disk I/O", with the extraction of data from the storage layer (table scan).


-- Before we utilize/apply the service, we should check if our queries are ELIGIBLE for its use, with this code (ACCOUNTADMIN role needed):
-- Also, the query must have been executed before, so we can get its query_id string.
SELECT PARSE_JSON(system$estimate_query_acceleration('<query_id>'));


-- The outputted JSON's format:

-- {"originalQueryTime": 252
-- "eligible": true,
-- "upperLimitScaleFactor": 1
-- }

-- Check more queries, see if they are eligible for Query Acceleration Service.
-- If a lot of queries are eligible, and if the calculated costs are sensible, we can consider it.
SELECT * FROM snowflake.account_usage.query_acceleration_eligible
ORDER BY eligible_query_acceleration_time DESC;





-- However, the Query Acceleration Service brings with it two important caveats:

-- 1) Only fetching (SELECT) and filtering operations are affected by the acceleration (UPDATEs and DELETEs don't get impacted).
-- The best-use case for it is queries that spend 75%-80% of the time in full table scans.


-- 2) When using QAS, queries will no longer be able to benefit from Warehouse Caching (because the machines used by/with QAS 
-- will be borrowed machines, different from the machines of your warehouse's cluster)








-- MODULE 9 -- 





-- M9 - Search Optimization Service (SOS) --



-- This service is frequently used for queries that execute 
-- "selective point lookups", such as these ones:

SELECT
NAME, ADDRESS FROM EMPLOYEES 
WHERE EMP_ID IN ('12867', '0987SS');

SELECT NAME, ADDRESS FROM EMPLOYEES WHERE 
EMP_EMAIL='support.help@corp.com';




-- How to enable (SQL code):


ALTER TABLE <table_name> ADD SEARCH OPTIMIZATION ON <col_name>;





"Essentially, this service's objective is to find needles (few records) in haystacks (huge tables)".


"The search optimization service can significantly improve the 
performance of certain types of lookup and analytical queries that 
use an extensive set of predicates for filtering."

"Selective point lookup queries on tables.
A point lookup query returns only one 
or  a small number of distinct rows."

"Once you identiy the queries that can benefit from the 
search optimization service, you can configure 
search optimization for the columns and tables 
used in those queries."


-- Used in scenarios in which:

-- 1) You have a huge table (50gb, 150gb, 250gb+ ), and you frequently return only a few records from it. (50 records out of 20 million, for example)

-- 1.1) "Few records" --> try to retrieve at most 1k records; the SOS is not recommended for the retrieval of result sets greater than that count.

-- 2) You are frequently running intensive analytical queries, with a lot of WHERE conditions in 
-- a single query (because the more WHERE conditions you have, the less records you retrieve).

-- 3) Too slow individual queries.

-- 4) You don't want to spend costs in a bigger warehouse.

-- 5) Your queries are not eligible for QAS (Query Acceleration Service)

-- 6) Clustering is not viable, and loading data while ordering (ORDER BY) it is not good enough.


-- Example code:


-- Create table with 6 billion rows.
CREATE TABLE DEMO_DB.PUBLIC.LINEITEM_SOS
AS
SELECT * FROM
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.LINEITEM;

-- Clone original table's structure and data (zero-copy-clone)
CREATE TABLE DEMO_DB.PUBLIC.LINEITEM_NO_SOS CLONE DEMO_DB.PUBLIC.LINEITEM_SOS;

-- Add search optimization on certain columns - this creates/uses extra storage, so be careful (185gb table gets 30gb extra storage, for these 2 columns with SOS).
ALTER TABLE DEMO_DB.PUBLIC.LINEITEM_SOS ADD SEARCH OPTIMIZATION ON EQUALITY(L_COMMENT);
ALTER TABLE DEMO_DB.PUBLIC.LINEITEM_SOS ADD SEARCH OPTIMIZATION ON EQUALITY(L_ORDERKEY);
ALTER TABLE DEMO_DB.PUBLIC.LINEITEM_SOS ADD SEARCH OPTIMIZATION ON SUBSTRING(HEM_ARRAY);

-- Column "search_optimization" (ON/OFF). Also "search_optimization_bytes", which shows how much storage bytes (additional storage) is being spent with SOS.
SHOW TABLES;

-- Shows the difference between search optimization enabled and disabled:
SELECT * FROM DEMO_DB.PUBLIC.LINEITEM_SOS WHERE L_ORDERKEY = '4509487233';  -- Takes 6 seconds, roughly. - 3 partitions scanned.
select * from DEMO_DB.PUBLIC.LINEITEM_NO_SOS where L_orderkey = '4509487233'; -- Takes 43 seconds, roughly. - 9 thousand partitions scanned



-- Essentially, Snowflake creates additional "lookup tables" (additional storage costs) to help improve your query speed.
-- These additional "lookup tables" function similarly to regular index tables in conventional database systems (but not identically, as these lookup 
-- tables do not have UNIQUEness and NOT NULL constraints, as index tables do).

-- These lookup tables are materialized views, created using the selected columns as a basis, and have a storage cost associated to them.








-- RECAP of query optimization options, so far: --

-- 1) Clustering - The grouping of micropartitions according to the most used filters

-- 2) Query Acceleration Service (QAS) - Used to reduce query times on huge tables, huge amounts of data retrieved. "Borrows" additional machines to read data faster.

-- 3) Search Optimization Service (SOS) - The creation of an index-like additional table (materialized view), 
-- which helps lookup few rows (many WHERE filters) in huge tables.












-- MODULE 10 -- 



-- M10 - Load data - Intro 




-- To work with Snowflake in our terminal, we need:

-- 1) Snow CLI 

-- 2) AWS CLI 




-- To connect to our snowflake account/app, we must run, in the terminal:
snowsql -a <account-identifier> -u <username_in_the_account>  -- "account-identifier" is something like <string>.us-east-2.aws

-- Account Identifiers are values like:

xy12345.us-east-2.aws 
(values composed of "account locator", 
"account region" 
and "account cloud platform")



-- When we connect with SnowSQL CLI,
-- we assume the role which our account/user
-- has.








-- MODULE 11 -- 


-- M11 - COPY preparations (auxiliary objects)

-- Before loading data into our tables, we must create the auxiliary objects that will be used with the COPY command.
-- As a best practice, we should create a dedicated database, where all these objects will be stored, a central place.
-- This will greatly help us in the future, when we need to referenec them in our COPY commands:


-- Create a dedicated database for our Snowflake Objects (we don't need the failsafe feature, so we create it as transient)
CREATE TRANSIENT DATABASE CONTROL_DB;

-- Create Schemas for each of the Snowflake Object types
CREATE SCHEMA CONTROL_DB.INTERNAL_STAGES;
CREATE SCHEMA CONTROL_DB.EXTERNAL_STAGES;
CREATE SCHEMA CONTROL_DB.INTEGRATION_OBJECTS; -- Storage integration objects
CREATE SCHEMA CONTROL_DB.FILE_FORMATS;
CREATE SCHEMA CONTROL_DB.MASKING_POLICIES;
CREATE SCHEMA CONTROL_DB.PIPES;
CREATE SCHEMA CONTROL_DB.TASKS;
CREATE SCHEMA CONTROL_DB.STREAMS;
CREATE SCHEMA CONTROL_DB.TAGS;





-- Load data - First Object Type - Stages 



-- Stages are Snowflake objects that represent Blob Storage Areas (like S3),
-- places where you load/upload all your raw files, before loading them into Snowflake tables.


-- Stages contain properties like "location", which is the place where your files will be coming from.


 Q: As a data engineer, I want to create a file URL that is only valid for 24 hours.
 Which file function would I use?

 A: BUILD_SCOPED_FILE_URL -- this outputs an encoded URL granting access to a file for 24
 hours, to the user that requested it.



-- There are 2 types of Stages:



-- 1) Internal Stages (staging areas managed by Snowflake itself)

    -- 1.A) Table Staging Areas - Symbols are "@%"

    -- 2.B) Named Staging Areas - Symbol is "@"

    -- 3.C) User Staging Areas (rarely used) - Symbols are "@~"

-- 2) External Stages (staging areas managed by third parties, such as S3, GCP, Azure.) - Symbol is "@"







-- Unlike Internal Stages, External Stages must be prepared before being used. This preparation involves the creation of a Integration Object,
-- which is responsible for making the connection between Snowflake and S3, GCP, Azure, secure.

-- One best practice is the usage of file format objects, which avoid repetition of code in your COPY commands.

-- The most used Stages (from most used to least used) are External Stages, Named Stages and Table Stages.




-- A) Table Stages (least used):


-- Each table has a snowflake stage allocated 
-- to it, by default, for storing files. This stage 
-- is a convenient option if your files need to be 
-- accessible to multiple  users and only need 
-- to be copied into a single table.


-- This type of Stage is automatically created and assigned to each corresponding table.


-- They should be used when:

-- 1) We have multiple users in our account.

-- 2) We have multiple files in this stage.

-- 3) All the data in the stage will be copied only to this single table, no COPYs to other tables.




-- Some unique traits of Table Stages:

-- 1) Unlike Named and External Stages, they cannot be dropped, as they are part of the table objects.

-- 2) Unlike Named and External Stages, we cannot use File Format objects with them; if you want a 
-- specific FILE_FORMAT, you must write it inline, like this:

COPY INTO xxx 
FROM @yyy
FILE_FORMAT=(
    SKIP_HEADER=1,
    TYPE=CSV
);

-- 3) They do not support data transformations while loading data into your tables.





-- B) Named Stages 


-- Named stages are database objects that provide 
-- the greatest degree of flexibility for data loading.
-- Because they are database objects, the security/access 
-- rules that apply to all objects also are applied 
-- to this type of object.

-- This type of object also cannot be cloned.





-- The great advantages of this Stage type are:


-- 1) They can be used to load data into any of your tables.

-- 2) As they behave like regular snowflake objects, we can grant/revoke access, to them, to our various account roles (better access control).

-- 3) A common best practice is the creation of folders insided of this stage, so we can atribute each folder to a table, inside our Snowflake system.


-- Basic Stage Creation Syntax:



-- Create Internal, Named Stage
CREATE OR REPLACE STAGE CONTROL_DB.INTERNAL_STAGES.MY_INT_STAGE;

-- Create External Stage - insecure (no Integration Object)
CREATE OR REPLACE STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE 
    url='s3://snowflake867/test/';

-- Create External Stage - secure (with Integration and File Format Objects)
CREATE OR REPLACE STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE 
    url='s3://snowflake867/test/'
    STORAGE_INTEGRATION=<integration_name> -- Integration Object needed
    FILE_FORMAT=(
        FORMAT_NAME=<format_name> -- File Format Object needed
    );

-- Alter Stage Object
ALTER STAGE CONTROL_DB.INTERNAL_STAGES.MY_INT_STAGE
    SET FILE_FORMAT=(
        TRIM_SPACE=TRUE
    )
    COPY_OPTIONS=(PURGE=TRUE); -- with "PURGE=TRUE", the files in our stage will be DELETED after a successful COPY operation.

-- Drop Stages
DROP STAGE CONTROL_DB.INTERNAL_STAGES.MY_INT_STAGE;
DROP STAGE CONTROL_DB.INTERNAL_STAGES.MY_EXT_STAGE;

-- Describe Stages' properties (location, database, schema, name, etc)
DESC STAGE CONTROL_DB.INTERNAL_STAGE.MY_INT_STAGE; -- "location" will be empty (as we are inside of snowflake)
DESC STAGE CONTROL_DB.INTERNAL_STAGE.MY_EXT_STAGE; -- "location" will be your bucket's url.

-- List files inside of stage
LIST @CONTROL_DB.INTERNAL_STAGE.MY_INT_STAGE;
LIST @CONTROL_DB.INTERNAL_STAGE.MY_EXT_STAGE;

-- Show all Stages 
SHOW STAGES;




-- Load data - Second Object Type - File Formats


-- A File Format, named (object) or not, always needs 
-- to be specified in your COPY command.

-- The greatest advantage of the File Format objects is 
-- that it does not matter how many COPY commands you have,
-- if you change the File Format that is registered to all of them,
-- the changes's effects will be applied to all of the commands as well.

-- The most common properties used with CSV File Formats are 
-- RECORD_DELIMITER, SKIP_HEADER and FIELD_DELIMITER.

-- Some properties are only supported by some File Format types,
-- like "STRIP_OUTER_ARRAY" AND "STRIP_NULL_VALUES", which are only 
-- supported by File Formats of type JSON.


-- Basic File Format Creation Syntax:




-- Create CSV File Format
 CREATE OR REPLACE FILE FORMAT CONTROL_DB.FILE_FORMATS.CSV_FORMAT
    TYPE=CSV,
    FIELD_DELIMITER=',',
    SKIP_HEADER=1,
    NULL_IF=('NULL', 'null', '\\N')
 -- EMPTY_FIELD_AS_NULL=true
 -- FIELD_OPTIONALLY_ENCLOSED_BY='"'
 -- ERROR_ON_COLUMN_COUNT_MISMATCH=TRUE
 -- TRIM_SPACE = FALSE
 -- ESCAPE = 'NONE' 
--  ESCAPE_UNENCLOSED_FIELD = '\134'
--  DATE_FORMAT = 'AUTO' 
--  TIMESTAMP_FORMAT = 'AUTO' 
    COMPRESSION=gzip; -- for files in ".csv.gzip" format


-- Alter File Format - Example 1
ALTER FILE FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT
    SET TYPE='JSON',
    ERROR_ON_COLUMN_COUNT_MISMATCH=FALSE;

-- Alter File Format - Example 2
ALTER FILE FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT
    SET TYPE='PARQUET',
    SNAPPY_COMPRESSION=TRUE;

-- Alter File Format - Example 3
ALTER FILE FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT
    SET TYPE='XML';

-- Alter File Format - Example 4
ALTER FILE FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT
    SET TYPE='AVRO';

-- Describe File Format Object's properties - many of them are also present in stage object, but we should always try to define properties'
-- values in the File Format objects, and not stages (best practice - you should try not to write file_format argument inline, in copy command)
DESC FILE FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT;

-- Show all File Formats 
SHOW FILE FORMATS;






-- Load data - Third Object Type - Integration Object


-- These are always needed for external stages, to have a secure connection between AWS and S3.



-- Basic Integration Object Creation Syntax:



-- Create Integration Object
CREATE OR REPLACE STORAGE INTEGRATION PIXEL_RESOLUTION_INTEGRATION
    TYPE=EXTERNAL_STAGE
    STORAGE_PROVIDER=S3
    ENABLED=TRUE
    STORAGE_AWS_ROLE_ARN='arn:aws:iam::*******************:role/snowflake' -- a "snowflake" dedicated IAM user is needed, in AWS, to utilize this value
    STORAGE_ALLOWED_LOCATIONS=('<bucket-url>'); -- create bucket beforehand

-- Alter Integration Object 
ALTER STORAGE INTEGRATION S3_<integration_name>
SET STORAGE_ALLOWED_LOCATIONS=(
    's3://bucket-url/folder-1/',
    's3://bucket-url/folder-2/',
    's3://bucket-url/folder-3/'
);

-- Describe Integration Object (mandatory, as we need the STORAGE_AWS_EXTERNAL_ID and
-- STORAGE_AWS_ROLE_ARN; we'll use this ID and this role in the AWS config, in IAM users/buckets, in "Trusted Relationships")
DESC STORAGE INTEGRATION <integration_name>;

-- Show all Storage Integrations
SHOW STORAGE INTEGRATIONS;

-- Integration Object fields:
property	                    property_type	property_value	            property_default
ENABLED	                        Boolean	            true	                    false
STORAGE_PROVIDER	            String	            S3	
STORAGE_ALLOWED_LOCATIONS	    List	s3://new-snowflake-course-bucket/CSV/	[]
STORAGE_BLOCKED_LOCATIONS	    List		        []
STORAGE_AWS_IAM_USER_ARN	    String	arn:aws:iam::543875725500:user/heeb0000-s	
STORAGE_AWS_ROLE_ARN	        String	arn:aws:iam::269021562924:role/new-snowflake-access	
STORAGE_AWS_EXTERNAL_ID	        String	   UU18264_SFCRole=2_TBE7RjHPfSqmCjne1y5exkh5IDQ=	
COMMENT	                        String		

-- In AWS, create IAM user and Role, policy "s3FullAccess", and edit the permmissions' JSON:
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::269021562924:role/new-snowflake-access"
			},
			"Action": "sts:AssumeRole",
			"Condition": {
				"StringEquals": {
					"sts:ExternalId": "UU18264_SFCRole=2_TBE7RjHPfSqmCjne1y5exkh5IDQ="
				}
			}
		}
	]
}

-- Finally, after setting up AWS and Snowflake with this 
-- Storage Integration Object, create a secure Stage Object and validate/check if connection between two systems is valid

-- Create Stage Object
CREATE OR REPLACE STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE 
    url='s3://snowflake867/test/'
    STORAGE_INTEGRATION=<integration_name> -- our Integration Object
    FILE_FORMAT=(
        FORMAT_NAME=<format_name>
    );

-- Check Connection Between Systems
LIST @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE; -- will show the files in our bucket.








-- Uploading files manually (via GUI and via Snow CLI):



-- Using the Snowflake Web Console GUI, we can upload files, from our local machines,
-- directly into our Snowflake tables; this practice is only recommended if you have up to 10k records.
-- If we have more than that, the Snow CLI and its commands must be used.



-- Example of Snow CLI usage, to upload files:


-- Create Table (and, consequently, Table Stage)
CREATE TABLE DEMO_DB.PUBLIC.EMP_BASIC (
    FIELD_1 STRING,
    FIELD_2 NUMBER,
    FIELD_3 DATE
);

-- Upload file (.csv) from local storage to Snowflake Internal Stage (Table Stage), blob storage, using Snow CLI
 PUT FILE:///root/Snowflake/Data/Employee/employees0*.csv -- local filesystem path
 @DEMO_DB.PUBLIC.%EMP_BASIC; -- stage

-- List files, now present in Table Stage's blob storage area
LIST @DEMO_DB.PUBLIC.%EMP_BASIC; -- in worksheets
ls @DEMO_DB.PUBLIC.%EMP_BASIC; -- in Snow CLI

-- Remove/delete files, present in Table Stage's blob storage area (to save storage costs), after their data has been copied to your tables
REMOVE @DEMO_DB.PUBLIC.%EMP_BASIC; -- in worksheets 
rm @DEMO_DB.PUBLIC.%EMP_BASIC; -- in Snow CLI

-- Select rows in EMP_BASIC Table (the result set will be empty, just like the table, as the files will still only exist in the Table Stage's blob storage)
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC LIMIT 100;





-- Example of Snow CLI usage, to download files (from Table and Named stages):


-- Download file (.csv) from Table Stage to local storage
GET @DEMO_DB.PUBLIC.%EMP_BASIC
file:///path/to/your/local/file/storage/that/will/receive/the/file;




-- Before summarizing the Copy command and its features,
-- it is good to review the use-case in which we do not 
-- copy the data into Snowflake tables, but we use Snowflake
-- to query the data from files, stored in External Stages (S3).
-- With this approach, a lot of Snowflake's features are wasted.
-- Some of these features are caching, the storing of metadata and 
-- micropartitions. This approach should be used only if our data 
-- in S3 is rarely queried (can be advantageous in cases where 
-- you want to avoid the data storage costs in both Snowflake and S3).
-- Also, if this approach is used, the "Query Profile" option will have 
-- very few details about the query.




-- Example of querying data from an External Stage directly, without copying into a table
SELECT 
T.$1 AS first_name,
T.$2 AS last_name,
T.$3 AS email
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_EXTERNAL_STAGE AS T;

-- Querying while filtering
SELECT
T.$1 AS first_name,
T.$2 AS last_name,
T.$3 AS email 
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_EXTERNAL_STAGE AS T
WHERE T.$1 IN ('Di', 'Carson', 'Dana');

-- Querying while joining
SELECT 
T.$1 AS first_name,
T.$2 AS last_name,
T.$3 AS email
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_EXTERNAL_STAGE AS T
INNER JOIN @CONTROL_DB.EXTERNAL_STAGES.S3_EXTERNAL_STAGE AS D
ON T.$1=D.$1;

-- You can also create views - when new files are added to your bucket, the view will "refresh" automatically (because it only saves the logic of the query, not the results)
CREATE OR REPLACE VIEW DEMO_DB.PUBLIC.QUERY_FROM_S3 
AS 
SELECT
T.$1 AS first_name,
T.$2 AS last_name,
T.$3 AS email 
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_EXTERNAL_STAGE AS T;

-- You can also create a table from the bucket's files - However, when new files are eventually added to your bucket, this table won't be refreshed.
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.QUERY_FROM_S3_TABLE
AS 
SELECT
T.$1 AS first_name,
T.$2 AS last_name,
T.$3 AS email
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_EXTERNAL_STAGE AS T;












-- The Copy Command


-- One quirk of the copy command, very important to know, is that 
-- Snowflake stores the md5 hash values of each of the files loaded into your tables.
-- If you are trying to load the same file repeatedly, Snowflake will stop you: it will 
-- compare the md5 value of the to-be-loaded file and the md5 value of the file you already
-- loaded, find out they are equal, and then will stop the load proccess. This is done to 
-- avoid the creation of duplicate rows in our tables. To bypass this behavior, if needed, 
-- we must set the option "FORCE=TRUE" in our COPY commands.

-- Before copying a file into one of your tables, create a sample of your file (10-100 rows), and test 
-- the copy command with it (for that purpose, Named Stages/Table Stages can be used, along with 
-- the Snow CLI and "put" command).

-- Always use a dedicated warehouse (size Large is good enough, for most cases)
-- to load/unload your data, as the process must not be stopped once it is started.

-- The default compression format used by Snowflake, when unloading files
-- from the staging areas into your local machine, is GZIP.

-- Before copying your files, if they are huge (multiple GB), always split them into smaller
-- chunks, first. If you copy a lot of 10mb files, the copy speed will be much faster than 
-- with a 10gb file.

-- .gzip files are supported in copy commands, but .zip files aren't. (must be unzipped, first).



-- Copying into Snowflake tables from S3 External Stage, examples:



-- Copying from AWS External Stage, most basic format:
COPY INTO <table_name> -- create table beforehand (with appropriate columns and data types for each column)
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_STAGE -- create stage beforehand
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT -- create file format beforehand
);


-- Copying from AWS External Stage, forcing the repeated copy procedure of a file:
COPY INTO <table_name>
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_STAGE
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
)
FORCE=TRUE;


-- Copying from AWS External Stage, CSV file, only some of the columns of files:
COPY INTO <table_name>
FROM (
    SELECT
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6
        FROM @CONTROL_DB.EXTERNAL_STAGES.S3_STAGE  AS t ) 
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);


-- Copying from AWS External Stage, CSV file, metadata (filename and file_row_number, to assist in migrations;
-- with these values, we know exactly from which .csv file our rows were extracted) and some of the file's columns:
COPY INTO <table_name>
FROM (
    SELECT
        METADATA$FILENAME AS FILE_NAME,
        METADATA$FILE_ROW_NUMBER,
        t.$1,
        t.$2,
        t.$3
        FROM @CONTROL_DB.EXTERNAL_STAGES.S3_STAGE  AS t ) 
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);


-- The same as the code seen above, but better - FILE_NAME column's values are cleaner. 
-- ("@employees03.csv.gz" format, instead of "@emp_basic_local/employees03.csv.gz")
COPY INTO <table_name>
FROM (
SELECT 
SPLIT_PART(METADATA$FILENAME, '/', 2) AS FILE_NAME,
METADATA$FILE_ROW_NUMBER,
T.$1,
T.$2,
T.$3
FROM @CONTROL_DB.EXTERNAL_STAGES.S3_STAGE  AS t 
)
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);


-- After data was copied from AWS into Snowflake table, we can validate/check if all rows were loaded, with this simple SQL statement:
SELECT 
DISTINCT FILE_NAME AS FILE_NAME,
COUNT (*) AS AMOUNT_OF_ROWS
FROM <table_name> -- staging table, filled by the above statement
GROUP BY FILE_NAME;







-- Copying from Snowflake Internal Stages (Table and Named Stages) into Snowflake Tables, examples:





-- Copy data into Snowflake table, from Internal (Table) staging area
COPY INTO DEMO_DB.PUBLIC.EMP_BASIC
FROM @DEMO_DB.PUBLIC.%EMP_BASIC
FILE_FORMAT= (
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT;
);

-- Situational command, lets us view how our rows are being formatted, in the files present in our table staging area.
SELECT
    $1,
    $2,
    $3,
    $4,
    $5,
    $6
    FROM @DEMO_DB.PUBLIC.%EMP_BASIC
    (
        FILE_FORMAT => CONTROL_DB.FILE_FORMATS.CSV_FORMAT; -- to view the data correctly, we need to write the file format in, in this manner.
    )
    LIMIT 100;

-- After loading the data, with this command, we can compare the loaded data with the data in the table staging area;
-- if no rows are returned, the data was copied perfectly, and the two sets are identical.
SELECT
$1,
$2,
$3,
$4,
$5,
$6 
FROM @DEMO_DB.PUBLIC.%EMP_BASIC
(FILE_FORMAT => CONTROL_DB.FILE_FORMATS.CSV_FORMAT)
MINUS -- compares the data in the files in the table staging area to the already loaded data, loaded from the same files.
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC;







-- Copy data into Snowflake table, from Internal (Named) staging area
COPY INTO DEMO_DB.PUBLIC.EMP_BASIC
FROM @DEMO_DB.PUBLIC.EMP_BASIC
FILE_FORMAT= (
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT;
);

-- Feed files into Named Stage, from file system, for future use (copy into tables)
put 'file:///path/to/your/local/file/storage/that/will/upload/the/files/*'
@CONTROL_DB.INTERNAL_STAGES.MY_INT_STAGE/EMP_BASIC;

-- Describe Stage Object:
DESC STAGE DEMO_DB.INTERNAL_STAGES.MY_INT_STAGE







-- The inverse way ("unload" of data), copying/transferring data from Snowflake tables to Stages (Internal, External), examples:


-- Copy data from Snowflake Table (tabular data) into Table Stage (csv files, parquet data, json, etc)...
COPY INTO @DEMO_DB.PUBLIC.%EMP_BASIC
FROM DEMO_DB.PUBLIC.EMP_BASIC
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);

-- Copy (unload) data from Snowflake Table into Table Stage, in .json format outputted files.
COPY INTO @DEMO_DB.PUBLIC.%EMP_BASIC
FROM 
(
    SELECT object_construct(*) FROM DEMO_DB.PUBLIC.EMP_BASIC
)
FILE_FORMAT=(
TYPE=JSON
    );

-- Copy only some columns of your table into Table Stage
COPY INTO @DEMO_DB.PUBLIC.%EMP_BASIC
FROM (
    SELECT
    FIRST_NAME,
    LAST_NAME,
    EMAIL
    FROM  DEMO_DB.PUBLIC.EMP_BASIC
)
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
)
-- OVERWRITE=TRUE; -- used if you want to replace a file that is already living in the stage area.


-- Count rows copied into Table Stage's files - compare with number of rows in your Snowflake Table
SELECT COUNT(*) FROM @DEMO_DB.PUBLIC.%EMP_BASIC;


-- Downloads the files to your local system, in csv/json/parquet format; these are the files now residing 
-- in the  Table Staging Area. This command can only be used inside Snow CLI (does not work in worksheets)
GET @DEMO_DB.PUBLIC.%EMP_BASIC
file:///path/to/your/local/file/storage/that/will/receive/the/file;

-- After downloading the files, remove them from Table Stage area, to save costs
rm @DEMO_DB.PUBLIC.%EMP_BASIC; -- in Snow CLI
REMOVE @DEMO_DB.PUBLIC.%EMP_BASIC; -- in Worksheets
 






-- MODULE 12 -- 


-- M12 - Basic Error Handling During COPY command process --


-- In real-life scenarios, it is extremely common 
-- to receive errors during the execution of Copy commands.
-- The errored-out records must not be ignored, and should 
-- preferably be stored in an additional table, so they 
-- can be debugged in the future.

-- To achieve this goal, we must use the "ON_ERROR='CONTINUE'"
-- option, in our COPY command.




-- Error handling example: 


-- Create Staging Table
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.EMP_BASIC (
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    STREETADDRESS STRING,
    CITY STRING,
    START_DATE DATE
);

-- Transform values during copy (with 'iff()'), to avoid errors
COPY INTO TAXI_DRIVE FROM
(
SELECT 
T.$1,
T.$2,
iff(T.$3='', null, T.$3), -- in a given row, if the value found in the third column is '', convert it to null; otherwise, maintain it as the same value.
iff(T.$4='', null, T.$4), -- in a given row, if the value found in the fourth column is '', convert it to null; otherwise, maintain it as the same value.
T.$5,
T.$6,
T.$7,
T.$8,
T.$9
FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE AS T
)
    FILE_FORMAT=(
        FORMAT_NAME='CSV_FORMAT'
        field_optionally_enclosed_by='"'
    )
ON_ERROR='CONTINUE';

-- Continue copying, even with errors ("PARTIALLY LOADED")
COPY INTO DEMO_DB.PUBLIC.EMP_BASIC
FROM (
    SELECT 
    T.$1,
    T.$2,
    T.$3,
    T.$4,
    T.$5,
    T.$6
    FROM @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE AS T
)
ON_ERROR='CONTINUE';

-- Use "VALIDATE()" function, to show which records errored-out during the copy - "column_name" shows the column that caused the error.
SELECT * FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.EMP_BASIC, JOB_ID => <your_query_id>));

-- Create a table, "REJECTED_RECORDS" with the format 'error_message - rejected record'.
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.REJECTED_RECORDS 
AS 
SELECT * FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.EMP_BASIC, JOB_ID => <your_query_id>));

-- Create another table, without the error messages, and only the rejected record's values in the columns.
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.FORMATTED_REJECTED_RECORDS AS
SELECT 
SPLIT_PART(rejected_record, ',', 1 ) as first_name,
SPLIT_PART(rejected_record, ',', 2 ) as last_name,
SPLIT_PART(rejected_record, ',', 3 ) as email,
SPLIT_PART(rejected_record, ',', 4 ) as streetaddress,
SPLIT_PART(rejected_record, ',', 5 ) as city,
SPLIT_PART(rejected_record, ',', 6 ) as start_date
FROM DEMO_DB.PUBLIC.REJECTED_RECORDS;









-- MODULE 13 -- 



-- M13 - External Tables --


-- In the MODULE 11, at the beginning, there is an example 
-- of how to query data from S3 directly, using Snowflake but 
-- without using many of its features (caching, micropartitions, table scans);
-- in that approach, we use views to query the data stored in S3.

-- However, there is an alternative approach, generaly better 
-- than direct SELECTs and views, that is the usage of External Tables, 
-- to query that S3 data directly. This approach is much better because 
-- it leverages the metadata feature of snowflake, to make the queries much 
-- faster. 

-- With external tables, Snowflake can actually use caching and metadata, and 
-- can pinpoint "which files need to be queried from the bucket" whenever we run
-- any query, on top of these tables (differently from views and direct Selects, 
-- which will always query all the files in our buckets).

-- The External Table approach is still not the most optimal one (the most optimal 
-- would be to load all the data into Snowflake and use all its features), but it 
-- is still better than direct SELECT queries and Views.

-- These External Tables, by default, always start with only a single 
-- column, named "VALUE", of data type "VARIANT" (json objects). If we want these tables 
-- to have "regular" columns, with single values inside them, we must 
-- use the Snowflake access syntax (with "col:key_name", like "VALUE:c1", for example). However,
-- even if we use that syntax and omit the "VALUE" column, it will still be included in the final 
-- table, along with the "normal" columns.

-- However, if we are to use External Tables, we need to integrate them with the SQS (the one I know how to set up)
-- and SNS AWS services. If we don't, our External Tables won't refresh automatically when new files are uploaded 
-- to our bucket. OBS: Snowflake maintains only a single SQS Queue for all your buckets.

-- Optionally, if we want to leverage even more of Snowflake's features, we can partition our
-- External Tables, utilizing "metada$filename" as the only parameter (that way, we can 
-- create "pseudofolders" inside of our table, based on the filename criteria). For more info,
-- check the example below, right after the manual refresh command.

-- Also, External Tables cannot be cloned, and cannot have Fail-safe zones.

-- Syntax:



-- Create External Table
CREATE OR REPLACE EXTERNAL TABLE DEMO_DB.PUBLIC.<EXT_TABLE_NAME>
WITH LOCATION = @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE -- mandatory - our s3 external stage, with the integration object already set up.
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);

-- Describe External Table
DESC TABLE ext_table_example;

-- Table format will be:

--
-- name: value  (the column's name will be 'VALUE')
-- type: VARIANT 
-- kind: column 
-- null: y 
-- default: null
--

-- Check validity
SELECT * FROM ext_table LIMIT 100;

-- Values, in each row, will have this format (data type VARIANT, single column, of name "VALUE"):

-- {   "c1": "Nyssa",   "c2": "Dorgan",   "c3": "ndorgan5@sf_tuts.com",   "c4": "7 Tomscot Way",   "c5": "Pampas Chico",   "c6": "4/13/2017" }
-- {   "c1": "Catherin",   "c2": "Devereu",   "c3": "cdevereu6@sf_tuts.co.au",   "c4": "535 Basil Terrace",   "c5": "Magapit",   "c6": "12/17/2016" }
-- {   "c1": "Grazia",   "c2": "Glaserman",   "c3": "gglaserman7@sf_tuts.com",   "c4": "162 Debra Lane",   "c5": "Shiquanhe",   "c6": "6/6/2017" }



-- Create another table, transient, based on that external table's single column's values (with "normal" columns and values):
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.FORMATTED_EXT_TABLE
AS 
SELECT 
VALUE:c1 AS first_name,
VALUE:c2 AS last_name,
VALUE:c3 AS email,
VALUE:c4 AS street_address,
VALUE:c5 AS country,
VALUE:c6 AS created_date
FROM DEMO_DB.PUBLIC.<EXT_TABLE_NAME>;

-- Create another table based on external table, while transforming data types:
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.FORMATTED_EXT_TABLE
AS 
SELECT 
VALUE:c1::STRING AS first_name,
VALUE:c2::STRING AS last_name,
VALUE:c3::STRING AS email,
VALUE:c4::STRING AS streetaddress,
VALUE:c5::STRING AS country,
VALUE:c6::DATE AS created_date
FROM DEMO_DB.PUBLIC.<EXT_TABLE_NAME>;

-- Show All External Tables
SHOW EXTERNAL TABLES;

-- Create External Table in a specific format (but "VALUE" field will still be included)
CREATE OR REPLACE EXTERNAL TABLE DEMO_DB.PUBLIC.<EXT_TABLE_NAME>
(
    FIRST_NAME STRING AS (value:c1::string),
    LAST_NAME STRING(20) AS (value:c2::string),
    EMAIL STRING AS (value:c3::string)
)
WITH LOCATION=@CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);

-- Values, in each row, will have this format:

-- VALUE                                                                                                                                               FIRST_NAME  LAST_NAME    EMAIL
-- {   "c1": "Di",   "c2": "McGowran",   "c3": "dmcgowrang@sf_tuts.com",   "c4": "1856 Maple Lane",   "c5": "Banjar Bengkelgede",   "c6": "2017-04-22" }	    Di	McGowran	dmcgowrang@sf_tuts.com
-- {   "c1": "Carson",   "c2": "Bedder",   "c3": "cbedderh@sf_tuts.co.au",   "c4": "71 Clyde Gallagher Place",   "c5": "Leninskoye",   "c6": "2017-03-29" }	Carson	Bedder	cbedderh@sf_tuts.co.au
-- {   "c1": "Dana",   "c2": "Avory",   "c3": "davoryi@sf_tuts.com",   "c4": "2 Holy Cross Pass",   "c5": "Wenlin",   "c6": "2017-05-11" }	                    Dana	Avory	davoryi@sf_tuts.com


-- Check External Table metadata
SELECT * FROM table(SNOWFLAKE.INFORMATION_SCHEMA.EXTERNAL_TABLE_FILES(TABLE_NAME => '<ext_table_name>'));

-- Check External Table metadata
SELECT * FROM table(SNOWFLAKE.INFORMATION_SCHEMA.EXTERNAL_TABLE_FILE_REGISTRATION_HISTORY(TABLE_NAME=>'<ext_table_name>'));

-- Manual refresh of External Table (cumbersome, but if we don't use AWS SNS and the auto-refresh feature, we 
-- must do this every time a new file is uploaded to our buckets)
ALTER EXTERNAL TABLE <ext_table_name> REFRESH;



-- Optional - To save up costs and time spent with processing, if, when we run queries,
-- we are 100% sure that some row can only exist inside of one of our files in the collection (thousand of files, for example) of 
-- files in the s3 bucket, we can search for that specific file, considering its filename as a partition (less partitions scanned,
-- less compute cost). This partition feature becomes especially useful when your volume of data increases over time.

-- For that, we must write like this:



-- Create External Table, but Partition By "DEPARTMENT" column, created by the usage of the "metadata$filename" value.
CREATE OR REPLACE EXTERNAL TABLE DEMO_DB.PUBLIC.<EXT_TABLE_NAME>
(
    DEPARTMENT VARCHAR AS SUBSTR(METADATA$FILENAME, 5, 11), -- "department" will be values like 'employees01', 'employees02', extracted from filenames like 'employee2112312.csv.gz'
    FIRST_NAME STRING AS (VALUE:c1::string),
    LAST_NAME STRING(20) AS (VALUE:c2::string),
    EMAIL STRING AS (VALUE:c3::string)
    PARTITION BY (DEPARTMENT)
    WITH LOCATION = @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE
    FILE_FORMAT=(
        FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT;
    )
);


-- To utilize the partitions (reduce processing costs and time), we must run SELECTS like this:
SELECT
*
FROM DEMO_DB.PUBLIC.<EXT_TABLE_NAME>
WHERE department='employees03' -- usage of partitions
 AND first_name='John';



 -- How to set up AWS SQS, to auto-refresh our external tables each time our buckets receive new files:


-- 1) The property "AUTO_REFRESH" is already defined as TRUE, as a default, in every external table. However,
-- this is not enough, we need to apply some settings in our buckets, also.

-- 2) In our bucket, we must click on "properties", and then on "event notifications", and then on "create".

-- 3) Select "All object creation events" and "All object removal events".

-- 4) In "Destination", select SQS Queue.

-- 5) In "Specify SQS Queue", choose "Enter SQS Queue ARN".

-- 6) Back in snowflake, run:

    SHOW EXTERNAL TABLES;

-- 7) Copy the value of the column "notification_channel"; that string will be our SQS Queue ARN.

-- 8) Paste that string into the "Enter SQS Queue ARN" field.

-- 9) The auto-refresh feature now will be activated.


-- OBS: There is also a "PARTITION_TYPE='USER_SPECIFIED'" option, that should be used in cases where the 
-- substr() + metadata$filename syntax is not enough to partition your external table. The use-case for 
-- this advanced syntax is typically scenarios where our data is already present in AWS S3, divided in subfolders.
-- More details about it can be viewed in this Repo's Module 18, lesson 7 (Manual Partitions).




-- MODULE 14 -- 



-- M14 - COPY command options 



-- The options are:


-- 1) VALIDATION_MODE

"This option instructs the copy command to validate the data 
files instead of loading them into the specified table; i.e. 
The copy command tests the files for errors, but does not
 load them. The command validates the data to be loaded and
then returns results based on the validation option specified."

-- VALIDATION_MODE, then, helps us save costs with storage.

-- It's always a good idea to include this option in the 
-- COPY command before we actually try to copy data into our 
-- tables.

-- One of its quirks is that it does not support COPY
-- statements that transform data during loads.

-- Possible values are:

-- a) 'RETURN_X_ROWS' (rarely used) - Validates the specified number of rows, if no errors are encountered; otherwise, fails at the first error encountered in the rows.

-- b) 'RETURN_ERRORS' - Returns all errors (parsing, conversion, etc.) across all files specified in the COPY statement. if no rows are returned, there are no errors

-- c) 'RETURN_ALL_ERRORS' -- The same as the value seen above, but also
-- includes files with errors that were partially 
-- loaded during an earlier load because the ON_ERROR
-- copy option was set to CONTINUE during the load.

-- 1.5) VALIDATE() - This is not a COPY command option,
--      but must be mentioned, as it is extremely convenient.
--      The VALIDATE() function allows a user to view all errors
--      and errored-out records encountered during a previous COPY INTO
--      execution.

-- 2) FILES/PATTERN 


-- 3) ON_ERROR - Very important Option.


-- The default behavior, for this option, is "ABORT_STATEMENT".

-- This option DOESN'T WORK if you are copying unstructured data (JSON, XML)

-- If you are building data pipelines, this option must always 
-- be set as 'CONTINUE', to avoid breaking the pipeline's execution.

-- Even if we set its value as "CONTINUE", we don't need to worry 
-- about failed records, because we can always get them, later, by 
-- running the query

SELECT * FROM TABLE(VALIDATE(DEMO_DB.PUBLIC.EMP_BASIC, JOB_ID => <your_query_id>));



-- 4) ENFORCE_LENGTH and TRUNCATECOLUMNS - ENFORCE_LENGTH (default value is TRUE) throws an error, in your COPY command, if the value inserted is too long for a given column.
--                                         TRUNCATECOLUMNS (default value is FALSE) truncates the values you insert, if they do not fit the given column.


-- 5) FORCE - (default value is FALSE) Forces the copying of your files into your tables, even if those files have already been 
--    copied before (will generate duplicate rows in your tables, identical data).


-- 6) PURGE - (default value is FALSE) Deletes files present in your staging area (both Internal and External), after a successful COPY. Use with care.


-- 7) LOAD_HISTORY (view) - with this information schema view, you are able to retrieve the history of data loaded into tables 
--    using the COPY INTO <table>  command. The view displays one row for each file loaded. This historical data, of each COPY command you run, is maintained 
--    for 14 days. However, this view has a limitation: it can only display up to 10.000 rows. If we want to bypass this limit, we must use the "copy_history()" function.

    -- To visualize this view, we run:

-- View Load History for all tables (ACCOUNTADMIN needed) - "COPY INTO" historical data is kept for 14 days.
SELECT * FROM SNOWFLAKE.INFORMATION_SCHEMA.LOAD_HISTORY
    ORDER BY last_load_time DESC;

-- View Load History for a given database
SELECT * FROM DEMO_DB.INFORMATION_SCHEMA.LOAD_HISTORY
    ORDER BY last_load_time DESC;

-- View Load History for all tables (ACCOUNTADMIN needed) - This view is special. Here, the "COPY INTO" historical data is kept for 365 days.
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY;


-- 8) COPY_HISTORY (function) - Similar to the LOAD_HISTORY view, but provides more information (details about file size and stage location)
--    and has no limit of 10.000 rows. There's also a 'COPY_HISTORY' view, account-level, that provides historical data of up to 365 days.

    -- To run this function, we write:

-- Visualize "COPY INTO" history for a given table.
SELECT * FROM TABLE(DEMO_DB.INFORMATION_SCHEMA.COPY_HISTORY(TABLE_NAME=>'EMP_BASIC', START_TIME=>DATEADD(hours, -42, CURRENT_TIMESTAMP())));
-- WHERE error_count > 0;


    -- To use the "COPY_HISTORY" account-level view, we write:

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY;


-- 9) SINGLE - if set as TRUE,
--    the default behavior when unloading (i.e. splitting 
--    your table's row data into multiple files, in your 
--    internal stage) is switched by a behavior that forces
--    your tabular data to create a single file.






-- MODULE 15 -- 



-- M15 - Load Unstructured Data (JSON, XML) -- 



-- When loading/parsing JSON, always refer to element names (keys in the json)
-- with correct casing (they are case-sensitive; "name" is different than "Name"),
-- like "SELECT VALUE:employee:name" instead of "SELECT VALUE:employee:Name".


-- To traverse semi-structured data, in Snowflake,
-- we use the dot notation (.) and bracket notation ([], for arrays).


-- The semi-structured data formats supported by 
-- Snowflake are:

-- AVRO

-- XML 

-- ORC 

-- JSON 

-- PARQUET


-- To parse semi-structured data, we have many useful
-- functions, like 'FLATTEN()' and 'INFER_SCHEMA()" (
-- which is used to automatically detect a schema definition
-- )


-- Select and Load JSON Data, Basic Syntax:




-- Select JSON data from External Stage, in a JSON file, without copying the file into a Snowflake Table:
SELECT
$1
-- $1:"name"::string AS name, 
-- $1:"age"::number AS age
FROM @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE/example.json
(file_format=> @CONTROL_DB.FILE_FORMATS.JSON_FORMAT);


-- Create Raw Table - single column, data type "VARIANT"
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.EMP_JSON_RAW (
    V VARIANT
);

-- Inserting Raw Json data into table
INSERT INTO DEMO_DB.PUBLIC.EMP_JSON_RAW
SELECT 
    PARSE_JSON(
'{
   "fullName":"Johnny Appleseed",
   "age":42,
   "gender":"Male",
   "phoneNumber":{
      "areaCode":"415",
      "subscriberNumber":"5551234"
   },
   "children":[
      {
         "name":"Jayden",
         "gender":"Male",
         "age":"10"
      },
      {
         "name":"Emma",
         "gender":"Female",
         "age":"8"
      },
      {
         "name":"Madelyn",
         "gender":"Female",
         "age":"6"
      }
   ],
   "citiesLived":[
      {
         "cityName":"London",
         "yearsLived":[
            "1989",
            "1993",
            "1998",
            "2002"
         ]
      },
      {
         "cityName":"San Francisco",
         "yearsLived":[
            "1990",
            "1993",
            "1998",
            "2008"
         ]
      },
      {
         "cityName":"Portland",
         "yearsLived":[
            "1993",
            "1998",
            "2003",
            "2005"
         ]
      },
      {
         "cityName":"Austin",
         "yearsLived":[
            "1973",
            "1998",
            "2001",
            "2005"
         ]
      }
   ]
}'
    );

-- Selecting key from variant column, without string transformation. Column value output: "Johnny Appleseed" (with quotes)
SELECT v:fullName AS full_name 
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW;

-- Selecting key from variant column, with string and number transformations. Column value output: Johnny Appleseed (no quotes), 42 (number), male (string)
SELECT 
v:fullName::string AS full_name,
v:age::int AS age,
v:gender::string AS gender
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW;

-- Selecting nested data, inside variant colummn's json values:
SELECT 
v:phoneNumber.areaCode::string AS area_code,
v:phoneNumber.subscriberNumber::string AS subscriber_number
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW;

-- Selecting nested data, but one of the columns is not in our Json objects/values - Column value will appear as null, and no errors will be thrown (a good thing)
SELECT 
v:phoneNumber.areaCode::string AS area_code,
v:phoneNumber.subscriberNumber::string AS subscriber_number,
v:phoneNumber:extensionNumber::string AS extension_number -- this column doesn't exist in our current JSON data - its value will appear as NULL
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW;

-- Produce one row for each child of the same parent - Be careful with this syntax, as the repetition of code can be bad, bad usage of UNION ALLs
SELECT 
v:fullName::string AS parent_name,
v:children[0].name::string FROM DEMO_DB.PUBLIC.EMP_JSON_RAW
UNION ALL
SELECT
v:fullName::string AS parent_name,
v:children[1].name::string FROM DEMO_DB.PUBLIC.EMP_JSON_RAW
UNION ALL 
SELECT
v:fullName::string AS parent_name,
v:children[2].name::string FROM DEMO_DB.PUBLIC.EMP_JSON_RAW;

-- To get the same output as the query seen above (but with less code), 
-- we can use one of the most useful functions for unstructured data, "flatten()".
-- OBS: This function must be used with a JOIN.
SELECT 
T:fullName::string AS parent_name,
F.value:name::string AS child_name,
F.value:gender::string AS child_gender,
F.value::string AS child_age
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW AS T, TABLE(flatten(v:children)) AS F;

-- To check how many elements exist in an array, we have "array_size()"
SELECT 
v:fullName::string AS parent_name,
array_size(v:citiesLived) AS number_of_cities_lived_in,
array_size(v:children) AS number_of_children
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW;

-- Parse array within array
SELECT 
v:fullName::string AS parent_name,
c1.value:cityName::string AS city_name,
y1.value:string AS year_lived
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW
TABLE(FLATTEN(v:citiesLived)) c1,  -- outer array 
TABLE(FLATTEN(c1.value.yearsLived)) y1  -- inner array
ORDER BY year_lived ASC;

-- Parse array within array, while using aggregation
SELECT 
C1.value:cityName::string AS city_name,
count(*) AS year_lived
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW
TABLE(FLATTEN(v:citiesLived)) C1,
TABLE(FLATTEN(c1.value:yearsLived)) Y1
GROUP BY city_name;

-- Example of INFER_SCHEMA function usage, to automatically
-- detect a schema definition:

CREATE TABLE DEMO_DB.PUBLIC.SS_TABLE
USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE(
      INFER_SCHEMA(
      LOCATION=>'@CONTROL_DB.STAGES.MY_EXT_STAGE',
      FILE_FORMAT=>'FF_PARQUET'
)));

-- After we parse this data, we can store it in other tables, formatted tables, and the like.

////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Some approaches for unstructured data handling, worst to best:

-- 1 - (worst)
-- It is possible to use COPY INTO to load JSON data into Transient Tables with single columns of type "VARIANT" and keep querying
-- data from these tables, but this practice is not recommended (can be slow when huge volumes of data are involved).
-- Syntax:
COPY INTO DEMO_DB.PUBLIC.EMP_JSON_RAW
FROM 
@CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE/example.json
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.JSON_FORMAT
);


-- 2 - (good, but not the best)
-- We can use Transient Tables with single columns, of type VARIANT, to receive our data from external stages.
-- Afterwards, we can use that data, in that single column, in an INSERT INTO statement to another table, permanent
-- and with proper columns. However, the problem in this approach is that if you receive any data type errors (value must be DATE,
-- but is received as STRING) while attempting to insert the data, you won't be able to fetch the
-- rejected records with the VALIDATE() function, as that function is restricted to the COPY command. 
-- Syntax:
INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC -- permanent, final table
SELECT 
V:"name"::string AS NAME,
V:"email"::string AS EMAIL,
V:"age"::age AS AGE
FROM DEMO_DB.PUBLIC.EMP_JSON_RAW AS V; -- Transient table

-- 3 - (best approach possible) - only drawback is the storage in Snowflake Internal Stage and AWS at the same time, until you delete the files in your Internal Stage
-- To have the error handling provided by the COPY command, we must:

-- 1) Parse JSON data directly from AWS S3 External Stage (with a SELECT)

-- 2) Copy that parsed data into Snowflake Named Stage/Table Stage Area (data will be transformed into CSV format, inside of Internal Stages)

-- 3) Finally, we COPY INTO our permanent table the csv data that is now living in our Internal Stage (Named/Table)

-- Syntax/queries:


-- Steps 1 and 2 (combined into a single statement):
COPY INTO @DEMO_DB.PUBLIC.%EMP_BASIC  --- copy into internal table staging area.
    FROM (
    SELECT   -- parse data from aws s3 location.
    V:"name"::string AS NAME,
    V:"email"::string AS EMAIL,
    V:"age"::age AS AGE
    FROM @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE/example.json
    (FILE_FORMAT => CONTROL_DB.FILE_FORMATS.JSON_FORMAT)
    );

-- Check if .csv files, our data, is in the Internal Stage
LIST @DEMO_DB.PUBLIC.%EMP_BASIC;

-- Step 3 - Now we get to benefit from the "ON_ERROR='CONTINUE'" copy option, and COPY command's error handling (like the "validate()" function).
COPY INTO DEMO_DB.PUBLIC.EMP_BASIC
FROM @DEMO_DB.PUBLIC.%EMP_BASIC
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
    )
ON_ERROR='CONTINUE';

////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Select and Load XML Data, Basic Syntax:



-- Create Raw Table - single column, data type "VARIANT"
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.EMP_XML_RAW (
    V VARIANT
);

-- Insert XML Data into Variant Column
INSERT INTO DEMO_DB.PUBLIC.EMP_XML_RAW
SELECT
PARSE_XML('<bpd:AuctionData xmlns:bpd="http://www.treasurydirect.gov/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.treasurydirect.gov/ http://www.treasurydirect.gov/xsd/Auction_v1_0_0.xsd">
<AuctionAnnouncement>
<SecurityTermWeekYear>26-WEEK</SecurityTermWeekYear>
<SecurityTermDayMonth>182-DAY</SecurityTermDayMonth>
<SecurityType>BILL</SecurityType>
<CUSIP>912795G96</CUSIP>
<AnnouncementDate>2008-04-03</AnnouncementDate>
<AuctionDate>2008-04-07</AuctionDate>
<IssueDate>2008-04-10</IssueDate>
<MaturityDate>2008-10-09</MaturityDate>
<OfferingAmount>21.0</OfferingAmount>
<CompetitiveTenderAccepted>Y</CompetitiveTenderAccepted>
<NonCompetitiveTenderAccepted>Y</NonCompetitiveTenderAccepted>
<TreasuryDirectTenderAccepted>Y</TreasuryDirectTenderAccepted>
<AllTenderAccepted>Y</AllTenderAccepted>
<TypeOfAuction>SINGLE PRICE</TypeOfAuction>
<CompetitiveClosingTime>13:00</CompetitiveClosingTime>
<NonCompetitiveClosingTime>12:00</NonCompetitiveClosingTime>
<NetLongPositionReport>7350000000.0</NetLongPositionReport>
<MaxAward>7350000000</MaxAward>
<MaxSingleBid>7350000000</MaxSingleBid>
<CompetitiveBidDecimals>3</CompetitiveBidDecimals>
<CompetitiveBidIncrement>0.005</CompetitiveBidIncrement>
<AllocationPercentageDecimals>2</AllocationPercentageDecimals>
<MinBidAmount>100</MinBidAmount>
<MultiplesToBid>100</MultiplesToBid>
<MinToIssue>100</MinToIssue>
<MultiplesToIssue>100</MultiplesToIssue>
<MatureSecurityAmount>65002000000.0</MatureSecurityAmount>
<CurrentlyOutstanding/>
<SOMAIncluded>N</SOMAIncluded>
<SOMAHoldings>11511000000.0</SOMAHoldings>
<FIMAIncluded>Y</FIMAIncluded>
<Series/>
<InterestRate/>
<FirstInterestPaymentDate/>
<StandardInterestPayment/>
<FrequencyInterestPayment>NONE</FrequencyInterestPayment>
<StrippableIndicator/>
<MinStripAmount/>
<CorpusCUSIP/>
<TINTCUSIP1/>
<TINTCUSIP2/>
<ReOpeningIndicator>N</ReOpeningIndicator>
<OriginalIssueDate/>
<BackDated/>
<BackDatedDate/>
<LongShortNormalCoupon/>
<LongShortCouponFirstIntPmt/>
<Callable/>
<CallDate/>
<InflationIndexSecurity>N</InflationIndexSecurity>
<RefCPIDatedDate/>
<IndexRatioOnIssueDate/>
<CPIBasePeriod/>
<TIINConversionFactor/>
<AccruedInterest/>
<DatedDate/>
<AnnouncedCUSIP/>
<UnadjustedPrice/>
<UnadjustedAccruedInterest/>
<ScheduledPurchasesInTD>772000000.0</ScheduledPurchasesInTD>
<AnnouncementPDFName>A_20080403_1.pdf</AnnouncementPDFName>
<OriginalDatedDate/>
<AdjustedAmountCurrentlyOutstanding/>
<NLPExclusionAmount>0.0</NLPExclusionAmount>
<MaximumNonCompAward>5000000.0</MaximumNonCompAward>
<AdjustedAccruedInterest/>
</AuctionAnnouncement>
</bpd:AuctionData>');


-- RootNode - in this example, it is "bpd:AuctionData"


-- Select RootNode's value
SELECT V:"@" FROM DEMO_DB.PUBLIC.EMP_XML_RAW;

-- Select all "Root Elements" (sub-nodes below the rootNode. In this case, "AuctionAnnouncement" and all its sub-nodes)
SELECT V:"$" FROM DEMO_DB.PUBLIC.EMP_XML_RAW;

-- Same output as the above query, but more versatile approach
SELECT XMLGET(V, 'AuctionAnnouncement', 0) FROM DEMO_DB.PUBLIC.EMP_XML_RAW;

-- Output XML nodes as key-value pairs in a JSON object (with ":$" syntax)
SELECT XMLGET(V, 'AuctionAnnouncement', 0):"$" FROM DEMO_DB.PUBLIC.EMP_XML_RAW;

-- outputted JSON ("@" for each node element, "$" for each node's value):


 [   
 {     "$": "26-WEEK",     "@": "SecurityTermWeekYear"   },
 {     "$": "182-DAY",     "@": "SecurityTermDayMonth"   },  
 {     "$": "BILL",     "@": "SecurityType"   },
 {     "$": "912795G96",     "@": "CUSIP"   },   
 {     "$": "2008-04-03",     "@": "AnnouncementDate"   },   
 {     "$": "2008-04-07",     "@": "AuctionDate"   },   
 {     "$": "2008-04-10",     "@": "IssueDate"   },   
 {     "$": "2008-10-09",     "@": "MaturityDate"   },   
 {     "$": 21,     "@": "OfferingAmount"   },   
 {     "$": "Y",     "@": "CompetitiveTenderAccepted"   },  
 {     "$": "Y",     "@": "NonCompetitiveTenderAccepted"   },   
 {     "$": "Y",     "@": "TreasuryDirectTenderAccepted"   },   
 {     "$": "Y",     "@": "AllTenderAccepted"   },   
 {     "$": "SINGLE PRICE",     "@": "TypeOfAuction"   },   
 {     "$": "13:00",     "@": "CompetitiveClosingTime"   },   
 {     "$": "12:00",     "@": "NonCompetitiveClosingTime"   },   
 {     "$": 7350000000,     "@": "NetLongPositionReport"   },   
 {     "$": 7350000000,     "@": "MaxAward"   },   
 {     "$": 7350000000,     "@": "MaxSingleBid"   },   
 {     "$": 3,     "@": "CompetitiveBidDecimals"   },   
 {     "$": 0.005,     "@": "CompetitiveBidIncrement"   },   
 {     "$": 2,     "@": "AllocationPercentageDecimals"   },   
 {     "$": 100,     "@": "MinBidAmount"   },   
 {     "$": 100,     "@": "MultiplesToBid"   },   
 {     "$": 100,     "@": "MinToIssue"   },   
 {     "$": 100,     "@": "MultiplesToIssue"   },   
 {     "$": 65002000000,     "@": "MatureSecurityAmount"   },   
 {     "$": "",     "@": "CurrentlyOutstanding"   },   
 {     "$": "N",     "@": "SOMAIncluded"   },  
 {     "$": 11511000000,     "@": "SOMAHoldings"   },   
 {     "$": "Y",     "@": "FIMAIncluded"   },   
 {     "$": "",     "@": "Series"   },   
 {     "$": "",     "@": "InterestRate"   },   
 {     "$": "",     "@": "FirstInterestPaymentDate"   },   
 {     "$": "",     "@": "StandardInterestPayment"   },  
 {     "$": "NONE",     "@": "FrequencyInterestPayment"   },  
 {     "$": "",     "@": "StrippableIndicator"   },   
 {     "$": "",     "@": "MinStripAmount"   },  
 {     "$": "",     "@": "CorpusCUSIP"   },   
 {     "$": "",     "@": "TINTCUSIP1"   },   
 {     "$": "",     "@": "TINTCUSIP2"   },   
 {     "$": "N",     "@": "ReOpeningIndicator"   }, 
 {     "$": "",     "@": "OriginalIssueDate"   },  
 {     "$": "",     "@": "BackDated"   },   
 {     "$": "",     "@": "BackDatedDate"   },   
 {     "$": "",     "@": "LongShortNormalCoupon"   },  
 {     "$": "",     "@": "LongShortCouponFirstIntPmt"   },   
 {     "$": "",     "@": "Callable"   },   
 {     "$": "",     "@": "CallDate"   },   
 {     "$": "N",     "@": "InflationIndexSecurity"   },  
 {     "$": "",     "@": "RefCPIDatedDate"   },  
 {     "$": "",     "@": "IndexRatioOnIssueDate"   }, 
 {     "$": "",     "@": "CPIBasePeriod"   },   
 {     "$": "",     "@": "TIINConversionFactor"   }, 
 {     "$": "",     "@": "AccruedInterest"   },  
 {     "$": "",     "@": "DatedDate"   },  
 {     "$": "",     "@": "AnnouncedCUSIP"   },   
 {     "$": "",     "@": "UnadjustedPrice"   },   
 {     "$": "",     "@": "UnadjustedAccruedInterest"   },   
 {     "$": 772000000,     "@": "ScheduledPurchasesInTD"   }, 
 {     "$": "A_20080403_1.pdf",     "@": "AnnouncementPDFName"   },  
 {     "$": "",     "@": "OriginalDatedDate"   },   
 {     "$": "",     "@": "AdjustedAmountCurrentlyOutstanding"   },   
 {     "$": 0,     "@": "NLPExclusionAmount"   },   
 {     "$": 5000000,     "@": "MaximumNonCompAward"   }, 
 {     "$": "",     "@": "AdjustedAccruedInterest"   } 
 ]

-- Formatting XML nodes, transforming them into JSON, and then into a table (tabular data):
SELECT 
XMLGET(value, 'SecurityType'):"$" AS 'Security Type',
XMLGET(value, 'MaturityDate'):"$" AS "Maturity Date",
XMLGET(value, 'OfferingAmount'):"$" AS 'Offering Amount',
XMLGET(value, 'MatureSecurityAmount'):"$" AS 'Mature Security Amount'
FROM DEMO_DB.PUBLIC.EMP_XML_RAW,
LATERAL FLATTEN(to_array(xml_demo.v:"$")) AS auction_announcement;


-- Outputted table format:


"SECURITY TYPE"     "MATURITY DATE"          "OFFERING AMOUNT"      "MATURE SECURITY AMOUNT"

"BILL"             "2008-10-09"            21                   650020000000000







-- SECOND PART OF THE SUMMARY - SNOWFLAKE FEATURES -- 







-- MODULE 16 --




-- M16 - Snowpipe 





-- The main purpose of pipes is "continuous"/automatic 
-- data copying in your tables, data extracted from uploaded
-- files.

-- Snowpipe supports copying from External Stage as well
-- as Internal Stage.

-- With Snowpipe, for every file appearing in your bucket,
-- a notification is sent, by AWS S3, to the Snowpipe 
-- Service (serverless) - once this serverless loader
-- detects that notification, it will identify the 
-- new files that were uploaded, and then will load 
-- their contents into your Snowflake Table. Because 
-- the service is serverless, you can't choose a warehouse 
-- to run your pipe with (and the costs for the copy command 
-- will depend on the duration and filesize of your operation)


-- The Snowpipe/pipe objects are basically wrappers
-- around "COPY" commands; they are special wrappers
-- that constantly watch your S3 buckets, waiting for
-- notifications to be thrown by AWS. However, running 
-- COPY commands directly is better in bulk-load scenarios,
-- more reliable.

-- Pipes also have a "repeated-data block" feature, like
-- the COPY command. Unlike the standalone COPY command, 
-- however, the Pipes compare only the filenames of your files,
-- and not their md5 hash values, before deciding whether to
-- block the copy operation to avoid repeated rows.

-- The best practice is to have a single pipe per AWS bucket.

-- If you want to alter the COPY command written 
-- into a Pipe, you need to actually recreate 
-- the pipe, as you can't alter it directly.


-- For the Pipe to work, we must have prepared all 
-- of the objects needed for a normal COPY command,
-- which are:

-- 1) Stage 

-- 2) File Format (best practice)

-- 3) Integration Object (Storage Integration)

-- 4) The Table to COPY your data into



-- After creating all these objects, we need to configure our 
-- S3 bucket so that they really end up sending notifications 
-- to our Pipes, whenever a new file is uploaded. Get the "notification_channel"
-- value of your pipe, and then, in your bucket, do the following:

-- 1) Click on properties 

-- 2) Click on events 

-- 3) Set all create/update/remove events

-- 4) Choose "SQS Queue ARN"

-- 5) Insert the "notification_channel" value of your desired pipe



-- Basic Syntax:




-- Create a Pipe to ingest JSON data
CREATE OR REPLACE PIPE CONTROL_DB.PIPES.JSON_PIPE
    AUTO_INGEST=TRUE -- default value
    AS 
    COPY INTO DEMO_DB.PUBLIC.EMP_BASIC -- COPY command, wrapped by the pipe.
    FROM @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE;

-- Show all Pipes - Get the value of the "notification_channel" field, we need it for the SQS notification service, in our buckets.
SHOW PIPES;


-- Refresh pipe, to check what files got loaded
ALTER PIPE CONTROL_DB.PIPES.JSON_PIPE REFRESH;

-- Recreate pipe. Used in cases in which we want to alter the COPY command in its body.
CREATE OR REPLACE PIPE CONTROL_DB.PIPES.JSON_PIPE
AUTO_INGEST=TRUE 
AS 
COPY INTO DEMO_DB.PUBLIC.EMP_BASIC
FROM @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
);

-- However, even if we refresh pipe, the old metadata will still be in it. We can check this, with the refresh statement
ALTER PIPE CONTROL_DB.PIPES.JSON_PIPE REFRESH;

-- If we want to re-upload a file to AWS and have its contents copied into a Snowflake Table, we must drop our Pipe first, and only then recreate it (this will clear 
-- its metadata):
    DROP PIPE CONTROL_DB.PIPES.JSON_PIPE;
    CREATE PIPE CONTROL_DB.PIPES.JSON_PIPE <...>;



-- Pipe behavior during error scenarios - Not very good:

    -- A) Our errors don't get thrown to the console, nor are notified to us

    -- B) Error message is generic

    -- C) We have to check and validate Pipe object manually

    -- D) Unlike normal COPY commands, COPYs that were run by Pipe objects won't appear in the "query_history" view

    -- E) However, information about Pipe's COPY commands can be found with the "copy_history()" function, as seen in statement 3, shown below

-- To check the error message during the execution of a given Pipe,
-- we run these statements:


-- 1) Check if pipe is running and if it has not errored-out
SELECT SYSTEM$PIPE_STATUS('CONTROL_DB.PIPES.JSON_PIPE');

-- Output:

{
    "executionState": "RUNNING",
    "pendingFileCount": 0
}

-- 2) Check the specific error that was given, if we know the moment it occurred (we can't use the queryId, as it won't be registered)
SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME=>'CONTROL_DB.PIPES.JSON_PIPE'
        START_TIME=>dateadd(hour, -4, current_timestamp())
    )
);

-- Previous query's output (generic error message, not very useful):

'Remote file was not found. There are several potential causes.
The file might not exist. The required credentials may be 
missing or invalid. If you are running a copy command,
please make sure files are not deleted when they are 
being loaded, or files are not being loaded into two 
different tables concurrently with auto purge option'


-- 3) Check info about the failed COPY command, with the "copy_history()" function (ACCOUNTADMIN needed):
SELECT * 
FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.COPY_HISTORY(
    table_name=>'<table_name>',
    start_time=> dateadd(hours, -1, current_timestamp())
));






-- MODULE 17 -- 





-- M17 - Data Sharing


-- (Secure Data Sharing).

-- This feature is not supported in 
-- the "Virtual Private" Snowflake edition,
-- due to stricter security requirements and
-- the isolated environment the account exists in.



-- With this feature, we can share data 
-- from account X to account Y, and, at
-- the same time, without spending on
-- extra data storage and transfer costs.
-- We do this with data shares, which are 
-- objects used to share Snowflake metadata 
-- of user X with another users.

-- With Data Shares, account Y will be able 
-- to query the data of account X, but the 
-- compute costs/processing of that querying
-- will be associated to account Y, and not account X.

-- Furthermore, account Y will have only read-access
-- to the objects provided by account X, not being 
-- able to UPDATE, DELETE nor DROP tables.

-- It is also not possible to clone Shared tables, nor temporary Tables.

-- If a customer wants to take a look into our main table, for whatever reason,
-- we can provide access to a Clone of the main table, instead of providing access
-- directly to it (not a good idea).

-- Data providers can only share data with data consumers that 
-- "live" in the same cloud region/cloud provider as they do. If they 
-- want to share data with data consumers of another region, "Replication"
-- to an account in the data consumers' region is a prerequisite. Also, 
-- consumer account cannot share databases that have been shared with them (re-share).

-- OBS: only Secure Views (views that have their SQL text/definition field hidden/blank) can be provided to 
-- consumer accounts. Regular views are prohibited. 

-- Always remember that Secure Views are a little slower than regular views; this is more noticeable with bigger tables.

-- Also, you can consume as many shares as you want from data providers,
-- but you can only create one database per share.

-- Each Share object is configured with Object Privileges (GRANTS to Database, Schemas and Table Objects)
-- and account identifiers (part of the url of the consumer account)



-- To use this feature, we need:

-- 1) Two accounts, the Producer and the Consumer 

-- 2) To create a Data Share Object, in the Producer account

-- 3) Set the "Grants", the permissions, on the Share Object, in the Producer account

-- 4) Add a user to this Share object, in the Producer account

-- 5) To create a Table from the shared Data Share Object, in the consumer account


-- The Syntax for creating Shares is:


-- Create a share object (data sharing) - Producer
CREATE OR REPLACE SHARE EXAMPLE_SHARE;

-- Set permissions on Share object - Producer
GRANT USAGE ON DATABASE DEMO_DB TO SHARE EXAMPLE_SHARE;
GRANT USAGE ON SCHEMA DEMO_DB.PUBLIC TO SHARE EXAMPLE_SHARE;
GRANT SELECT ON TABLE DEMO_DB.PUBLIC.EMP_BASIC TO SHARE EXAMPLE_SHARE;

-- Check if grants were given to Share object - Producer 
SHOW GRANTS TO SHARE EXAMPLE_SHARE;

-- Add consumer account to newly created Share object - Producer
ALTER SHARE EXAMPLE_SHARE
ADD ACCOUNTS=<account_id>

-- Drop Share 
DROP SHARE EXAMPLE_SHARE;

-- Show all Shares, in Consumer account
DESC SHARE <producer_account>.EXAMPLE_SHARE;

-- Show Grants to our Share
SHOW GRANTS TO SHARE EXAMPLE_SHARE;

-- Create Secure View, to be shared with Share object (sharinng normal views is not allowed)
CREATE OR REPLACE SECURE VIEW DEMO_DB.PUBLIC.EMP_BASIC_S_VIEW
AS SELECT first_name, last_name, email
FROM DEMO_DB.PUBLIC.EMP_BASIC;

-- Alters a View, transforms it into a Secure View (so it can be used with Data Shares)
ALTER VIEW <view_name> SET SECURE;

-- Create a database in Consumer account, using the Share object.
CREATE DATABASE DATA_S FROM SHARE <producer_account>.EXAMPLE_SHARE;

-- Validate table access (uses compute from account B, and queries from account A)
SELECT * FROM DATA_S.PUBLIC.DEMO_DB;





-- If you want to share your tables with someone/
-- something that does not have a Snowflake account,
-- you can create a Snowflake account inside of your
-- account, with read-only access. This type of account 
-- is called "Reader" or "Managed" accounts. The difference,
-- with Reader accounts, is that all processing done by them,
-- usage of warehouses, is billed to their "parent" account,
-- the account that created them.

-- Because this will be a "separate account", inside of your main
-- one, you should create warehouses and roles inside it, to be used 
-- with it (nevertheless, the billing will still be sent to your parent 
-- account).

-- Reader accounts, as the name suggests, are very limited: no DML operations 
-- are permitted, only SELECTS and the creation of empty tables/simple snowflake objects; 
-- operations with these objects, themselves, are not permitted.


-- Create Reader/Managed Account, inside your Snowflake Account - You should copy the value "accountUrl", because it will be used later - Producer Account
CREATE MANAGED ACCOUNT example_helper_account 
ADMIN_NAME=example_admin,
ADMIN_PASSWORD='example_admin_@456',
TYPE=READER;

-- Add Reader Account to Share - insert the "accountUrl" in the placeholder field - Producer Account
ALTER SHARE EXAMPLE_SHARE
ADD ACCOUNTS=<reader_account_url>;

-- Create Database From Share - Consumer/Reader account
CREATE DATABASE SHARED_DATABASE FROM SHARE <producer_account_id>.EXAMPLE_SHARE;







-- MODULE 18 --







-- M18 - Time Travel




-- Before even considering Time Travel, as a common best practice, whenever we 
-- attempt to run a large, conscious DML on one of our tables, we should always create a backup
-- of that table, preferably using the "Clone" feature of Snowflake (doing so, we save compute power).


-- Time Travel is available in Permanent (1 to 90 days retention period) and Transient Tables (1 day, max).
-- We must always be aware that Time Travel generates storage costs; the more we update our tables, the more
-- cost we'll generate (more "versions" of our table will be created, behind the scenes). The more days we set as
-- retention period, the more costs we'll generate, as well.

-- When a Transient Table is created, its Retention Period is set to 1 (one day, the max). We can disable
-- its Time Travel feature afterwards, if we set its Retention Period to 0.

-- With production tables, a good Retention Period is 4-5 days; with this value, we get to benefit from added
-- security, with not so high additional storage costs (though the additional cost may vary depending on our use-cases;
-- the more frequent our updates, the higher the cost).

-- If we clone one of our databases, to use the clone for Analytics purposes, we should create the clone
-- as Transient and set its Retention Period to 0 (because, as it will be a complete copy of 
-- the original object, it'll also have its Retention Period, whatever value it may be).

-- There are two ways to restore the data of a table, in disaster scenarios, using Time Travel. 
-- One proper, other unproper.


-- A) Unproper way, doing the restore with a single command (CREATE OR REPLACE), which will erase table's timeline (table's hidden ID will be dropped):


-- Restores table data to former state, before the mistake, but erases Table's timeline completely
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.EMP_BASIC 
AS 
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC BEFORE(statement => '<your-query-id>');




-- For the proper way, there is more than one step. You must:

-- 1) Create a Staging Table, of type 'Transient'

-- 2) Copy (INSERT) the data of our table at the moment before the mistake, into that Staging Table

-- 3) Truncate all the data of our current Permanent table (there is no problem in doing so; its timeline will still be in order, we can always go back)

-- 4) Copy (INSERT) the data of our Staging Table (data before the mistake) into our current Permanent (production table), which will be empty, before 
-- the copy.

-- With the proper way, we maintain the timeline of the original (production, permanent) Table, and also restore all the damaged data.






-- Basic Syntax:


-- Shows you how much bytes are being used with Time Travel (TIME_TRAVEL_BYTES) and Fail-safe (FAILSAFE_BYTES), compared to your actual storage (ACTIVE_BYTES)
SELECT * FROM <database_name>.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS;

-- Alter Retention Period of your Table (possible with Transient and Permanent tables)
ALTER TABLE DEMO_DB.PUBLIC.EMP_BASIC_PERMANENT
SET DATA_RETENTION_TIME_IN_DAYS=45; -- max is 90, for enterprise and higher. For standard edition, maximum is 1.

ALTER TABLE DEMO_DB.PUBLIC.EMP_BASIC_TRANSIENT
SET DATA_RETENTION_TIME_IN_DAYS=1; -- options are 0 (disabled) or 1 (maximum)

-- Disable Time Travel in your table (possible with Transient and Permanent tables)
ALTER TABLE DEMO_DB.PUBLIC.EMP_BASIC_PERMANENT
SET DATA_RETENTION_TIME_IN_DAYS=0;

-- Get the state of your table 1 minute into the past
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC AT(offset => -60 * 1);

-- Get the state of your table, AT a given moment, using timestamps
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC AT(TIMESTAMP => 'Mon, 01 May 2015 16:20:00 -0700'::TIMESTAMP);
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC AT(TIMESTAMP => TO_TIMESTAMP(1432669154242, 3));

-- (most useful) Get the state of your table, BEFORE the execution of a certain statement/transaction (queryId needed)
SELECT * from DEMO_DB.PUBLIC.EMP_BASIC BEFORE(STATEMENT => '<query_id>'); -- format: 8e5d0ca9-005e-44e6-b858-a8f5b37c5726

-- Return the difference in table data resulting from a certain statement/transaction
SELECT
OLD_TABLE.*,
NEW_TABLE.*
FROM DEMO_DB.PUBLIC.EMP_BASIC BEFORE(STATEMENT => '8e5d0ca9-005e-44e6-b858-a8f5b37c5726') as OLD_TABLE
FULL OUTER JOIN DEMO_DB.PUBLIC.EMP_BASIC AT(STATEMENT => '8e5d0ca9-005e-44e6-b858-a8f5b37c5726') as NEW_TABLE
ON OLD_TABLE.id = NEW_TABLE.id
WHERE OLD_TABLE.id IS NULL OR NEW_TABLE.id is null;

-- Undo the Drop of a Table
DROP TABLE DEMO_DB.PUBLIC.EMP_BASIC;
UNDROP TABLE DEMO_DB.PUBLIC.EMP_BASIC;

-- Undo the Drop of Schemas and Databases
DROP SCHEMA DEMO_DB.PUBLIC;
UNDROP SCHEMA DEMO_DB.PUBLIC;
DROP DATABASE DEMO_DB;
UNDROP DATABASE DEMO_DB;







-- MODULE 19 --




-- M19 - Fail-safe



-- This feature doesn't exist in Transient and Temporary tables.

-- Fail-safe is a "continuous backup" of your data, done 
-- after the chosen retention period of your table ends (1-90 days). 
-- Fail-safe zone is the 7-day period after the retention period of your tables,
-- where the backup of your data will be kept. Fail-safe is not configurable, 
-- and is always present in Permanent Tables.

-- If we create our tables as Permanent and then set their retention period 
-- to 0 (Time Travel disabled), we'll have only Fail-Safe enabled. This means 
-- that every one of our changes to the table will be sent to the Fail-safe zone,
-- directly. 

-- Data in the Fail-safe zone will be kept (and use storage) for 7 days.

-- The difference between Fail-safe and Time Travel is that Time Travel
-- can be managed by us (with commands, queries, etc); Fail-safe, on the other 
-- hand, can only be manipulated by the Snowflake team, which will attempt 
-- to recover our damaged data, service provided on a "best effort basis", 
-- and totally case-by-case.

-- As the costs with Fail-safe can quickly stack up, developers, when testing 
-- features, should create and use Transient Objects (like whole databases),
-- to avoid the Fail-safe cost produced by Permanent Objects. This is a best 
-- practice because developers will be constantly creating and dropping tables,
-- which will generate those unwanted Fail-safe bytes. Less important Tables, 
-- in your system, should also be maintained as Transient Tables.

-- Staging tables should always be created as Transient Tables, as well. Additionaly,
-- a best practice is to set its Retention Time to 0, to disable Time Travel.



-- Useful commands, to check Fail-safe usage:



-- Table storage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

-- Shows you how much bytes are being used with Time Travel (TIME_TRAVEL_BYTES) and Fail-safe (FAILSAFE_BYTES), compared to your actual storage (ACTIVE_BYTES)
SELECT * FROM <database_name>.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS;








-- MODULE 20 -- 







-- M20 - Cloning





-- With cloning, we copy only the metadata of the original table,
-- saving costs with data transferring and storage (the original table's 
-- data/storage location is used). Costs will be generated only if we 
-- update/change the clone, with new data/operations.

-- Even though both tables, the original and the clone, point to the 
-- same "original location", both will be completely independent 
-- of each other, meaning that if we update/change the data in one 
-- of the objects, the other one won't be affected.

-- As we are copying the metadata of the original table, a lot 
-- of things will be copied, such as the table's timeline, clustering keys,
-- comments, etc. 

-- We can also combine Cloning with other features, like Time Travel,
-- to create clones of our original table, at certain moments in the past.

-- The objects that can be cloned are Databases,
-- Schemas, Tables, Stages, File Formats and Tasks.






-- Example Syntax:



-- Create clone of original table (creating a copy of its metadata)
CREATE TABLE DEMO_DB.PUBLIC.EMP_BASIC_CLONE
CLONE DEMO_DB.PUBLIC.EMP_BASIC;

-- Combine Cloning and Time Travel
CREATE TABLE DEMO_DB.PUBLIC.EMP_BASIC_TIME_TRAVELER_CLONE
CLONE DEMO_DB.PUBLIC.EMP_BASIC
BEFORE (TIMESTAMP => <timestamp>);

-- Proof that Originals and Clones are independent (CLONE_GROUP_ID is the same in both objects, as the Clone inherits metadaata from the Original, but the "ID" itself, in both of them, is different)
SELECT * FROM DEMO_DB.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_NAME LIKE 'EMP_BASIC';



-- Another useful feature, if somewhat niche, is the SWAP command.
-- It allows us to swap the metadata of two different tables,
-- essentially/effectively swapping the storage/data inside of them.

-- We use this in use-cases where we want to replace the data in 
-- our production table with the data of our development table (like 
-- in scenarios where the data in our production table is wrong/old and the 
-- data in our development table is correct/updated).

-- With this feature, we can safely move the data/metadata from the Production Table 
-- to the Development Table, where it can be safely stored. The data/metadata from 
-- the Development Table is then put into the Production Table, where it can be promptly 
-- used.





-- Example Syntax:

-- Create Development Table
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.EMP_DEV (
    first_name string,
    last_name string,
    email string,
    streetaddress string,
    city string,
    start_date date
);

-- Development Table receives/ends up with correct data:
COPY INTO EMP_DEV 
FROM @CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE
FILE_FORMAT=(
    FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
)
ON_ERROR='CONTINUE';


-- Create Production Table 
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.EMP_PROD (
    first_name string,
    last_name string,
    email string,
    streetaddress string,
    city string,
    start_date date
);

-- Wrong operation - Mistake is made - all rows with invalid value 
UPDATE DEMO_DB.PUBLIC.EMP_PROD 
SET first_name='Dummy';

-- Swap Development Table metadata with Production Table metadata (Prod Table's data will move to Dev Table)
ALTER TABLE DEMO_DB.PUBLIC.EMP_PROD 
SWAP WITH DEMO_DB.PUBLIC.EMP_DEV;







-- Additionaly, the SWAP feature allows us to very smartly undo mistakes/errors in our
-- tables. The steps are:


-- 1) Create a clone of the Production table, the table that has the problem.

-- 2) Afterwards, we fix the error in that Clone table (that, at the moment, is equal to the Production Table)

-- 3) Lastly, to apply your fix on the current Production Table, you simply run a "SWAP WITH" between the
--    Production table and that "Patched-Production" (Clone) table, swapping their metadata sets.

-- 4) With this, the "errored-out" data of the Production Table will be kept inside the previous clone table,
--    and the fixed data of the Production table will now live inside of the actual Production Table.





-- MODULE 21 -- 








-- M21 - Data Sampling






-- During development activity, we'll run many queries
-- to get information about our tables' structure and 
-- data distribution. If we insist on running our test/analytical
-- queries on top of our entire tables, we'll:

-- 1) Spend a lot of compute resources unecessarily 

-- 2) Be forced to wait a long time for the queries to finish



-- That's why it's a good idea to create samples of our 
-- main tables, so we can run these test queries on smaller 
-- subsets of data. If our queries run satisfactorily in 
-- these smaller subsets, we can eventually test them 
-- on the main tables, as well.

-- Sampling reduces development cost, development lifecycle,
-- and can lead to up to 80% precision in your tests, when 
-- compared to the testing on top of the real table.

-- The creation of samples is better than the creation of 
-- clones on top of your main tables, because with samples
-- we save compute power and storage costs (we won't run our 
-- tests on top of the original table, like we do with the clones).

-- We have two ways to create a sample from a table, in 
-- Snowflake, Bernoulli (row-based) and System (block-based).
-- Both have different use-cases.

-- In both sampling methods, we can define "seeds". These are used 
-- to replicate sampling results along repeated runs, so we can share
-- these results among colleagues (ex: "I got x result in this test, the
-- seed was 349, take a look at it as well.")




-- Bernoulli (row) method:

-- We define "p" as the chance, out of a 100%, of each 
-- row of being selected and compiled in the final sample.
-- A value of p of 10, in a table of 1 million, for example, 
-- would produce a final sample of 100.000 rows.

-- Advantage: It's more random, the produced sample is 
-- more realistic/real than the one produced by the System 
-- method.

-- Disadvantage: It's more processing intensive, as it runs 
-- for each row. It also takes more time to finish creating 
-- the sample, even more so in huge tables.


-- Ideal use-case: small to medium-sized tables.


-- Example Syntax:


-- Create a sample from a table, using row method - here, the p was defined as '3' (3%), and the seed as 82.
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.EMP_BASIC_R_SAMPLE
AS 
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC SAMPLE ROW(3) SEED (82);





-- System (Block) method:

-- Before the sampling starts, Snowflake fractions your 
-- table in multiple blocks. We define "p" as the chance,
-- out of a 100%, of each block of being selected 
-- and compiled in the final sample. As row numbers in each block vary,
-- our samples won't produce exact percentage results like the 
-- ones seen on the Bernoulli method. A value of p of 10, in a
-- table of 1 million, for example, would produce a
-- final sample of 95k-110k rows.

-- Advantage: Its sampling process is cheaper and faster
-- than the one produced by the Bernoulli method.

-- Disadvantage: It's less realistic than the Bernoulli method.


-- Ideal use-case: huge tables.



-- Example Syntax:


-- Create a sample from a table, using system method - here, the p was defined as '3' (3%), and the seed as 52.
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.EMP_BASIC_S_SAMPLE
AS 
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC SAMPLE SYSTEM(3) SEED (52);








-- MODULE 22 --







-- M22 - Tasks







-- In Snowflake, tasks are used to schedule query execution.
-- We can create simple trees of tasks to execute queries, by 
-- creating dependencies between them.

-- Tasks can be combined with Table Streams (Stream Object) to 
-- create continuous ETL workflows, to always process recently 
-- changed table rows.

-- To define a task, we need to specify the Warehouse in which 
-- its attached query will be executed. Also, always be aware of
-- the fact that a task can only execute a single SQL statement.

-- The shortest interval you can set between executions of a given 
-- task is 1 minute.

-- Tasks can be suspended and resumed, with the ALTER TASK command.

-- When a task is created, it will always be set as "SUSPENDED". To 
-- make it start working, we need the ALTER TASK command, to resume it.



-- Example Syntax:





-- Create Task (will be suspended, at first) - first option - Schedule by "Time" string definition
CREATE OR REPLACE CONTROL_DB.TASKS.EMP_BASIC_TASK
    WAREHOUSE = COMPUTE_WH 
    SCHEDULE='1 MINUTE' -- shortest amount of time possible between runs 
AS 
INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC (timestamp) VALUES (CURRENT_TIMESTAMP);

-- Create Task (will be suspended, at first) - second option - Schedule by "CRON" string definition
CREATE OR REPLACE CONTROL_DB.TASKS.EMP_BASIC_TASK
    WAREHOUSE = COMPUTE_WH 
    SCHEDULE='USING CRON 0 9-17 * * SUN America/Los_Angeles' -- MHDMD - MINUTE HOUR DAY OF THE MONTH MONTH OF THE YEAR DAY OF THE WEEK
AS 
INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC (timestamp) VALUES (CURRENT_TIMESTAMP);

-- Resume suspended task (like newly created ones)
ALTER TASK CONTROL_DB.TASKS.EMP_BASIC_TASK RESUME;

-- Suspend resumed task
ALTER TASK CONTROL_DB.TASKS.EMP_BASIC_TASK SUSPEND;

-- Shows which tasks are scheduled in our system
SHOW TASKS;

-- Check Task History - Each entry shows us the reason for errors, if any has occurred.
SELECT * FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY SCHEDULED_TIME DESC;




-- Task trees/dependency:

--         ROOT TASK
--        ---- [] ----
--        i          i 
--        i          i 
--     TASK A      TASK B 
--     I   I       I    i
-- TASK C  TASK D  E     F 




-- Each task can have as many child tasks as needed,
-- but can have only a single parent task related to itself.

-- To start a tree of tasks, the child tasks must be resumed first,
-- and the parent tasks must be resumed last.

-- To suspend a tree of tasks, the root task/parent task must be suspended first,
-- and the child tasks must be suspended last.





-- Example Syntax:




-- Create root (parent) task - created in suspended state
CREATE TASK CONTROL_DB.TASKS.ROOT_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE='1 MINUTE'
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC SELECT '1';

-- Create child task n1
CREATE TASK CONTROL_DB.TASKS.TASK_2
    WAREHOUSE = COMPUTE_WH
AFTER ROOT_TASK
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC_2 SELECT '2';

-- Create child task n2
CREATE TASK CONTROL_DB.TASKS.TASK_3
    WAREHOUSE = COMPUTE_WH
AFTER CONTROL_DB.TASKS.TASK_2
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC_3 SELECT '3';

-- Create child task n3
CREATE CONTROL_DB.TASKS.TASK_4
    WAREHOUSE = COMPUTE_WH
AFTER CONTROL_DB.TASKS.TASK_3
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC_4 SELECT '4';

-- Create child task n4
CREATE TASK CONTROL_DB.TASKS.TASK_5
    WAREHOUSE = COMPUTE_WH
AFTER CONTROL_DB.TASKS.TASK_4
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC_5 SELECT '5';

-- Create child task n5
CREATE TASK CONTROL_DB.TASKS.TASK_6
    WAREHOUSE = COMPUTE_WH
AFTER CONTROL_DB.TASKS.TASK_5
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC_6 SELECT '6';

-- Create child task n6
CREATE TASK CONTROL_DB.TASKS.TASK_7
    WAREHOUSE = COMPUTE_WH
AFTER CONTROL_DB.TASKS.TASK_6
AS INSERT INTO DEMO_DB.PUBLIC.EMP_BASIC_7 SELECT '7';



-- Correct Start procedure:

-- Suspend Root Task
ALTER TASK CONTROL_DB.TASKS.ROOT_TASK SUSPEND;
-- Resume Child Tasks
ALTER TASK CONTROL_DB.TASKS.TASK_2 RESUME;
ALTER TASK CONTROL_DB.TASKS.TASK_3 RESUME;
ALTER TASK CONTROL_DB.TASKS.TASK_4 RESUME;
ALTER TASK CONTROL_DB.TASKS.TASK_5 RESUME;
ALTER TASK CONTROL_DB.TASKS.TASK_6 RESUME;
ALTER TASK CONTROL_DB.TASKS.TASK_7 RESUME;
-- Resume Root Task
ALTER TASK ROOT_TASK RESUME;



-- Correct Suspend procedure:

-- Suspend Root Task
ALTER TASK CONTROL_DB.TASKS.ROOT_TASK SUSPEND;
-- Suspend Child Tasks
ALTER TASK CONTROL_DB.TASKS.TASK_2 SUSPEND;
ALTER TASK CONTROL_DB.TASKS.TASK_3 SUSPEND;
ALTER TASK CONTROL_DB.TASKS.TASK_4 SUSPEND;
ALTER TASK CONTROL_DB.TASKS.TASK_5 SUSPEND;
ALTER TASK CONTROL_DB.TASKS.TASK_6 SUSPEND;
ALTER TASK CONTROL_DB.TASKS.TASK_7 SUSPEND;








-- MODULE 23 --





-- M23 - Streams 








-- The Stream Object's purpose is to capture 
-- whatever changes are applied to a given table (CDC,
-- Change Data Capture). They are always created on 
-- top of existing tables.

-- It records data manipulation language (DML) 
-- changes made to tables, including INSERTS,
-- UPDATES, DELETES, as well as metadata about each change,
-- so that actions can be taken using the changed data.

-- Note that a stream itself does not contain any table data. 
-- A stream only stores the offset for the source table (3 metadata columns),
-- and returns CDC (Change Data Capture) records by leveraging the 
-- versioning history of the source table.

-- It's also possible to create multiple Stream objects on top 
-- of a same table (this is useful when we have/need to work with 
-- multiple "consumers" of the table's changes). The Stream Objects,
-- in this case, will be independent from each other.

-- Streams don't last forever; they expire after 14 days, by default.
-- This can be checked with the "SHOW STREAMS" command, in the column
-- "MAX_DATA_ENTENSION_TIME_IN_DAYS". This can also be checked with
-- "DESCRIBE STREAM <stream_name>". The "STALE_AFTER" column shows the 
-- prediction of when the given Stream will expire.

-- Whenever a Stream Object's "change record" is used, it 
-- is consumed, and ceases to exist. You cannot consume only 
-- "part" of a Stream; even if you use only a part of the records/changes 
-- captured in a Stream in a DML operation, the whole Stream, with all of 
-- its records/data captures, will be consumed. When a Stream is consumed, 
-- its offset is advanced.

-- "Consumer Tables" are tables that consume the changes stored in Stream 
-- Objects. A given Stream Object can only be consumed by a single Consumer 
-- Table, as its data will cease to exist after being consumed. A "Consumer
-- Table" can be the same table where you are applying changes, or another table
-- entirely.

-- An alternative to Streams is the CHANGES clause, seen below.

-- The best thing we can do, with Streams, is combine them with Tasks to 
-- create custom ETL workflows, to consume their data automatically



-- There are two kinds of Stream object:


    -- 1) Standard - Captures INSERTS, UPDATES AND DELETES

    -- 2) Append-only - Captures only INSERTS.






-- Example Syntax:



-- Create a table to store the names and fees paid by members of a gym 
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.MEMBERS_DEV (
    ID NUMBER(8) NOT NULL,
    NAME VARCHAR(255) DEFAULT NULL,
    FEE NUMBER(3) NULL
);

-- Create a Standard Stream Object to track changes to members table
CREATE OR REPLACE STREAM CONTROL_DB.STREAMS.MEMBER_CHECK ON TABLE DEMO_DB.PUBLIC.MEMBERS_DEV;

-- Insert data (changes) into members table
INSERT INTO DEMO_DB.PUBLIC.MEMBERS_DEV (ID, NAME, FEE)
VALUES 
(1, 'Joe', 0),
(2, 'Jane', 0),
(3, 'George', 0),
(4, 'Betty', 0),
(5, 'Sally', 0);

-- Check Stream Object's data captures:
SELECT * FROM CONTROL_DB.STREAMS.MEMBER_CHECK;

-- Output Format:
ID	NAME	FEE	        METADATA$ACTION	        METADATA$ISUPDATE	    METADATA$ROW_ID
1	Joe	    0	           INSERT	                    FALSE	        26ebaca5271316a90083471aa845abd60240f5e2
2	Jane	0	           INSERT	                    FALSE	        56900cf9df958e162b3ade459692317ca6fa2ab0
3	George	0	           INSERT	                    FALSE	        da44edeea3fd94766c61fd561c5d583dc84c3d34
4	Betty	0	           INSERT	                    FALSE	        f0a56bf02e41f27e1cf35332081807639e89ea49
5	Sally	0	           INSERT	                    FALSE	        c76ab7e17d8f1c8693f039e3e1712da80df7f727

-- Create additional table, where we'll insert the Stream's "records" (data captures of the records that were changed/inserted)
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.MEMBERS_PROD (
    ID NUMBER(8) NOT NULL,
    NAME VARCHAR(255) DEFAULT NULL,
    FEE NUMBER(3) NULL
);

-- Consume Stream Data (records in the Stream Object will cease to exist), applying changes to a Prod Table
INSERT INTO DEMO_DB.PUBLIC.MEMBERS_PROD(id, name, fee) 
SELECT ID, NAME, FEE 
FROM CONTROL_DB.STREAMS.MEMBER_CHECK;

-- Our Streams will always, by default, point to the most recent offset, but we can create a Stream positioned at 
-- a different offset (time), with the Time Travel syntax.
CREATE STREAM CONTROL_DB.STREAMS.MEMBER_CHECK ON TABLE DEMO_DB.PUBLIC.EMP_BASIC BEFORE (TIMESTAMP => TO_TIMESTAMP(40*365*86400));
CREATE STREAM CONTROL_DB.STREAMS.MEMBER_CHECK ON TABLE DEMO_DB.PUBLIC.EMP_BASIC BEFORE (offset=> 60*5);
CREATE STREAM CONTROL_DB.STREAMS.MEMBER_CHECK ON TABLE DEMO_DB.PUBLIC.EMP_BASIC BEFORE (statement => <query_id>);

-- Create Append-only Stream on source table (will capture only INSERT operations on table. Update and Delete-related operations won't be captured)
CREATE OR REPLACE STREAM CONTROL_DB.STREAMS.MEMBERS_CHECK_APPEND_ONLY ON TABLE DEMO_DB.PUBLIC.MEMBERS_DEV
APPEND_ONLY=TRUE;









-- The Changes Clause 







-- The CHANGES clause has a similar purpose to the
-- Stream Object, but with three important differences:

--     1) Records/changes captured by it are not consumed
--        when they are used. They will stay active, even if you 
--        use them.

--     2) Unlike the Stream Object, the CHANGES clause is not an 
--        object, and is used together with your SELECT statements.

--     3) To use it, we need to alter our tables with the option
--        CHANGE_TRACKING=TRUE




-- Example Syntax:





-- To use the CHANGES clause, to track changes, this property value is needed
ALTER TABLE DEMO_DB.PUBLIC.EMP_BASIC
    SET CHANGE_TRACKING=TRUE;

-- How to use the CHANGES clause, in our SELECT statements (with "offset", see changes up to x amount of minutes, in the past)
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC
CHANGES(information => default)
AT (OFFSET => -0.5*60);

-- How to use the CHANGES clause, in our SELECT statements (with "timestamp", see changes up to that timestamp, in the past)
SELECT * 
FROM DEMO_DB.PUBLIC.EMP_BASIC
CHANGES(information => default)
AT(TIMESTAMP => <your_timestamp>);

-- Using the CHANGES clause with "append_only", we return only the changes of type INSERT that happened up to that timestamp, in the past.
SELECT * FROM SALES_RAW 
CHANGES(information => append_only)
AT(timestamp => 'your-timestamp'::timestamp_tz);








-- Example of Streams combined with tasks - 
-- SCD (Slowly Changing Dimensions) Type 1 (each "entry"
-- has multiple records assigned to it, depending on the number of times 
-- it has been modified, also with the date of each change)

-- 
-- The line that makes everything work is "WHEN SYSTEM%STREAM_HAS_DATA('<stream_name>')"

-- OBS: Updates will produce 2 records, "DELETE" AND "INSERT".

-- Code:

-- Create Source Table
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.SOURCE_TABLE (
    ID INT,
    NAME STRING
);

-- Create Standard Stream
CREATE OR REPLACE STREAM CONTROL_DB.STREAMS.EXAMPLE_STREAM
ON TABLE DEMO_DB.PUBLIC.SOURCE_TABLE;

-- Create consumer/target table 
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.TARGET_TABLE (
    ID INT,
    NAME STRING,
    STREAM_TYPE STRING DEFAULT NULL,
    REC_VERSION NUMBER DEFAULT 0,
    REC_DATE TIMESTAMP_LTZ
);

-- Create/update Task (initially suspended)
CREATE TASK CONTROL_DB.TASKS.EXAMPLE_TASK
    WAREHOUSE=COMPUTE_WH
    SCHEDULE='1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('CONTROL_DB.STREAMS.EXAMPLE_STREAM')
AS 
MERGE INTO DEMO_DB.PUBLIC.TARGET_TABLE AS T
USING CONTROL_DB.STREAMS.EXAMPLE_STREAM AS S 
ON T.ID=S.ID AND (METADATA$ACTION='DELETE')
WHEN MATCHED AND METADATA$ISUPDATE='FALSE' THEN 
UPDATE SET REC_VERSION=9999, STREAM_TYPE='DELETE'
WHEN MATCHED AND METADATA$ISUPDATE='TRUE' THEN
UPDATE SET REC_VERSION=REC_VERSION - 1
WHEN NOT MATCHED THEN INSERT (ID, NAME, STREAM_TYPE, REC_VERSION, REC_DATE)
VALUES (
    S.ID, S.NAME, METADATA$ACTION, 0, CURRENT_TIMESTAMP()
);

-- Start Task 
ALTER TASK CONTROL_DB.TASKS.EXAMPLE_TASK RESUME;

-- Insert 3 rows into Source Table
INSERT INTO DEMO_DB.PUBLIC.SOURCE_TABLE VALUES (0, 'charlie brown');
INSERT INTO DEMO_DB.PUBLIC.SOURCE_TABLE VALUES (1, 'lucy');
INSERT INTO DEMO_DB.PUBLIC.SOURCE_TABLE VALUES (2, 'linus');

-- Insert 3 more rows, but with different values
INSERT INTO DEMO_DB.PUBLIC.SOURCE_TABLE VALUES (3, 'charlie brown');
INSERT INTO DEMO_DB.PUBLIC.SOURCE_TABLE VALUES (4, 'lucy lucy');
INSERT INTO DEMO_DB.PUBLIC.SOURCE_TABLE VALUES (5, 'linus linus');

-- View results
SELECT * FROM DEMO_DB.PUBLIC.TARGET_TABLE;

-- Target Table output:
ID	NAME	           STREAM_TYPE	REC_VERSION	      REC_DATE
2	linus	              INSERT	     0	    2023-08-23 11:24:44.527 -0700
3	charlie brown	      INSERT	     0	    2023-08-23 11:24:44.527 -0700
5	linus linus	          INSERT	     0	    2023-08-23 11:24:44.527 -0700
4	lucy lucy	          INSERT	     0	    2023-08-23 11:24:44.527 -0700
0	charlie brown	      INSERT	     0	    2023-08-23 11:24:44.527 -0700
1	lucy	              INSERT	     0	    2023-08-23 11:24:44.527 -0700


-- View Tasks details 
SHOW TASKS;

-- View Task execution history
SELECT * FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.TASK_HISTORY());









-- MODULE 24 --





-- M24 - Continuous data load, with Streams and Tasks






-- We will leverage some of the Snowflake 
-- features to load data continuously.


-- We will use:

-- 1) Snowpipe

-- 2) Streams

-- 3) Tasks




-- The steps to be followed are:



-- 0) Before you do anything, you should have your files split in smaller chunks, for easier copying and use.

-- 1) Have your data loaded in AWS S3


-- 1.5) List the files in your bucket, in S3, with the AWS CLI:

aws s3 ls 

-- 1.6) If you wish to create a new folder inside your bucket, in S3, use this command:

aws s3api put-object --bucket <bucket_name> --key myfolder/

-- 2) Set up a Snowpipe, and integrate it with your bucket (SQS)

-- 3) Set up a Task to Auto-refresh the Pipe, for error cases while loading the files. (this Task will run every minute, to refresh the Pipe)

-- 4) Create a Staging Table, Transient Type, that will receive the data from the files uploaded to our buckets

-- 5) Create a Final Table, permanent Type, that will receive incremental data

-- 6) Create a Stream, Stream X, that will watch the Staging Table and capture its changes

-- 7) To end the flow, we create a Task that will automatically consume the rows (data captures) that appear in Stream X, use them to 
--    insert rows/apply changes to the Final Table.




-- So, the items needed are:

-- A) 2 Tables, Staging and Final

-- B) A Stream (or multiple streams, for multiple consumer tables), placed on top of the Staging Table

-- C) A Snowpipe, to copy the data from AWS S3 into our Staging Table

-- D) 2 tasks, one for refreshing the pipe, and another for consuming the data captures appearing in the Stream, to apply them in the Final Table.s




-- Example Code:





-- Beforehand, create Stage, Integration and File Format Objects.
-- Then, Begin by creating the Staging Table
CREATE TRANSIENT TABLE DEMO_DB.PUBLIC.STAGING (
    C_ID STRING,
    NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    ZIP STRING
);

-- Copy Table Structure
CREATE TABLE DEMO_DB.PUBLIC.FINAL LIKE DEMO_DB.PUBLIC.STAGING;

--- Create Snowpipe to continuously load data (capture changes/data uploaded to S3)
CREATE OR REPLACE PIPE CONTROL_DB.PIPES.SOME_PIPE
    AUTO_INGEST=TRUE
AS COPY INTO DEMO_DB.PUBLIC.STAGING
    FROM @CONTROL_DB.STAGES.MY_EXT_STAGE
    ON_ERROR='CONTINUE' -- very important
    FILE_FORMAT=(
        FORMAT_NAME=CONTROL_DB.FILE_FORMATS.CSV_FORMAT
    );

-- Check Pipe Status
SELECT SYSTEM$PIPE_STATUS('CONTROL_DB.PIPES.SOME_PIPE');

-- Refresh pipe manually, so new files can be copied into Staging Table
ALTER PIPE SNOWPIPE REFRESH;

-- Validate Pipe load, in the case of errors
SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME=>'CONTROL_DB.PIPES.SOME_PIPE',
        start_time=>TO_DATE(CURRENT_TIMESTAMP())
    )
);

SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME=>'CONTROL_DB.PIPES.SOME_PIPE'
    )
);

-- Create Stream on top of Staging Table
CREATE OR REPLACE STREAM CONTROL_DB.STREAMS.STREAM_X
ON TABLE DEMO_DB.PUBLIC.STAGING;

-- Create Task to consume Stream data, insert it into Final Table
CREATE OR REPLACE TASK CONTROL_DB.TASKS.S3_TASK 
    WAREHOUSE=COMPUTE_WH
    SCHEDULE='1 MINUTE'
WHEN 
    SYSTEM$STREAM_HAS_DATA('CONTROL_DB.STREAMS.STREAM_X')
AS 
INSERT INTO DEMO_DB.PUBLIC.FINAL
SELECT * FROM CONTROL_DB.STREAMS.STREAM_X;

-- Start Task
ALTER TASK CONTROL_DB.TASKS.S3_TASK RESUME;














-- MODULE 25 --







-- M25 - Materialized Views






-- MVs are database objects that contain the
-- result set of a given query.

-- They can be created on top of commonly executed
-- complex queries, to make them readily available 
-- and more performant.

-- Besides being used for common tables, we can
-- create them on top of external tables, to improve 
-- their query performance.

-- They store the results of a query definition,
-- and then periodically refresh these results.

-- Unlike normal Views, MVs are not "windows"
-- into your tables.

-- Instead, MVs are separate objects that hold 
-- query result data, data which is periodically 
-- refreshed.

-- Snowflake's Materialized Views are also
-- different from conventional MVs, seen in other 
-- database systems.

-- This type of view is not recommended for use-cases 
-- where you frequently update tables, as the MV update 
-- costs will quickly pile up. We can see this cost in the 
-- "Account" tab, as "MATERIALIZED_VIEW_MAINTENANCE",
-- cost which is derived from the "MATERIALIZED_VIEW_REFRESH_HISTORY" function/view.
-- Whenever the main table gets changed, there will be a cost to refresh your
-- corresponding Materialized View.

-- If our main table is huge and gets updated daily/on a two-day basis,
-- MVs are not worth using.

-- Materialized views impact your costs for both storage and compute resources. 
-- Materialized views use storage to store your computed results
-- and also use compute to keep your materialized views up to date.


-- Snowflake MVs also have some query limitations. They cannot query:

-- A materialized view.

-- A non-materialized view.

-- A UDTF (user-defined table function).

-- A materialized view cannot include:

-- UDFs (this limitation applies to all types of user-defined functions, including external functions).

-- Window functions.

-- HAVING clauses.

-- ORDER BY clause.

-- LIMIT clause.

-- GROUP BY keys that are not within the SELECT list. All GROUP BY keys in a materialized view must be part of the SELECT list.

-- GROUP BY GROUPING SETS.

-- GROUP BY ROLLUP.

-- GROUP BY CUBE.

-- Nesting of subqueries within a materialized view.









-- Some of the problems seen in MVs of other database 
-- systems:

-- 1) The periodical refreshes can lead to inconsistent/out-of-date
-- results when you access them

-- 2) DML operations, like INSERTs, UPDATEs and DELETEs, all 
--    suffer from slowdown whenever MVs are used/created (because 
--    the MV always needs to be updated along with the main table)



--  Some of the advantages/quirks of Snowflake MVs:

--  1) Optimal speed is always ensured (thanks to its caching)

--  2) Query results are always current and consistent
--     with main table

--  3) Are easy to use, thanks to the maintenance service
--     that constantly runs in the background (when a base table 
--     is changed, the background service automatically updates our 
--     MV to reflect the changes)

--  4) Can be very pricey (they are additional objects, with their own storage costs)





-- The "refreshing"/maintenance service is attached to our main table,
-- and will frequently compare the MV with it.




-- Example Syntax:


-- Create Materialized View
CREATE OR REPLACE MATERIALIZED VIEW DEMO_DB.PUBLIC.EMP_BASIC_MV
AS 
SELECT * FROM DEMO_DB.PUBLIC.EMP_BASIC

-- "Behind by" column - shows us if the MV is already synced with the main table.
SHOW MATERIALIZED VIEWS;

-- Check the refreshing service attached to our main tables - entries will be present only if our main tables have been changed
SELECT * FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY());

-- output:
created_on	                            name	            reserved	    database_name	schema_name	    cluster_by	rows	bytes	source_database_name	source_schema_name	source_table_name	refreshed_on	compacted_on	                                        owner	    invalid	invalid_reason	behind_by	comment	text	                                                                            is_secure	automatic_clustering	owner_role_type
2023-08-24 07:02:17.453 -0700	CALL_CENTER_M_VIEW		                    DEMO_DB	            PUBLIC		             60	    19,456	    DEMO_DB	                    PUBLIC	        CALL_CENTER	    2023-08-24      07:01:56.331 -0700	2023-08-24 07:01:56.331 -0700	ACCOUNTADMIN	false		                0s		        CREATE OR REPLACE MATERIALIZED VIEW CALL_CENTER_M_VIEW AS  SELECT * FROM CALL_CENTER;	false	            OFF	            ROLE



-- Materialized Views are a nice feature. However,
-- We can create a quasi-MV with other Snowflake features,
-- like Streams and Tasks, without using MVs and generating 
-- excessive costs. This can be achieved mainly with Tasks,
-- which we'll set to refresh our tables on different schedules (not 
-- immediately, like the MVs do, but still regularly, like every two 
-- days). The changes to our table, in turn, can be recognized by a Stream Object.


-- To do that, the steps to be followed are:



-- 1) Create a Source Table, Permanent, the table which will be used to create the fake MV

-- 2) Create a Stream on top of that Source Table, to track changes applied to it

-- 3) Create a Task, with a custom schedule (ex: every two days), which will have the condition
--  'SYSTEM$STREAM_HAS_DATA()', that must be satisfied to have the Stream be consumed by its SQL statement

-- 4) Inside the Task, the "MERGE" statement will be used. We must use it to avoid duplicates appearing in 
--   our fake MV table.




--  Obviously, this setup shown above is not the same as the one used by real Materialized Views, but it 
--  can generally satisfy our business needs. The advantage in relation to MVs is that we can control how
--  often the refreshes will run, scheduling them according to our needs.











-- MODULE 26 --






-- M26 - Dynamic Tables 






-- Before understanding the Dynamic Table Object/Concept,
-- we should review the difference between Common Views 
-- and Materialized Views


-- Common Views:

-- 1) Objects that store query logic, but don't have their own storage (and no costs)

-- 2) No actual caching of data (result sets are not stored)

-- 3) As no data is cached, queries always run anew, and end up not using 
--    any of Snowflake's caching capabilities (additional compute costs, increased wait time during queries)

-- 4) As queries are run "anew", Common Views always end up "refreshed"
--    immediately, automatically, meaning we always get the most up-to-date
--    data.



-- Materialized Views:

-- 1) Separate Objects, with their own storage (with their own cost)

-- 2) Actual caching of data (result sets are stored, they persist)

-- 3) Queries take advantage of the cached data (reduced compute costs, increased query speed)

-- 4) MVs are refreshed automatically, by a background service, but the 
--    process is not instantaneous, and we have no control over it (interval between refreshes)

-- 5) Complex queries (with JOINS and complex aggregates) are not supported.





-- With Dynamic Tables, the objective is to overcome the limitations seen in Views and MVs,
-- allowing us to:


-- 1) Write complex queries, on top of multiple tables (JOINS)

-- 2) Persist the query results (caching of result sets, increased speed)

-- 3) Set the refresh schedule as we want (daily, weekly, every two days, every 12 hours, etc.)



-- However, Dynamic Tables also have some unique traits/quirks:

-- A) You can't run DML statements directly on top of Dynamic Tables (INSERT, UPDATE, DELETE). The only possible operation is "SELECT".

-- B) Under the hood, Dynamic Tables use Stream Objects to track the changes to your main/source tables.

-- C) As they are materialized query results (table derived from the query we ran on top of the source table/tables), 
--    maintained by Snowflake, they also have storage costs associated to them.

-- D) Some SQL features are not supported by them, such as Stored Procedures, Tasks, UDFs, and External Functions.

-- E) You can only define refreshing intervals by "X <time-unit>", as shown below. You cannot use CRON expressions (ex: "refresh at this time of day" - this is 
-- not possible).

-- F) Dynamic Tables can have two kind of refreshes occuring inside of them: Incremental Refreshes and Full Refreshes. Full 
--    Refreshes must always be avoided, as they involve the refreshing of the entire Dynamic Table, instead of only a part of it (incremental).
--    Full Refreshes happen when we use "UNION" in the statement that creates our Dynamic Table. Dynamic Tables currently only support INNER JOINs,
--    OUTER JOINS and CROSS JOINs for incremental refreshes. There is no point in using Dynamic Tables if our refreshes are always being Full
--    Refreshes, because there will be no speed improvement with the feature.




-- Example Syntax:



-- Create Dynamic Table (we must define the "TARGET_LAG" between refreshes)
CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.LINEITEM_DYNAMIC
  TARGET_LAG = '20 minutes'  ---  Only Dynamic Tables have this option - table will be refreshed every 20 minutes. The minimum interval is 1 minute. We can also set seconds, hours and days
  WAREHOUSE = compute_wh
  AS
  SELECT
  l_returnflag,
  l_linestatus,
  sum(l_quantity) AS sum_qty,
  sum(l_extendedprice) AS sum_base_price,
  sum(l_extendedprice * (
1
 - l_discount)) AS sum_disc_price,
  sum(l_extendedprice * (
1
 - l_discount) * (
1
 + l_tax)) AS sum_charge,
  avg(l_quantity) AS avg_qty,
  avg(l_extendedprice) AS avg_price,
  avg(l_discount) AS avg_disc,
  count(*) AS count_order
FROM DEMO_DB.PUBLIC.LINEITEM -- Base table from which you want to create the Dynamic Table
WHERE l_shipdate <= DATE '1998-12-01'
GROUP BY  l_returnflag,  l_linestatus
ORDER BY  l_returnflag,  l_linestatus; -- Order by Clauses are possible with Dynamic Tables, as they are not Materialized Views.

-- If we try to query that Dynamic Table, we will receive an error - this is because the table won't have been created yet (TARGET_LAG of 20 minutes)
SELECT * FROM DEMO_DB.PUBLIC.LINEITEM_DYNAMIC;

-- Output:
"Dynamic table 'DEMO_DB.PUBLIC.LINEITEM_DYNAMIC' is not initialized.
Please run a manual refresh or wait for a manual refresh before querying"

-- We can force that manual refresh, with this code - this refresh will inform us of the timestamp of the refresh, and also that 4 rows were inserted (extracted from 
-- the main table)
ALTER DYNAMIC TABLE DEMO_DB.PUBLIC.LINEITEM_DYNAMIC REFRESH;

-- Check existence of table/status of data inside of Dynamic Table
SELECT * FROM DEMO_DB.PUBLIC.LINEITEM_DYNAMIC;

-- Insert some content in source table. - When the Dynamic Table gets refreshed, these changes will be reflected on it
INSERT INTO DEMO_DB.PUBLIC.LINEITEM
SELECT * FROM DEMO_DB.PUBLIC.LINEITEM_DUMMY;

-- Check status of the data inside of the Dynamic Table - will only get updated after 20 minutes, as defined in the "TARGET_LAG" option
SELECT * FROM DEMO_DB.PUBLIC.LINEITEM_DYNAMIC;








-- Dynamic Table usage example (no-dynamic-table vs with-dynamic-table):




-- In the Traditional Scenario, without Dynamic Table, we'll have:


-- A) Two Staging Tables, Transient, X and Y

-- B) A third Table, Intermediate Table Z, which will be created by the JOIN between Tables X and Y

-- C) A fourth, final Table, FINAL, on top of which we will run a MERGE statement, merging the Z table (joined data of X and Y) with it.

-- D) Two Streams, one for TABLE_X and other for TABLE_Y

-- E) Three Tasks, one to MERGE TABLE_X and TABLE_Y into the TABLE_Z, another for clearing/consuming the streams, and another for the MERGE of the TABLE_Z into the FINAL table.


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Code (no Dynamic Table):


-- Create Staging Table X - Truncate and Load, always
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.TABLE_X
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- Create Staging Table Y - Truncate and Load - always
CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.TABLE_Y
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS;

-- Create Table Z, intermediate Table, based on joined data from 2 staging tables.
-- This intermediate table Z will be "Truncate and Load" (Drop and Recreate), and that's why we write "CREATE OR REPLACE" in the statement
CREATE OR REPLACE TRANSIENT TABLE 
DEMO_DB.PUBLIC.TABLE_Z
AS 
SELECT
A.C_CUSTKEY,
A.C_NAME,
A.C_ADDRESS,
B.O_ORDERSTATUS,
B.O_ORDERPRIORITY 
FROM DEMO_DB.PUBLIC.TABLE_X AS A 
INNER JOIN DEMO_DB.PUBLIC.TABLE_Y AS B 
ON A.C_CUSTKEY = B.C_CUSTKEY;

-- Create Final Table
CREATE TABLE FINAL (
    C_CUSTKEY STRING,
    C_NAME STRING,
    C.ADDRESS STRING,
    O_ORDERSTATUS STRING,
    O_ORDERPRIORITY STRING
);

-- Merge Intermediate Table Z into Final Table
MERGE INTO DEMO_DB.PUBLIC.FINAL AS TARGET
USING
DEMO_DB.PUBLIC.TABLE_Z AS STAGING
ON STAGING.C_CUSTKEY = TARGET.C_CUSTKEY
    WHEN MATCHED THEN UPDATE SET
    TARGET.C_NAME = STAGING.C_NAME
    TARGET.C_ADDRESS = STAGING.C_ADDRESS
    TARGET.O_ORDERSTATUS = STAGING.O_ORDERSTATUS
    TARGET.O_ORDERPRIORITY = STAGING.O_ORDERPRIORITY
WHEN NOT MATCHED THEN INSERT (STAGING.C_CUSTKEY, STAGING.C_NAME,
STAGING.C_ADDRESS, STAGING.O_ORDERSTATUS, STAGING.O_ORDERPRIORITY)
VALUES (
STAGING.C_CUSTKEY,
STAGING.C_ADDRESS,
STAGING.O_ORDERSTATUS,
STAGING.O_ORDERPRIORITY
);


-- The above code would work, but we would need to Create Tasks and Streams to automate the load process into the FINAL Table, like this:



-- Create Streams on Tables X and Y
CREATE OR REPLACE STREAM CONTROL_DB.STREAMS.STREAM_X
ON TABLE DEMO_DB.PUBLIC.TABLE_X;
CREATE OR REPLACE STREAM CONTROL_DB.STREAMS.STREAM_Y
ON TABLE DEMO_DB.PUBLIC.TABLE_Y;


-- Create Task to recreate Intermediate Table Z, at a certain interval, whenever there is data captured in the Streams. A child task is also needed, to clear the streams after the recreating of the table.
CREATE OR REPLACE TASK CONTROL_DB.TASKS.EXAMPLE_TASK
    WAREHOUSE=COMPUTE_WH
    SCHEDULE='1 HOUR'
WHEN 
    SYSTEM$STREAM_HAS_DATA('CONTROL_DB.STREAMS.STREAM_X') OR
    SYSTEM$STREAM_HAS_DATA('CONTROL_DB.STREAMS.STREAM_Y')
AS 
    CREATE OR REPLACE TRANSIENT TABLE 
    DEMO_DB.PUBLIC.TABLE_Z
    AS 
    SELECT
    A.C_CUSTKEY,
    A.C_NAME,
    A.C_ADDRESS,
    B.O_ORDERSTATUS,
    B.O_ORDERPRIORITY 
    FROM DEMO_DB.PUBLIC.TABLE_X AS A 
    INNER JOIN DEMO_DB.PUBLIC.TABLE_Y AS B 
    ON A.C_CUSTKEY = B.C_CUSTKEY;

-- Create Child Task of previous task, to clear Streams after TABLE_Z is recreated
CREATE OR REPLACE TASK CONTROL_DB.TASKS.CHILD_EXAMPLE_TASK
     WAREHOUSE=COMPUTE_WH
AFTER CONTROL_DB.TASKS.EXAMPLE_TASK
AS
CREATE OR REPLACE TEMPORARY TABLE DEMO_DB.PUBLIC.RESET_TABLE AS
SELECT * FROM CONTROL_DB.STREAMS.STREAM_X AS X 
INNER JOIN CONTROL_DB.STREAMS.STREAM_Y AS Y
ON X.C_CUSTKEY = Y.C_CUSTKEY;

-- Create Task to MERGE data from TABLE_Z into FINAL Table, on a regular basis
CREATE OR REPLACE TASK CONTROL_DB.TASKS.EXAMPLE_TASK_2
    WAREHOUSE='compute_wh'
    SCHEDULE='12 HOURS'
AS 
MERGE INTO DEMO_DB.PUBLIC.FINAL AS TARGET
USING
DEMO_DB.PUBLIC.TABLE_Z AS STAGING
ON STAGING.C_CUSTKEY = TARGET.C_CUSTKEY
    WHEN MATCHED THEN UPDATE SET
    TARGET.C_NAME = STAGING.C_NAME
    TARGET.C_ADDRESS = STAGING.C_ADDRESS
    TARGET.O_ORDERSTATUS = STAGING.O_ORDERSTATUS
    TARGET.O_ORDERPRIORITY = STAGING.O_ORDERPRIORITY
WHEN NOT MATCHED THEN INSERT (STAGING.C_CUSTKEY, STAGING.C_NAME,
STAGING.C_ADDRESS, STAGING.O_ORDERSTATUS, STAGING.O_ORDERPRIORITY)
VALUES (
STAGING.C_CUSTKEY,
STAGING.C_ADDRESS,
STAGING.O_ORDERSTATUS,
STAGING.O_ORDERPRIORITY
);


-- Disadvantages of this traditional approach:

-- 1) We are responsible for the code and for the scheduling, more 
--    room for mistakes (no managed service).
   
-- 2) Harder to maintain



-- Advantages of this traditional approach:

-- 1) We have more freedom, and more control over the scheduling
--    and the operations we want to run on our tables (INSERT,
--    DELETE, UPDATE).

-- 2) With this approach, SCD Type 1 and 2 are easier to build
--    (useful if we want to keep previous versions of records, in our 
--     table)


-- ////////////////////////////////////////////////////////////




-- With the usage of a Dynamic Table, we'll have:

-- A) The two Staging tables, TABLE_X and TABLE_Y

-- B) The Dynamic Table, EXAMPLE_DYNAMIC, and nothing more



-- In this scenario, we don't have "CREATE OR REPLACE" with the Staging tables,
-- because there will be no "Truncate and Load"; the data in the Staging tables will 
-- always stay inside them, and will be replicated in the Dynamic Table.

-- Also, in this scenario, there is a great simplification, because we don't have 
-- to create the Intermediate Table TABLE_Z, nor MERGE the data from the intermediate table 
-- into the FINAL table, nor create Tasks to orchestrate the creation/recreation of the 
-- intermediate table and the merging of its data into the FINAL table


-- Code (with Dynamic Tables; simpler to write):



-- Create Staging Table X - no Truncate and Load
CREATE TRANSIENT TABLE DEMO_DB.PUBLIC.TABLE_X
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- Create Staging Table Y - no Truncate and Load
CREATE TRANSIENT TABLE DEMO_DB.PUBLIC.TABLE_Y
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS;

-- Create Dynamic Table - it will guarantee the persist of the updates, inserts and deletes, refreshed by the specified interval
CREATE OR REPLACE DYNAMIC TABLE DEMO_DB.PUBLIC.EXAMPLE_DYNAMIC
    TARGET_LAG='12 HOURS'
    WAREHOUSE=compute_wh
    AS
    SELECT
    X.C_CUSTKEY,
    X.C_CUSTNAME,
    X.C_ADDRESS,
    Y.O_ORDERSTATUS,
    Y.O_ORDERPRIORITY,
    Y.o_orderkey
    FROM DEMO_DB.PUBLIC.TABLE_X AS X 
    INNER JOIN 
    DEMO_DB.PUBLIC.TABLE_Y AS Y
    ON A.C_CUSTKEY = B.C_CUSTKEY;



-- Disadvantages of this Dynamic Table approach:

-- 1) Less control
   
-- 2) We can't run DML operations directly on the Dynamic Table

-- 3) SCD Type 2 is possible, but harder to implement


-- Advantages of this traditional approach:

-- 1) Data will be auto-refreshed, we don't need to worry about 
-- scheduling refreshes and tasks

-- 2) The storage of data and operations are all handled by 
--    Snowflake






-- MODULE 27 -- 






-- M27 - Data Masking -- 





-- With it, we can hide entire values or parts of values 
-- of our columns.


-- Like this format:



-- NAME        ADDRESS         EMP_ID      ZIP_CODE      SALARY 
-- RAJESH      ASDASD          12313        1212**       *****



-- Of course we can get a similar result with Views,
-- we only need to use them with UDFs (functions), so
-- that these functions end up formatting the values. 
-- Even so, Snowflake Data Masking has some advantages, when 
-- compared to them.

-- Data Masks are called "Masking Policies", and must 
-- be applied to columns to have any effects on their
-- values.

-- The Masks hide data according to the Roles in your 
-- system.

-- To DROP/recreate a given Masking Policy, first you need to unset
-- it from all columns affected by it. If you don't want to recreate a 
-- policy (because you'd need to reapply it to all the columns), you can
-- alter only its body, with a special syntax.



-- Example Syntax:



-- Create Data Mask (created, but still not applied to a column) - Full mask (all values of the column are masked)
CREATE OR REPLACE MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY
    AS (VAL VARCHAR) RETURNS VARCHAR ->
        CASE
            WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN VAL
            ELSE '##-###-##'
            END;

-- Create Data Mask - Partial Value, Full Mask
CREATE OR REPLACE MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY
    AS (VAL VARCHAR) RETURNS VARCHAR ->
        CASE
            WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN VAL
            ELSE SUBSTRING(VAL,1,2) -- show only 2 first characters of phones
            END;

-- Create Data Mask - Full value, Partial Mask (only a few of the values of the column are masked)
CREATE OR REPLACE MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY_PARTIAL
AS 
(VAL STRING) RETURNS STRING -> 
    CASE 
        WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN 
        CASE WHEN VAL='25-247-272-2878' THEN 'ABDEFGH' ELSE VAL -- Only rows with this value in this columns will have the col's value redacted.
    END 
ELSE '*******'
END;

-- Create a table while applying Masking Policy to a column
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.EMP_BASIC (
    FIRST_NAME STRING,
    PHONE MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY
);

-- Apply Masking Policy on a specific column
ALTER TABLE IF EXISTS DEMO_DB.PUBLIC.CUSTOMERS MODIFY COLUMN PHONE
SET MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY


-- To DROP/recreate a given Masking Policy, first you need to unset it from all columns affected by it
ALTER TABLE IF EXISTS DEMO_DB.PUBLIC.CUSTOMERS MODIFY COLUMN PHONE
UNSET MASKING POLICY;

-- Drop a Masking Policy
DROP MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY;

-- Alter the Masking Policy's body, without recreating it:
ALTER MASKING POLICY CONTROL_DB.MASKING_POLICIES.PHONE_POLICY
SET BODY -> 
         CASE
            WHEN CURRENT_ROLE() IN ('ANALYST') THEN VAL
            ELSE 'redacted' -- show 'redacted' in the column
            END;




-- We can have a similar effect, of masking, by creating and sharing a Secure View, like this:


-- Create UDF to format phone values 
CREATE OR REPLACE FUNCTION "REDACT_PHONE"("PHONE" STRING)
RETURNS STRING
LANGUAGE SQL
AS '
SELECT
CASE 
    WHEN CURRENT_ROLE() IN (''ANALYST_FULL'',''ACCOUNTADMIN'') THEN "##-###-##"
    ELSE PHONE
END AS PHONE
  ';
  
-- Create Secure View with redacted phones
CREATE OR REPLACE SECURE VIEW DEMO_DB.PUBLIC.MASKED_PHONE_EMP_BASIC
AS 
SELECT 
FIRST_NAME,
LAST_NAME,
REDACT_PHONE(PHONE) AS REDACTED_PHONE,
ZIP
FROM DEMO_DB.PUBLIC.EMP_BASIC;



-- The advantage of views is that you can define masking policies based
-- on multiple columns, as parameters (as we see in the example Syntax down below). An
-- example of this kind of mask would be a condition of "mask all values of the 'address'
-- column of rows whose name column's value is 'John'".





-- However, views also have problems of their own, such as:


-- 1) If we have 100 Tables, we have to create 100 views;
--    if we eventually want to change the masking of our view or 
--    mask more of its columns, we'll have to recreate potentially 
--    dozens of views.

-- 2) Each time we edit/recreate a view, we need to re-add GRANTs
--    and SELECTs on this view, to the roles that need to use it.
--    However, there is a way to avoid this, with the "COPY GRANTS"
--    clause, that should be used with the "CREATE OR REPLACE SECURE VIEW"
--    command (example seen below)

-- 3) If we use Views/Secure Views, we are choosing to forgo the 
--    caching features of Snowflake, generating additional costs 
--    and query times.

-- 4) We can end up with multiple Views for a same table.

-- 5) The owner of the View can manipulate the View's definition 
--    at will, removing any of the "masks"/UDFs that we used on it.

-- 6) The data-masking, in this case, will be "code-driven", vulnerable 
--    to edits.





-- Masking Policies, on the other hands, have many advantages:


-- 1) As they are Snowflake Objects, we can easily manage access
--    to them, so that only the appropriate roles can edit them (with GRANTS).

-- 2) If we mask a column's values entirely to a given role, that masking will also
--    speed up our queries, indirectly (because Snowflake will "know" that all the values 
--    in that column will be gibberish/redacted, so it will ignore it completely, not scan it 
--    at all).

-- 3) As they are objects, they can all be "stored" in a central place, like a Schema, like 
--    the schemas we should have in the "CONTROL_DB" database. Also, if we edit them, with the "body"
--    syntax, the changes are reflected in all columns affected by them.

-- 4) The data-masking will be "metadata-driven", much safer than code-driven protection.





-- If you must use Views/Secure Views to mask your data (complex masks, multiple parameters/columns to choose 
-- values to be masked), you can do so, but you should follow some best-use guidelines, as seen below.






-- Advanced View Masking Syntax Examples (multiple parameters/column conditions for masks):



-- First, define UDFs that will mask your data
CREATE OR REPLACE FUNCTION "DEATH_CODE_DATE_REDACT_FUNCTION"("DIAGNOSIS_CODE" VARCHAR(16777216), "SERVICE_DATE" DATE) -- 2 params accepted as value
RETURNS DATE
LANGUAGE SQL
AS '
SELECT
CASE WHEN CURRENT_ROLE() IN (''ANALYST'',''CONTRACTOR'',''ACCOUNTADMIN'') THEN
        CASE WHEN DIAGNOSIS_CODE IN (''G9382'',''O312'',''O3120'',''O3120X1'',''7681'',''39791'') THEN  SERVICE_DATE + UNIFORM(5, 14, RANDOM()) 
             ELSE SERVICE_DATE
             END
     ELSE SERVICE_DATE
END SERVICE_DATE
  ';

-- Afterwards, create a Secure View that uses those UDFs
CREATE OR REPLACE SECURE VIEW DEMO_DB.PUBLIC.EXAMPLE_SECURE_VIEW 
AS 
SELECT
PATIENT_NAME,
DOB,
DIAGNOSIS,
ADR_LINE_1,
ADR_LINE_2,
CITY,
ZIP,
STATE,
POS,
DEATH_CODE_DATE_REDACT_FUNCTION(DIAGNOSIS,SERVICE_START_DATE) SERVICE_START_DATE_REDACT, -- use UDF
SERVICE_START_DATE,
DEATH_CODE_DATE_REDACT_FUNCTION(DIAGNOSIS,SERVICE_END_DATE) SERVICE_END_DATE, -- use UDF
SERVICE_END_DATE,
PROVIDER_NAME
FROM DEMO_DB.PUBLIC.PATIENT;

-- Provide access to Secure View to all appropriate roles
GRANT SELECT ON VIEW DEMO_DB.PUBLIC.EXAMPLE_SECURE_VIEW TO ROLE ANALYST;


-- Recreate Secure View (edit/alter applied masking, for example) while 
-- keeping current GRANTS to roles, with the "COPY GRANTS" clause:
CREATE OR REPLACE SECURE VIEW DEMO_DB.PUBLIC.EXAMPLE_SECURE_VIEW COPY GRANTS -- the clause in question
AS 
SELECT
<expression_and_masks>,
<...>
FROM DEMO_DB.PUBLIC.PATIENT;












-- MODULE 28 --





-- M28 - Tagging -- 







-- This feature becomes extremely useful as your system grows; the more 
-- tables and schemas you have, the more useful it becomes (120+ databases, 300 tables, etc),
-- as it helps us with data discovery, with understanding how our data is distributed across our system.

-- Use-case: When categorization (Database-Schema-Table, folder-like structure) is not good enough,
-- then it is good to rely on tags, search by tags.

-- Warehouses, Databases, Schemas, Tables, all can be tagged.

-- We can also tag columns in our tables (when a tag is applied in a whole table,
-- all the columns receive the same tag name and value).

-- A same tag can have multiple values ('Red', 'Orange', 'Green', etc)

-- Each Object can have multiple tags assigned to itself, but each tag can only 
-- have a single value.

-- We can also pre-define what values are permitted, for a given tag. These values
-- must be defined at the moment of the tag's creation.

-- A common best practice is to create a role dedicated to the task of applying 
-- tags to your system's objects, like a "TAG_ADMIN" role. We can also create 
-- a database dedicated to this task, of creating tags, named "TAGS", with 
-- a schema of "GOVERNANCE", where all our tags may be put.

-- To use tagging correctly, you should have discipline: when creating new objects,
-- you should tag them accordingly.

-- Obs: When we create/modify something in the metadata layer of Snowflake,
--      like Tags, there is always some delay, the changes are never applied 
--      instantly.



-- To utiize tags, we have two steps:

-- 1) Applying tags

-- 2) Use tags with our queries, to have a better idea of "which data is where" in our system.




-- Example Syntax part one (first step, "Applying tags"):


-- Create a tag 
CREATE OR REPLACE TAG CONTROL_DB.TAGS.DB_DATA_SENSITIVITY;

-- Apply tag to a given object, while setting a value ('Red Data') to the tag
CREATE OR REPLACE DATABASE REVENUE WITH TAG (
    CONTROL_DB.TAGS.DB_DATA_SENSITIVITY = 'Red Data'
);
-- Apply tag to a given object, while setting a value ('Orange Data') to the tag
CREATE OR REPLACE DATABASE MARKETING WITH TAG (
    CONTROL_DB.TAGS.DB_DATA_SENSITIVITY = 'Orange Data'
);
-- Apply tag to a given object, while setting a value ('Green Data') to the tag
CREATE OR REPLACE DATABASE WEATHER WITH TAG (
    CONTROL_DB.TAGS.DB_DATA_SENSITIVITY = 'Green Data'
);

-- Alter value of a tag, after it has already been applied to an object (or if object has already been created)
ALTER DATABASE REVENUE 
SET TAG DEMO_DB.PUBLIC.DB_DATA_SENSITIVITY='Purple Data';

-- See the value of a given Tag, in a given Object (<tag_name>, <object_name>, <object_type>)
SELECT SYSTEM$GET_TAG(
    'TAG CONTROL_DB.TAGS.DB_DATA_SENSITIVITY', 'REVENUE', 'DATABASE'
);

-- View all of the tags created in our system (ACCOUNTADMIN role needed)
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
ORDER BY TAG_NAME, DOMAIN, OBJECT_ID;





-- Optional - Creation of Tag_ADMIN Role -- 




--Create TAG_ADMIN role
USE ROLE USERADMIN;
CREATE ROLE TAG_ADMIN;

-- Grant of "Tag Apply" privilege to TAG_ADMIN ROLE
USE ROLE ACCOUNTADMIN;
GRANT APPLY TAG ON ACCOUNT TO ROLE TAG_ADMIN;

GRANT IMPORTED PRIVILEGES 
ON DATABASE SNOWFLAKE TO ROLE TAG_ADMIN;

-- Grant needed Warehouse privileges to TAG_ADMIN ROLE
USE ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE TAG_ADMIN;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TAG_ADMIN;

-- Create TAG database
CREATE DATABASE TAGS;
CREATE SCHEMA TAGS.GOVERNANCE;

-- Grant Privileges on TAGS database to ROLE TAG_ADMIN
GRANT ALL PRIVILEGES ON DATABASE TAGS TO ROLE TAG_ADMIN;
GRANT USAGE ON DATABASE TAGS TO ROLE TAG_ADMIN;

GRANT ALL PRIVILEGES ON SCHEMA TAGS.GOVERNANCE TO ROLE TAG_ADMIN;
GRANT USAGE ON SCHEMA TAGS.GOVERNANCE TO ROLE TAG_ADMIN;





-- More Syntax examples:


-- Creating a bunch of tags, in TAGS database - general tags, to be used in our tables' columns
CREATE OR REPLACE TAG TAGS.GOVERNANCE.phone_number;
CREATE OR REPLACE TAG TAGS.GOVERNANCE.address;
CREATE OR REPLACE TAG TAGS.GOVERNANCE.names;
CREATE OR REPLACE TAG TAGS.GOVERNANCE.comments;
CREATE OR REPLACE TAG TAGS.GOVERNANCE.date;
CREATE OR REPLACE TAG TAGS.GOVERNANCE.keys;
CREATE OR REPLACE TAG TAGS.GOVERNANCE.region;

-- Apply tags to a given table's columns:
ALTER TABLE REVENUE.TRANSPORT.AIRLINE
MODIFY COLUMN "Airlines Name"
SET TAG TAG.GOVERNANCE.NAMES='Airline Name'; -- tag name, tag value.

ALTER TABLE REVENUE.TRANSPORT.AIRLINE
MODIFY COLUMN "Airlines RegionId"
SET TAG TAG.GOVERNANCE.REGION='Region of airline'; -- tag name, tag value.

ALTER TABLE REVENUE.TRANSPORT.AIRLINE
MODIFY COLUMN "Date"
SET TAG TAG.GOVERNANCE.DATE='Arrival Date'; -- tag name, tag value.

ALTER TABLE REVENUE.TRANSPORT.AIRLINE
MODIFY COLUMN "Airlines Notes"
SET TAG TAG.GOVERNANCE.COMMENTS='Traffic Control Comments'; -- tag name, tag value.

-- Check what tags have been applied on a given Table:
SELECT *
FROM TABLE(
    SNOWFLAKE.INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('REVENUE.TRANSPORT.AIRLINE', 'TABLE');
)





-- Example Syntax part two (second step, "searching by tags", after tags have been applied):



-- ACCOUNTADMIN needed - this query will contain info about "what tags were applied, in which objects"
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.ACCOUNT_TAGS_INFORMATION
AS 
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES 
ORDER BY TAG_NAME, DOMAIN, OBJECT_ID;

-- Using the above table, we can filter it to find out in which tables/schemas/databases we can find x type of values, like 'REGION' (because this 'REGION' can exist 
-- in multiple tables, can be "Living regions", or "Cultural regions", many use-cases)
SELECT
DATABASE,
SCHEMA,
TABLE_NAME,
COLUMN_NAME,
TAG_VALUE
FROM ACCOUNT_TAGS_INFORMATION
WHERE TAG_NAME='REGION';

-- See how many "date"-related columns are in your schemas
SELECT 
DATABASE,
SCHEMA,
TABLE_NAME,
COLUMN_NAME,
TAG_VALUE 
FROM ACCOUNT_TAGS_INFORMATION 
WHERE TAG_NAME='DATE';

-- See how many "name"-related columns are in your schemas...
SELECT 
DATABASE,
SCHEMA,
TABLE_NAME,
COLUMN_NAME,
TAG_VALUE 
FROM ACCOUNT_TAGS_INFORMATION 
WHERE TAG_NAME='NAMES';





-- You can also combine Tagging with Masking Policies,
-- to have "TAG-BASED MASKING POLICIES". If you use this
-- feature, every time you apply a tag to a table/column,
-- the assigned masking policy will be applied as well.
-- If you set the Tag in a table, the Masking Policies assigned 
-- to the Tag will attempt to "fit" inside the columns in your table
-- (the "NUMBER_MASK" will try to fit into a "amount" column, the "COMMENTS_MASK"
-- will try to fit into a "name" column, for example).



-- Examples:



-- Create Masking Policies
CREATE OR REPLACE MASKING POLICY CONTROL_DB.MASKING_POLICIES.COMMENTS_MASK
AS (VAL STRING) RETURNS STRING -> 
CASE
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN') THEN '***MASKED***'
    ELSE VAL
END;

CREATE OR REPLACE MASKING POLICY CONTROL_DB.MASKING_POLICIES.NUMBER_MASK
AS (VAL NUMBER) RETURNS NUMBER -> 
CASE
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN') THEN 000000
    ELSE VAL
END;

CREATE OR REPLACE MASKING POLICY CONTROL_DB.MASKING_POLICIES.COMMENTS_MASK
AS (VAL DATE) RETURNS DATE -> 
CASE
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN') THEN '1990-01-01'
    ELSE VAL
END;

-- Assign Masking Policies to Tags
ALTER TAG TAGS.GOVERNANCE.GENERAL_TAG
SET MASKING POLICY COMMENTS_MASK,
    MASKING POLICY NUMBER_MASK
    MASKING POLICY DATE_MASK;

-- Applying Tag to a Table (Masking Policies will be applied as well)
ALTER TABLE DEMO_DB.PUBLIC.EMP_BASIC
SET TAG DEMO_DB.PUBLIC.GENERAL_TAG='Some table 1';

-- Assign Masking Policy to Tag
ALTER TAG TAGS.GOVERNANCE.COMMENTS_TAG
SET MASKING POLICY COMMENTS_MASK;

-- Apply tag to single column (rest of columns does not get modified)
ALTER TABLE DEMO_DB.PUBLIC.EMP_BASIC 
MODIFY COLUMN "Comments" 
SET TAG TAGS.GOVERNANCE.COMMENTS_TAG='Hey there';





-- "Classification", or "the auto-tagging made by Snowflake" feature





-- Feature used for data discovery, for suggesting tags that might be useful
-- for your current Database distribution. It's also frequently used for cases where you
-- have hundreds of columns/tables in your system, to avoid spending
-- too much time applying tags manually.




-- Classification use-cases:



-- 1) Personally identifiable information (sensitive information)


-- 2) Access Control to data 


-- 3) Policy Management 


-- 4) Data Anonymization






-- Classification categories:



-- 1) Semantic Categories

-- Semantic Cat. are things like:

-- A) Names 

-- B) Addresses

-- C) Zip Codes

-- D) Phone Numbers

-- E) Age

-- F) Gender

-- G) URL




-- 2) Privacy Categories


-- A) Identifier 


-- B) Quasi-identifier


-- C) Sensitive





-- When Snowflake auto-tags your database objects, via Classification,
-- it tags with these categories, with these possible values.




-- Example of Classification tagging:



PRIVACY_CATEGORY='IDENTIFIER';

SEMANTIC_CATEGORY='EMAIL';


-- (tagged like this because emails are almost always used 
-- as identifiers)



PRIVACY_CATEGORY='IDENTIFIER';

SEMANTIC_CATEGORY='NAME';


-- (tagged like this because names are almost always used 
-- as identifiers)



PRIVACY_CATEGORY='SENSITIVE';

SEMANTIC_CATEGORY='SALARY';

-- (tagged like this because salary values aren't 
-- identifiers, but are sensitive information)



PRIVACY_CATEGORY='QUASI_IDENTIFIER';

SEMANTIC_CATEGORY='AGE';


-- (tagged like this because Ages aren't identifiers 
-- by se, but can be used with other values in a row to 
-- uniquely identify an individual) - ex: AGE + ZIP + GENDER





-- Probable Quasi-Identifiers:


-- QUASI_IDENTIFIER -->                AGE 
--                                     GENDER 
--                                     COUNTRY 
--                                     DATE OF BIRTH 
--                                     ETHNICITY 
--                                     LATITTDE 
--                                     LAT_LONG 
--                                     LONGITUDE 
--                                     MARITAL_sTATUS 
--                                     OCCUPATION
--                                     US_COUNTY 
--                                     US_CITY
--                                     YEAR_OF_BIRTH 




-- Classification (auto-tagging) demo:



-- Data Classification Built-in Function - suggests tags, tagging by "SEMANTIC_CATEGORY" and "PRIVACY_CATEGORY"
SELECT EXTRACT_SEMANTIC_CATEGORIES('REVENUE.TRANSPORT.AIRLINE');

-- The output is a JSON with the suggested tags' values and probability (because sometimes the suggestion may be wrong; suggestions are only shown if the probability 
-- is higher than 0.15%)
"Airline Notes": {
    "extra_info": {
        "alternates": [],
        "probability": "1.00"
    },
    "privacy_category": "QUASI_IDENTIFIER",
    "semantic_category": "OCCUPATION"
}



-- Function used to convert the JSON into tabular format, for easier viewing
SELECT
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,  
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  FROM
  TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('<database.schema.table_name>')::VARIANT)) AS f;

SELECT
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,  
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  FROM
  TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('<database.schema.table_name>')::VARIANT)) AS f;


SELECT
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,  
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  FROM
  TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('<database.schema.table_name>')::VARIANT)) AS f;
  
--if the probability is below the 0.80 threshold and the process identified other 
--possible semantic categories with a probability greater than 0.15





-- Once/if you are satisfied with the tagging suggested by Snowflake, you can 
-- call a built-in Stored Procedure that will automatically tag the database object 
-- for you. This procedure will tag the columns if their probability is equal to 100% (1.00):
CALL ASSOCIATE_SEMANTIC_CATEGORY_TAGS('<database.schema.table_name>', 
    EXTRACT_SEMANTIC_CATEGORIES('<database.schema.table_name>')
);


-- Check the value of the tagged columns in your table
SELECT *
    FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS('<database.schema.table_name>', 'table'));




-- Output of query seen above (remember, metadata/tags are not applied instantly, there is a delay)

-- TAG_DATABASE        TAG_SCHEMA      TAG_NAME                TAG_VALUE


-- SNOWFLAKE           CORE            PRIVACY_CATEGORY          IDENTIFIER 
-- SNOWFLAKE           CORE            PRIVACY_CATEGORY          QUASI-IDENTIFIER 

-- SNOWFLAKE           CORE            SEMANTIC_CATEGORY          NAME
-- SNOWFLAKE           CORE            SEMANTIC_CATEGORY          OCCUPATION



-- Check out which columns were tagged as "IDENTIFIER", in your system (tags created by Snowflake,
-- with this feature, live in the Snowflake central account schema; tags created by us, users, 
-- stay in the schema where we specify them)
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
    WHERE TAG_NAME = 'PRIVACY_CATEGORY'
    AND TAG_VALUE = 'IDENTIFIER';









-- MODULE 29 -- 








-- M29 - Stored Procedures





-- Some general Snowflake Stored Procedure quirks:


--  0) Stored Procedures never throw errors while they are being created; they will
--     only throw errors during their compilation, when being executed.

-- 0.5) When running "SHOW PROCEDURES", the view doesn't give you any details about 
--      whether a given procedure is a "Caller" or "Owner" procedure. To remediate this 
--      issue, one best-practice is to add "caller" and "owner" to your procedures, depending 
--      on their type, like this:

        CREATE OR REPLACE STORED PROCEDURE RECREATE_USERS_CALLER(ARG STRING)
        ...;
        CREATE OR REPLACE STORED PROCEDURE RECREATE_USERS_OWNER(ARG STRING)
        ...;

--  1) Snowflake doesn't allow the importing of JavaScript packages
--     into procedures.

--  2) Snowflake also doesn't allow you to use JavaScript native Objects
--     like "Math.random()" (you must use SQL functions that yield similar results/effects).
--     Snowflake Objects and their methods, however, are permitted.

-- 3) The important Snowflake Objects, in a Stored Procedure are the Statement (
    -- created with 'Snowflake.createStatement()', and executed with 'statementName.execute()'), and
    -- Result Set (which needs to run 'result_set_name.next()' ) Objects.

-- 4) The data type 'Number' is not supported for arguments or returns (we should use VARCHAR or FLOAT, instead)

-- 5) Many data types are not supported "out-of-the-box"; we need to use the corresponding compatible SQL data types to 
-- use the without errors. The correlation is:


INCOMPATIBLE SQL DATA TYPE     COMPATIBLE SQL DATA TYPE

INTEGER                             FLOAT
NUMBER, NUMERIC, DECIMAL            FLOAT 
BINARY                              Uint8Array
OBJECT                              Uint8Array 


-- 6) This means that the only possible returnable data types are VARCHAR, FLOAT, Uint8Array and VARIANT (for JSON returns).

-- 7) In the return type, we can specify "NOT NULL" as an option; if we do so, NULL values are not included in the final returned result.

-- 8) Inside the Statement Object, the most important methods are ".execute()", ".getColumnValue()", ".getColumnScale()", ".next()" and ".getQueryId()", but 
--    there are other important ones as well.

-- 9) With ".getQueryId()", and a given query's Id, we can get lots of other information, like "how much time a given query took", "which warehouse was used" 
--    and "how long the Warehouse was kept active" (these can be used to calculate cost).

-- 10) The Result Set Object is created on top of/using the Statement Object.

-- 11) The Result Set Object's methods can be found inside of the Statement Object; it has less methods than the Statement Object, and many 
--     of the latter's methods are present in the former's object as well.

-- 12) The most important Result Set method is ".next()", and should always be called, to initialize the pointer in your Result Set (to go through 
-- the entire Result Set and run operations/transformations on top of its records). If you don't call it, you'll receive an error ("ResultSet is empty or not prepared. call next() first.").

-- 12.5) "result_set.next()" should be called after "statement.execute()".

-- 12.6) Once you called "result_set.next()", you become able to call methods like "result_set1.getColumnName()" and "result_set1.getColumnValue()".

-- 13) Argument names are case-insensitive in the SQL portion of the procedure's code, but case-sensitive 
--     in the JavaScript parts.

-- 14) Stored Procedures are able to return only a single output (multiple values per return are not allowed).

-- 15) Because we are able to return only a single value/output, we should always think beforehand about the output structure of 
--     our returned value/object (if we are returning a JSON value).

-- 16) You most often will return JSON as a value (VARIANT), because FLOATS and VARCHARS are not that useful.

-- 17) As you will most frequently return JSON values, the function that will be most useful to you is 
--     "FLATTEN()", which will help you to parse your returned JSON values, like this:

SELECT
f.value:ColumnName,f.value:column_value
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) AS res,
TABLE(FLATTEN(COLUMN_FILL_RATE_OUTPUT_STURCTURE:key1)) AS F; -- "COLUMN_FILL_RATE_OUTPUT_STRUCTURE" is our procedure, being called. We access its key, "key1", with ":", and then with "FLATTEN" we transform the result. 

-- 18) With "result_set.next()" combined with "while" (loops), we can keep calling the next JSON object/value/record 
--     in this result_set; we can then position code inside the while loop, to run for loops transforming the data of each column 
--     inside of each row.

-- 19) "result_set.next()" returns a boolean, true or false, whether "there is still records to go through, in this_result_set".

-- 20) Still, you shouldn't run "result_set.next()" at the beginning of your procedure, as it will skip to the next record in your result set.

-- 21) You can use Bind Variables in your stored procedure to pass values into your SQL statements, from inside the JavaScript code. This feature also 
--     helps to protect against SQL injection attacks, and to make your code more reusable.

-- Snowflake Procedures are divided into 



-- A) Caller Procedures - With Caller Procedures, we, as callers, have more restrictions. We get
--                        Restricted by our own access privileges to tables and objects, and the 
--                        session variables defined during our session always get used inside the
--                        procedure. The procedure also uses our context (database, schema), besides 
--                        the privileges and session variables.

--                        Caller Procedures are "like pets". They can use only the things available to them,
--                        to the role that is using the procedure. As pets, they can only stay in our house (our 
--                        context), and can't invade the houses of our neighbors (other databases/schemas/tables).

--                        They should be used for cases like "Get column fill rate of a table", "remove duplicate records from table",
--                        and for procedures that implement complex business logic (better than owner procedures, for that, as they 
--                        consider the context in which they are executed, and can be reutilized).



-- B) Owner Procedures -  Owner Procedures are always executed considering the privileges/permissions
--                        that the owner/role of the procedure had/has at the time it was created. The 
--                        caller of the procedure, even if that role is not the owner itself, will inherit
--                        the owner's role, during its execution. Information about this view is also blocked,
--                        in the procedures view ('SHOW PROCEDURES' or 'DESC <procedure_name>'). 
--                        Additionally, callers of this type of procedure cannot view, set or unset the owner's
--                        session variables defined in it. It's also not possible for these callers to check out 
--                        the queries/steps executed by this procedure, in the query history view.
 
--                        Use-cases for Owner Procedures are: "get number of permanent and transient tables in 
--                        a database", "get tables with more fail-safe storage" and "get the number of unused tables",
--                        and any other repetitive tasks, that can be executed in your stead, by other roles impersonating
--                        your role.
 
 
 
--                        If some of your roles needs to monitor the procedure's queries/steps, 
--                        he/she should receive additional permission, by a GRANT of the privilege "MONITOR",
--                        like this:
                          GRANT MONITOR ON WAREHOUSE COMPUTE_WH TO ROLE SANDBOX;
                          REVOKE MONITOR ON WAREHOUSE COMPUTE_WH FROM ROLE SANDBOX;







-- Stored Procedure Examples:



-- Returns the count of rows of a given table as a value
CREATE OR REPLACE PROCEDURE COLUMN_COUNT_CALLER(TABLE_NAME VARCHAR)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER -- Caller Procedure
    AS 
    $$
    var my_sql_command =  "SELECT COUNT(*) FROM " + TABLE_NAME;

    var statement1 = snowflake.createStatement({ sqlText: my_sql_command }); -- Statement Object created
    
    var result_set1 = statement1.execute(); -- Result Set Object created

    result_set1.next(); -- Result Set 'next()' method called (initializes pointer - needed to go through table)

    row_count = result_set1.getColumnValue(1); -- Value - VARCHAR

    return row_count;
    $$;



-- Show all procedures 
SHOW PROCEDURES;


-- Call/Execute Stored Caller Procedure 
CALL COLUMN_COUNT_CALLER(DEMO_DB.PUBLIC.EMP_BASIC); -- returns something like '10.000';


-- Returns the Snowflake Statement Object, in a JSON format, displaying all of its methods and properties. 
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_STATEMENT_OBJECT_CALLER(TABLE_NAME VARCHAR)
    RETURNS VARIANT NOT NULL 
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER -- Caller Procedure
    $$
    var my_sql_command = 'SELECT COUNT(*) FROM ' + TABLE_NAME;


    var statement1 = snowflake.createStatement({sqlText: my_sql_command});


    return statement1;
    $$

-- Check out the Snowflake Statement Object, returned by this procedure
CALL COLUMN_FILL_RATE_CALLER('DEMO_DB.PUBLIC.CUSTOMER');



-- Snowflake Statement Object:
{
  "_c_resultSet": {
    "columnCount": 1,
    "getColumnDescription": {},
    "getColumnName": {},
    "getColumnScale": {},
    "getColumnSfDbType": {},
    "getColumnValue": {},
    "getColumnValueInternalRep": {},
    "getColumnValueStringRep": {},
    "getColumnsName": {},
    "isColumnNullable": {},
    "next": {},
    "rowCount": 1,
    "status": 0
  },
  "_updateStatementWithNewResult": {},
  "columnCount": 1,
  "execute": {},
  "executeAsync": {},
  "getColumnCount": {},
  "getColumnName": {},
  "getColumnScale": {},
  "getColumnSqlType": {},
  "getColumnType": {},
  "getNumDuplicateRowsUpdated": {},
  "getNumRowsAffected": {},
  "getNumRowsDeleted": {},
  "getNumRowsInserted": {},
  "getNumRowsUpdated": {},
  "getPersistedStatus": {},
  "getQueryId": {},
  "getRequestId": {},
  "getRowCount": {},
  "getSqlText": {},
  "getStatementId": {},
  "getStatus": {},
  "isColumnArray": {},
  "isColumnBinary": {},
  "isColumnBoolean": {},
  "isColumnDate": {},
  "isColumnNullable": {},
  "isColumnNumber": {},
  "isColumnObject": {},
  "isColumnText": {},
  "isColumnTime": {},
  "isColumnTimestamp": {},
  "isColumnVariant": {},
  "isDml": {},
  "queryId": "01aea239-0001-4fe1-0004-6d2a000420da",
  "resultSet": {
    "COUNT(*)": 150000,
    "getColumnCount": {},
    "getColumnDescription": {},
    "getColumnName": {},
    "getColumnScale": {},
    "getColumnSqlType": {},
    "getColumnType": {},
    "getColumnValBoxedType": {},
    "getColumnValue": {},
    "getColumnValueAsString": {},
    "getNumRowsAffected": {},
    "getQueryId": {},
    "getRowCount": {},
    "getSqlcode": {},
    "isColumnArray": {},
    "isColumnBinary": {},
    "isColumnBoolean": {},
    "isColumnDate": {},
    "isColumnNullable": {},
    "isColumnNumber": {},
    "isColumnObject": {},
    "isColumnText": {},
    "isColumnTime": {},
    "isColumnTimestamp": {},
    "isColumnVariant": {},
    "isDml": {},
    "next": {},
    "setCResultSet": {}
  },
  "rowCount": 1,
  "wait": {}
}


-- Result Set Object:
  "resultSet": {
    "COUNT(*)": 150000,
    "getColumnCount": {},
    "getColumnDescription": {},
    "getColumnName": {},
    "getColumnScale": {},
    "getColumnSqlType": {},
    "getColumnType": {},
    "getColumnValBoxedType": {},
    "getColumnValue": {},
    "getColumnValueAsString": {},
    "getNumRowsAffected": {},
    "getQueryId": {},
    "getRowCount": {},
    "getSqlcode": {},
    "isColumnArray": {},
    "isColumnBinary": {},
    "isColumnBoolean": {},
    "isColumnDate": {},
    "isColumnNullable": {},
    "isColumnNumber": {},
    "isColumnObject": {},
    "isColumnText": {},
    "isColumnTime": {},
    "isColumnTimestamp": {},
    "isColumnVariant": {},
    "isDml": {},
    "next": {},
    "setCResultSet": {}
  },


-- UPPERCASE vs lowercase, in stored procedures:

-- Argument names are case-insensitive in the SQL portion of the stored procedure code, but are case-sensitive in the JavaScript portion.
-- Using uppercase identifiers (especially argument names) consistently across your SQL statements and JavaScript code tends to reduce silent errors
CREATE OR REPLACE PROCEDURE F(ARGUMENT1 VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER -- Caller Procedure
AS
$$

var local_variable2 = ARGUMENT1;  // Correct

var local_variable1 = argument1;  // Incorrect

return local_variable2
$$;

call F('prad');



-- Using while, "for loop" and control structures inside of Procedure:
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_LOOPS(TABLE_NAME VARCHAR)
RETURNS VARIANT NOT NULL
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER -- Caller Procedure
AS
$$
var array_of_rows = [];
row_as_json = {};

var my_sql_command = "select count(*) ABC,count(*) DEF from "+ TABLE_NAME +";"
var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );
var result_set1 = statement1.execute();

while(result_set1.next()) { -- While (see point 18) - this "while" will keep running, as long as there's records to go through, in your table/result_set.

    -- Put each row in a variable of type JSON. 

    -- For each column in the row...

    for (var col_num = 0; col_num < result_set1.getColumnCount(); col_num = col_num + 1) { -- For loop (see point 18)

        var col_name = result_set1.getColumnName(col_num+1);
        var col_value = result_set1.getColumnValue(col_num+1);

        row_as_json = {
            ColumnName: col_name,
            column_value: col_value
        }


        array_of_rows.push(row_as_json);
    }
}


var table_as_json = { -- JSON object
    "key1": array_of_rows
}

return table_as_json;
$$


CALL COLUMN_FILL_RATE_LOOPS('DEMO_DB.PUBLIC.EMP_BASIC');



-- Same code as above, but with steps
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_LOOPS(TABLE_NAME varchar)
  RETURNS VARIANT NOT NULL
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER -- Caller Procedure
  AS 
  $$  
  
    var array_of_rows = [];
    row_as_json = {};
    


    -- //// 1) SQL statement in JavaScript variable
    var my_sql_command = "select * from "+ TABLE_NAME +" LIMIT 10;"

    -- //// 2) Creation of Statement Object, using SQL command
    var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );

    -- //// 3) Execution of Statement Object
    var result_set1 = statement1.execute();
    
      while (result_set1.next())  {
        -- Put each row in a variable of type JSON.
 
        -- For each column in the row...
        for (var col_num = 0; col_num < result_set1.getColumnCount(); col_num = col_num + 1) {
          var col_name =result_set1.getColumnName(col_num+1);
          var col_value = result_set1.getColumnValue(col_num+1);
          
          row_as_json = { ColumnName : col_name ,column_value : col_value}
          
          array_of_rows.push(row_as_json)
          }
          
        }   
        
  table_as_json = { "key1" : array_of_rows }; -- JSON object
   
   -- //// 4) Return of Result Set/other object, constructed using the Result Set (transformations)
   return table_as_json; 
  $$
  ;

-- Procedure call
CALL COLUMN_FILL_RATE_LOOPS('DEMO_DB.PUBLIC.EMP_BASIC');



-- Output of above procedure(JSON, single value, object):
{
  "key1": [
    {
      "ColumnName": "C_CUSTKEY",
      "column_value": 30001
    },
    {
      "ColumnName": "C_NAME",
      "column_value": "Customer#000030001"
    },
    {
      "ColumnName": "C_ADDRESS",
      "column_value": "Ui1b,3Q71CiLTJn4MbVp,,YCZARIaNTelfst"
    },
    {
      "ColumnName": "C_NATIONKEY",
      "column_value": 4
    },
    {
      "ColumnName": "C_PHONE",
      "column_value": "14-526-204-4500"
    },
    {
      "ColumnName": "C_ACCTBAL",
      "column_value": 8.848469999999999e+03
    },
    {
      "ColumnName": "C_MKTSEGMENT",
      "column_value": "MACHINERY"
    },
    {
      "ColumnName": "C_COMMENT",
      "column_value": "frays wake blithely enticingly ironic asymptote"
    },
    {
      "ColumnName": "C_CUSTKEY",
      "column_value": 30002
    },
    {
      "ColumnName": "C_NAME",
      "column_value": "Customer#000030002"
    },
    {
      "ColumnName": "C_ADDRESS",
      "column_value": "UVBoMtILkQu1J3v"
    },
    {
      "ColumnName": "C_NATIONKEY",
      "column_value": 11
    },
    {
      "ColumnName": "C_PHONE",
      "column_value": "21-340-653-9800"
    },
    {
      "ColumnName": "C_ACCTBAL",
      "column_value": 5.221810000000000e+03
    },
    {
      "ColumnName": "C_MKTSEGMENT",
      "column_value": "MACHINERY"
    },
    {
      "ColumnName": "C_COMMENT",
      "column_value": "he slyly ironic pinto beans wake slyly above the fluffily careful warthogs. even dependenci"
    }
  ]
}



-- Alternative steps to execute statement (simpler, 3 steps in one, but less control).
CREATE OR REPLACE PROCEDURE CUSTOMERS_INSERT_PROCEDURE_CALLER(CREATE_DATE VARCHAR)
    RETURNS STRING NOT NULL 
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER -- Caller Procedure
    AS 
    $$

    -- //// 1) SQL statement in JavaScript variable
        var sql_command = 'INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(:1);'
        
    -- //// 2) Using the Snowflake Global Object, execute SQL text directly (without creating Statement Object, or creating the Statement Object and immediately
    -- executing it)
        snowflake.execute(
            {
            sqlText: sql_command,
            binds: [CREATE_DATE]
            });
    -- //// 3) Return of string value
        return "Successfully executed.";
    $$;


CALL CUSTOMERS_INSERT_PROCEDURE_CALLER(current_date());


-- Using if-else statements in for loop
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_LOOPS_IF_ELSE_CALLER(TABLE_NAME varchar)
  RETURNS VARIANT NOT NULL
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER -- Caller Procedure
  AS    
  $$  
  
    var array_of_rows = [];
    row_as_json = {};
    


--  //// 1) SQL statement in JavaScript variable
    var my_sql_command = "select * from "+ TABLE_NAME +" LIMIT 10;"


--  //// 2) Creation of Statement Object, using SQL command
    var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );

-- //// 3) Execution of Statement Object
    var result_set1 = statement1.execute();
    

-- //// 3.5) Execution of ".next()" on result_set object (must always be done, even without while and for loops)
      while (result_set1.next())  {
--      // Put each row in a variable of type JSON.
 
 --     // For each column in the row...
        for (var col_num = 0; col_num < result_set1.getColumnCount(); col_num = col_num + 1) {
          var col_name =result_set1.getColumnName(col_num+1);
          var col_value = result_set1.getColumnValue(col_num+1);
          

          if (col_name==='C_NAME') {
            col_value='JOHN';
          } else {
            col_value
          }


          row_as_json = { ColumnName : col_name ,column_value : col_value}
          
          array_of_rows.push(row_as_json)
          }
          
        }   
        
  table_as_json = { "key1" : array_of_rows };
   
--  //// 4) Return of Result Set/other object, constructed using the Result Set (transformations)
   return table_as_json; 
  $$
  ;


-- Example of the usage of Bind Variables
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_BIND_VAR_CALLER(TABLE_NAME VARCHAR)
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER -- Caller Procedure
    AS 
    $$ 
    var array_of_rows= [];
    var row_as_json = {};

    var my_sql_command = "SELECT * FROM " + TABLE_NAME + " LIMIT 10;"
    var statement1 = snowflake.createStatement(
        {
            sqlText: my_sql_command
        }
    );
    var result_set1 = statement1.execute();


    var my_sql_command_2 = 'INSERT INTO CUSTOMER_TRANSPOSED VALUES(:1, :2)'; -- :1 and :2 are the placeholders/slots for the binded values.


    while (result_set1.next()) {

-- // Put each row in a variable of type JSON.

 -- // For each column in the row...
        for (var col_num = 0; col_num < result_set1.getColumnCount(); col_num = col_num + 1) {

                var col_name=result_set1.getColumnName(col_num + 1);
                var col_value=result_set1.getColumnValue(col_num + 1);



        if (col_name === 'C_NAME') {
            col_value='JOHN'
        } else {
            col_value
        }


        row_as_json = {
            ColumnName: col_name,
            column_value: col_value
        };

        array_of_rows.push(row_as_json);


        snowflake.execute({ -- Instead of returning the result set/some object, we run an INSERT statement into a table, via this statement
            sqlText: my_sql_command_2,
            binds: [col_name, col_val] -- Example of Bind Variables usage - we bind these variables' values into the "my_sql_command_2" statement.
        }) 
        }
    }

    return 'Rows inserted Successfully';
        $$;


CALL COLUMN_FILL_RATE_BIND_VAR_CALLER('DEMO_DB.PUBLIC.CUSTOMER');





-- Example of procedure - Show column fill rate for a given table, in tabular format

CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_CALLER(TABLE_NAME varchar)
  RETURNS VARIANT NOT NULL
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER -- Caller Procedure
  as     
  $$  
    var my_sql_command = "select COUNT(*) CNT from "+ TABLE_NAME +";"
    var statement1 = snowflake.createStatement( {sqlText: my_sql_command} );
    var result_set1 = statement1.execute();
    result_set1.next();
    
    var my_sql_command2 = "select * from "+ TABLE_NAME +" LIMIT 10 ;"
    var statement2 = snowflake.createStatement( {sqlText: my_sql_command2} );
    var result_set2 = statement2.execute();
    
    var cnt = result_set1.getColumnValue(1);
    var array_of_rows = [];
    
    
    var row_num = 0;
    row_as_json = {};
    
    var column_name;
    
      while (result_set2.next())  {
       -- // Put each row in a variable of type JSON.
         
       -- // For each column in the row...
        for (var col_num = 0; 
        col_num < result_set2.getColumnCount(); -- we can run this because we called "result_set3.next()" in the while loop.
        col_num = col_num + 1) {
          var col_name =result_set2.getColumnName(col_num+1);
          
         var my_sql_command3 = "select round(count(*)/"+cnt+",2) RW_CNT from "+ TABLE_NAME +" where "+col_name+" IS NOT NULL;"
         
        -- // return cnt;
         var statement3 = snowflake.createStatement( {sqlText: my_sql_command3} );
      
           result_set3 = statement3.execute();
          
           result_set3.next();
           var col_value = result_set3.getColumnValue(1); -- we can run this because we called "result_set3.next()" in the previous line.
          
           row_as_json = { ColumnName : col_name ,column_value : col_value}
          
           array_of_rows.push(row_as_json)
          }
          
        }   
        
      table_as_json = { "key1" : array_of_rows };
      
         for (var col_num = 0; col_num < result_set2.getColumnCount(); col_num = col_num + 1) {
         
         var my_sql_command4 = "insert into Table_fill_rate values (:1 , :2 ) "
      
         var statement4 = snowflake.createStatement( {sqlText: my_sql_command4,binds: [table_as_json.key1[col_num].ColumnName,table_as_json.key1[col_num].column_value]} );
      
         statement4.execute();
         
         }
 
  return table_as_json; 
  $$
  ;


CALL COLUMN_FILL_RATE_CALLER('DEMO_DB.PUBLIC.EMP_BASIC');


-- Output of above procedure:

COLUMN_NAME	FILL_RATE
C_CUSTKEY	1
C_NAME	1
C_ADDRESS	1
C_NATIONKEY	1
C_PHONE	1
C_ACCTBAL	1
C_MKTSEGMENT	1
C_COMMENT	1






-- The above procedure assumes that everything always goes well; However, when running any code, error scenarios always are going to pop up.

-- Some of the possible error scenarios, for this procedure, are:



-- 1) Table is empty 

-- 2) All records of table have "null" as one of the columns' as values.

-- 3) Table passed as argument does not exist

-- 4) Column data type is "JSON" or "VARIANT" (in this case, we should skip the checking of the fill rate of this column)

-- 5) Procedure fails "in between", for no aparent reason (someone aborted the process, for example) - in this case, we want to see a transaction-like
--    behavior (or all records get inserted, or no records get inserted at all. In other words, a roll back must occur).




-- For these and other error cases, we need error handling in our procedures.

-- For error handling, we can use try-catch blocks.

-- It's also a good idea to set up an additional "ERROR_LOG" table, which can store the miscellaneous
-- errors that might occur during our procedure's calls.

-- One big problem with Snowflake is that it has no DEBUG console, which means it is hard for us to know
-- which values are reaching our variables, at a given time, in the code (we cannot print values into the console). A way 
-- to circumvent this is to constantly write "return" statements to return different values in our code, frequently recreating our 
-- procedures to have an idea of what values are getting passed.


-- However, there is a workaround, using an utility procedure, which will be shown below.






-- In ETL job scenarios, with multiple steps, we tipically want that errors "bubble-up" during execution,
-- so that the procedure itself "fails". If we don't maintain that behavior, the procedure
-- will be treated as successful, which means that the downstream jobs, that receive its data,
-- will be receiving wrong data, something that will lead to discrepant results.

-- Summing up:


-- 1) When not running an ETL job, you can error handle like this:
if (reg_status === false) {
    return TABLE_NAME + " is not a table " -- This will make it so that your procedure ends up as "successful", even if you did have an error.
}

-- 2) When running an ETL job, you should error handle like this (throwing errors):
try {
    var my_sql_command = "SELECT COUNT(*) AS CNT FROM " + TABLE_NAME + ";";
    var statement1 = snowflake.createStatement(
        {
            sqlText: my_sql_command
        }
    );
    var result_set1 = statement1.execute();
    result_set1.next();
} catch (err) {
    snowflake.execute({
        sqlText: "INSERT INTO ERROR_LOG VALUES (?, ?, ?, ?)", -- With this, we LOG our error into a error_log table, before throwing the error itself to the console.
        binds: [err.code, err.state, err.message, err.stackTraceTxt]
    });

    throw err.message; -- Actual throw of an error; will mark your procedure as "failed"
}



-- 2.5) Or like this (throwing inside the try block, manually):
try {

    var my_sql_command = "SELECT COUNT(*) AS CNT FROM " + TABLE_NAME + ";";
    var statement1 = snowflake.createStatement(
        {
            sqlText: my_sql_command
        }
    );
    var result_set1 = statement1.execute();


    if (some_condition) {
        throw 'example error'; --- This will also trigger the catch block.
    }

    result_set1.next();
} catch (err) {
    snowflake.execute({
        sqlText: "INSERT INTO ERROR_LOG VALUES (?, ?, ?, ?)", -- With this, we LOG our error into a error_log table, before throwing the error itself to the console.
        binds: [err.code, err.state, err.message, err.stackTraceTxt]
    });

    throw err.message;
}




-- Error handling, different cases/scenarios
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_CALLER(TABLE_NAME VARCHAR)
    RETURNS VARIANT -- NOT NULL
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER
    AS 
    $$ 
    var input_pattern = "SELECT RLIKE('" + TABLE_NAME + "', '[a-zA-Z0-9_]+')";

    var statement0 = snowflake.createStatement({
        sqlText: input_pattern
    });


    var result_set0 = statement0.execute();
    result_set0.next();
    reg_status = result_set0.getColumnValue(1);
-- Handle "junk values passed as parameter" scenario
    if(reg_status === false) {
        return TABLE_NAME + " is not a table"; 
    }


-- Handle generic error scenarios
    try {
        var my_sql_command = "SELECT COUNT(*) AS CNT FROM " + TABLE_NAME + ";";

        var statement1 = snowflake.createStatement({
            sqlText: my_sql_command
        });

        var result_set1 = statement1.execute();

        result_set1.next();
    } catch (err) { -- generic error catch block

        return "Failed: " + err;
    }


var cnt = result_set1.getColumnValue(1);

-- Handle "Table has 0 records" scenario
if (cnt === 0) {
    return TABLE_NAME + " is empty "
}


try {
    var my_sql_command2 = "SELECT * FROM" + TABLE_NAME + " LIMIT 10;";
    var statement2 = snowflake.createStatement(
        {
            sqlText: my_sql_command2
        }
    );
    var result_set2 = statement2.execute();

} catch (err) { -- catch more generic errors
    return 'Failed: ' + err;
}


var array_of_rows = [];
var row_num = 0;

var row_as_json = {};
var column_name;

table_as_json = { "key1" : array_of_rows };


try {
for (var col_num = 0; col_num < result_set2.getColumnCount(); col_num = col_num + 1) {
var my_sql_command4 = "insert into Table_fill_rate values (:1 , :2)";

var statement4 = snowflake.createStatement(
    {  
        sqlText: my_sql_command4,
        binds: [table_as_json.key1[col_num].ColumnName,table_as_json.key1[col_num].column_value]
    } 
    );

statement4.execute();
}

      } catch (err) { -- catch more generic errors
        return: 'Failed: ' + err;
      }
    
return table_as_json;       
$$

-- Call Procedure
CALL COLUMN_FILL_RATE_CALLER('DEMO_DB.PUBLIC.EMP_BASIC');









-- There is a very useful utility procedure, which should be used during 
-- procedure development, inside your other procedures,
--  to log your variable's values into tables. It is shown below.



-- Utility procedure, used to log values into a separate table, to guide us. 'MSG' parameter is the value to be logged,
-- and 'TIMESTAMP' is the moment the value ocurred.
SET do_log = true; -- /// if TRUE, we enable logging. With false, the logging is disabled.
SET log_table = 'my_log_table'; -- // The name of the temp table where log messages will go.

CREATE OR REPLACE PROCEDURE DO_LOG(MSG STRING) 
    RETURNS STRING 
    LANGUAGE JAVASCRIPT 
    EXECUTE AS CALLER 
    AS
    $$

    try {
 -- Checks if we should log - checks for session variable "do_log = true";
var statement = snowflake.createStatement({sqlText: `SELECT $do_log`}).execute();
        } catch (err) {
        return ''; -- "swallow" the error, variable not set, so do not log anything.
                    }

    statement.next();

    if (statement.getColumnValue(1) == true) { -- if the value is anything other than true, don't log.
        try {
            snowflake.createStatement({
                sqlText: 'CREATE TEMP TABLE IDENTIFIER ($log_table) IF NOT EXISTS (TIMESTAMP NUMBER, MSG STRING)'
            }).execute();

            snowflake.createStatement({
                sqlText: 'INSERT INTO IDENTIFIER ($log_table) VALUES (:1, :2)',
                binds: [Date.now(), MSG]
            }).execute();
        } catch (error) {
            throw error;
        }

    }
    $$;



-- Usage:

-- 1) We start by defining a variable as an empty string. We'll gradually fill up this 
--    variable with the "MSG" values we get during our procedure's execution.

-- 2) We call "do_log(<some_variable>)" with the variables whose values we want to know, in our code.

-- 3) A temporary table, "my_log_table", will be created, and each row will be a log of the values got during one execution of 
--    your procedure.




-- Example:
CREATE OR REPLACE PROCEDURE COLUMN_FILL_RATE_CALLER(TABLE_NAME VARCHAR)
    RETURNS VARIANT NOT NULL
    LANGUAGE JAVASCRIPT
    EXECUTE AS CALLER
    AS 
    $$ 

    var accumulated_log_messages = ''; -- We will fill up this variable with the values of the variables we want to know about.

     function log(msg) { -- we define this function for ease of use, to be able to call this extra procedure multiple times, in this procedure.
        snowflake.createStatement( { sqlText: `call do_log(:1)`, binds:[msg] } ).execute();
        }


    var input_pattern = "SELECT RLIKE('" + TABLE_NAME + "', '[a-zA-Z0-9_]+')";

    var statement0 = snowflake.createStatement({
        sqlText: input_pattern
    });


    var result_set0 = statement0.execute();
    result_set0.next();
    reg_status = result_set0.getColumnValue(1);

-- add one value into the accumulated_log_messages, so we can check this value, later, in the my_log_table table
    accumulated_log_messages += 'regular expression result: '+reg_status+ '\n';



-- Handle "junk values passed as parameter" scenario
    if(reg_status === false) {
        return TABLE_NAME + " is not a table"; 
    }


-- Handle generic error scenarios
    try {
        var my_sql_command = "SELECT COUNT(*) AS CNT FROM " + TABLE_NAME + ";";

        var statement1 = snowflake.createStatement({
            sqlText: my_sql_command
        });

        var result_set1 = statement1.execute();

        result_set1.next();
    } catch (err) { -- generic error catch block

      snowflake.execute({
      sqlText: `insert into error_log VALUES (?,?,?,?)`,
      binds: [err.code, err.state, err.message, err.stackTraceTxt]
      });
 
      if (accumulated_log_messages != '') {
        log(accumulated_log_messages) -- log accumulated messages/create record in "my_log_table"
        }
      throw err.message; -- end execution
    }


var cnt = result_set1.getColumnValue(1);

-- Handle "Table has 0 records" scenario
if (cnt === 0) {
    return TABLE_NAME + " is empty "
}
-- add one more value into the accumulated_log_messages, so we can check this value, later, in the my_log_table table
accumulated_log_messages += 'count of records: '+cnt+ '\n';


try {
    var my_sql_command2 = "SELECT * FROM" + TABLE_NAME + " LIMIT 10;";
    var statement2 = snowflake.createStatement(
        {
            sqlText: my_sql_command2
        }
    );
    var result_set2 = statement2.execute();

} catch (err) { -- catch more generic errors
      snowflake.execute({
      sqlText: `insert into error_log VALUES (?,?,?,?)`
      ,binds: [err.code, err.state, err.message, err.stackTraceTxt]
      });
    
    if (accumulated_log_messages != '') {
     -- log accumulated messages/create record in "my_log_table"
        log(accumulated_log_messages)
        }

    throw "Failed: when trying to get schema of the table"; -- end execution
}

-- add one more value into the accumulated_log_messages, so we can check this value, later, in the my_log_table table
accumulated_log_messages += 'column type of result set 2: '+result_set2.getColumnType(1)+ '\n';

var array_of_rows = [];
var row_num = 0;

var row_as_json = {};
var column_name;

-- add one more value into the accumulated_log_messages, so we can check this value, later, in the my_log_table table
accumulated_log_messages += 'array of records: '+array_of_rows+ '\n'; 

table_as_json = { "key1" : array_of_rows };


try {
for (var col_num = 0; col_num < result_set2.getColumnCount(); col_num = col_num + 1) {
var my_sql_command4 = "insert into Table_fill_rate values (:1 , :2)";

var statement4 = snowflake.createStatement(
    {  
        sqlText: my_sql_command4,
        binds: [table_as_json.key1[col_num].ColumnName,table_as_json.key1[col_num].column_value]
    } 
    );

statement4.execute();
}

      } catch (err) { -- catch more generic errors
        return: 'Failed: ' + err;
      } 
      -- this finally is super important. It will always get executed, even if no errors have occurred.
      finally { -- if no errors occurred, still log string values into my_log_table.
        if (accumulated_log_messages != '') {
        log(accumulated_log_messages)
        }
      }
    
return table_as_json;       
$$





-- If needed, we can implement transactional (or all rows get inserted, or no rows at all) behavior in our procedures. We can do this 
-- by using "BEGIN WORK", "ROLLBACK WORK" and "COMMIT WORK", in conjunction with the "Snowflake.execute()" method.


-- Some general transaction guidelines, using Snowflake Stored Procedures:


-- 1) Never forget the "START WORK" statement, to start your procedure.

-- 2) Always run "COMMIT WORK" statements, to save your work, OUTSIDE of for loops/while loops

-- 3) The "ROLLBACK WORK" statement typically is executed in catch blocks, as a error handling mechanism.



-- Example:




-- (inside Procedure's code):
    snowflake.execute({
        sqlText: "BEGIN WORK;"  -- Starts Transaction.
    });


   try{
         for (var col_num = 0; col_num < result_set2.getColumnCount(); col_num = col_num + 1) {
         
         var my_sql_command4 = "insert into Table_fill_rate values (:1 , :2 ) "
      
         var statement4 = snowflake.createStatement( {sqlText: my_sql_command4,binds: [table_as_json.key1[col_num].ColumnName,table_as_json.key1[col_num].column_value]} );
      
          statement4.execute();
         
         }

         snowflake.createStatement(
            {
                sqlText: "COMMIT WORK" -- Saves changes, if everything went right.
            } 
         ).execute(); 

   } 
   catch (err) {
    
    snowflake.execute({
        sqlText: "ROLLBACK WORK;" -- Rolls back changes, if something went wrong.
    });

    throw "Failed: " + err;
   }




-- About UDF overloads:


-- They are "The ability for multiple UDFs to exist with 
-- the same identifier, but different input arguments".

-- Example:

SUBSTR(col_name, 1, 3);
SUBSTR(col_name, 1); -- different overloads




-- MODULE 30 --






-- M30 - Access Control




-- Tri-secret secure feature makes use of a composite encryption
-- key made up of a customer managed key and a Snowflake managed key
-- to encrypt data files.

-- Snowflake uses a hierarchical key model which is rooted in
-- a hardware key.

-- Snowflake uses Role-based Access Control (RBAC)
-- and Discretionary Access Control (DAC).

-- The access to database objects is defined through privileges. Our 
-- Roles should have granular privileges, from top to bottom.

-- In Snowflake, every securable object is owned by a single role (single ownership),
-- and all Objects are individually securable.

-- When a user is created, by default it has no role other than 'PUBLIC',
-- and no warehouse access.

-- With the "USAGE" privilege on a role, we can run queries on warehouses.
-- However, if we wish to suspend/resume a given warehouse, we need the privilege 
-- of "OPERATE" on top of it.





-- In the Snowsight GUI, if you click in "Account" and then in "Roles",
-- you get a nice diagram of all the roles in your system.


-- In regular (i.e. non-managed schemas), object owners (creators of tables, schemas, databases),
-- roles that have ownership over objects, can grant access on these objects to any roles, if they 
-- wish to do so.


-- Snowflake systems are always divided like this:




                     ORGANIZATION 
                        
                  ACCOUNT-LEVEL OBJECTS

USER ROLE  DATABASE    WAREHOUSE   NETWORK POLICY   OTHER ACCOUNT OBJECTS
                        

                  SCHEMA-LEVEL OBJECTS

TABLE VIEW  STAGE   STORED PROCEDURE    UDF   OTHER SCHEMA OBJECTS 








-- The Snowflake default roles, on the other hand, are structured like this:

                          ORGADMIN (creates and manages accounts)

                        ACCOUNTADMIN 

            SECURITYADMIN           SYSADMIN 

              USERADMIN            CUSTOM ROLES





-- General Role characteristics:



-- A) ACCOUNTADMIN -  Role that encapsulates the SYSADMIN and SECURITYADMIN
--                    system-defined roles. It is the top-level role in the system,
--                    and should be granted to only a limited/controlled 
--                    number of users in your account.

-- B) SECURITYADMIN - Role that can manage any object grant globally,
--                    as well as create, monitor and manage USERs and ROLEs
--                    This role has the "MANAGE GRANTS" security privilege, and,
--                    with it, is able to modify and revoke any grant. It also
--                    Inherits the privileges of the USERADMIN role. However, it can't create warehouses, databases and schema-level objects.

-- C) USERADMIN -     Role that is dedicated to USER and ROLE management only. This
--                    Role has the "CREATE USER" privilege (also can manage them), but
--                    cannot create ROLEs, nor GRANT ROLEs into other ROLEs or USERs.


-- D) SYSADMIN -    Role that has privileges to "CREATE WAREHOUSE" and "CREATE DATABASE"
--                  (and other schema-level objects) in your system. If, as recommended, 
--                  you create a role hierarchy that ultimately assigns all custom roles 
--                  to the SYSADMIN ROLE, this role also has the ability to grant privileges
--                  on Warehouses, Databases and other objects to other roles. However, it can't create or manage users and roles.






-- Lifecycle of a USER-ROLE:

-- Can create users and assign roles to them
USE ROLE SECURITYADMIN;

-- Create User - no privileges at the beginning
CREATE USER ARTHUR PASSWORD='ABC123';

-- Create Role - no privileges at the beginning
CREATE OR REPLACE ROLE DEVELOPER;

-- Grant privileges to role
GRANT USAGE ON DATABASE DEMO_DB TO ROLE DEVELOPER;
GRANT USAGE ON SCHEMA PUBLIC TO ROLE DEVELOPER;
GRANT SELECT ON TABLE EMP_BASIC TO ROLE DEVELOPER;


-- Grant usage to Warehouse to role - can also be executed with "SYSADMIN" - OBS: "USAGE" is not the same as "OPERATE" (doesn't let you resume/suspend the warehouse)
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DEVELOPER;
-- REVOKE USAGE ON WAREHOUSE COMPUTE_WH FROM ROLE DEVELOPER;

-- Grant role DEVELOPER to user ARTHUR
GRANT ROLE DEVELOPER TO USER ARTHUR;

-- Connect Custom role, 'DEVELOPER', to SYSADMIN (should always be done). SYSADMIN gets all the privileges of the DEVELOPER role.
GRANT ROLE DEVELOPER TO ROLE SYSADMIN;

-- Now user ARTHUR can use role 'DEVELOPER'
USE ROLE DEVELOPER;

-- Change to role ACCOUNTADMIN, to grant "CREATE DATABASE" permission (only allowed for ACCOUNTADMIN and SYSADMIN roles)
USE ROLE ACCOUNTADMIN;

-- Grant additional permissions (not recommended, to custom roles under SYSADMIN)
-- If we do this, the role also gets the permissions to create schema, tables, views, stages, procedures, udfs, file formats and all other schema-level objects (very risky).
-- Because of this reason, this privilege should not be granted to custom roles under SYSADMIN.
GRANT CREATE DATABASE ON ACCOUNT TO ROLE DEVELOPER;






-- Managed Schema --


-- In regular (i.e. non-managed schemas), object owners (creators of tables, schemas, databases),
-- roles that have ownership over objects, can grant access on these objects to any roles, if they 
-- wish to do so.

-- To remedy this access control freedom and to have better security, managed schemas were created.
-- With Managed Schemas, object owners lose the ability to GRANT access to other roles. Only the Schema 
-- Owner (the role with "OWNERSHIP" privilege on the Schema itself) or a role with the MANAGE GRANTS 
-- privilege can grant privileges on objects in the Schema.

-- In Managed Schemas, therefore, the most important character is the Schema Owner.



-- To use these Managed Schemas adequately, we must follow some guidelines:



-- 1) The role that creates the objects, inside of the Schema,
--    must not be the Schema Owner, but must have the privileges 
--    to create objects in that Schema.

-- 2) The Schema Owner is the one that will run "GRANTS" to give
--    access to other roles, to this Schema's objects.



-- The Role that creates and manages Roles
USE ROLE SECURITYADMIN; 

-- Create the Role responsible for the objects' creation
CREATE OR REPLACE ROLE MY_ROLE_CHILD_1;

-- Connect the child role to the parent role (Schema Owner)
GRANT ROLE MY_ROLE_CHILD_1 TO ROLE MY_ROLE;

-- Create Schema as Managed Schema
CREATE OR REPLACE SCHEMA MY_SCHEMA WITH MANAGED ACCESS;

-- Convert Schema into Managed Schema (only ACCOUNTADMIN and SECURITYADMIN can execute this statement, because only they have "GLOBAL MANAGE GRANTS")
ALTER SCHEMA MY_DB.MY_SCHEMA 
ENABLE MANAGED ACCESS;

-- Role that has the permission to GRANT USAGE to other roles (but does not actually create the database objects)
USE ROLE MY_ROLE; 

-- Grant needed "create"/manage schema objects privilege to the object creator role (but not the GRANTS privilege, that is exclusive to the Schema Owner)
GRANT USAGE ON DATABASE MY_DB TO ROLE MY_ROLE_CHILD_1;
GRANT USAGE ON SCHEMA MY_DB.MY_SCHEMA_2 TO ROLE MY_ROLE_CHILD_1;
GRANT ALL PRIVILEGES ON SCHEMA MY_SCHEMA_2 TO ROLE MY_CHILD_1;

-- Change to "MY_ROLE_CHILD_1", to test if we can manage created objects inside of schema.
USE ROLE MY_ROLE_CHILD_1;

-- Even "DROP TABLE" works, because "MY_ROLE_CHILD_1" has ownership over it.
DROP TABLE MY_DB.MY_SCHEMA_2.EMP;

-- Now this won't work, because "MY_ROLE_CHILD_1" is not the Schema owner, just the object creator inside of it.
GRANT USAGE TO SCHEMA MY_DB.MY_SCHEMA_2 TO ROLE SOME_ROLE;

-- We change to the Schema Owner role
USE ROLE MY_ROLE;

-- Now we can give GRANTs to other roles, because we are in the Schema Owner Role.
GRANT USAGE ON SCHEMA MY_DB.MY_SCHEMA_2 TO ROLE SOME_ROLE;
GRANT USAGE ON TABLE MY_DB.MY_SCHEMA_2.EMP TO ROLE SOME_ROLE;
GRANT SELECT ON TABLE MY_DB.MY_SCHEMA_2.EMP TO ROLE SOME_ROLE;








-- MODULE 31 -- 




-- M31 - Snowflake Partner Connect





-- Partner Connect is a service which expedites 
-- the process of getting up and running with 
-- selected third-party tools.


-- It allows you to easily create trial account with 
-- selected Snowflake business partners and integrate 
-- these accounts with Snowflake.

-- Generally, this option/feature will create some objects
-- in your Snowflake account at the same time a trial/free
-- account is created, in the service you have chosen.




-- MISC --



-- MISC


-- External functions use API Integration 
-- Objects to hold security-related information.

-- API Integration Objects store information 
-- about HTTPS proxy services, including information 
-- about:

-- a) The cloud platform provider

-- b) The type of proxy service

-- c) The identifier and access credentials for a cloud 
--    platform role that has sufficient privileges to use 
--    the proxy service.



-- Currently, Snowflake "Network Policy" objects
-- only support IPv4 IP addresses.


-- The only languages supported by UDFs are JavaScript,
-- Java, Python and SQL.

-- Snowflake recommends, as a minimum, 
-- that ACCOUNTADMIN should be enrolled 
-- in Multi-Factor Authentication.
