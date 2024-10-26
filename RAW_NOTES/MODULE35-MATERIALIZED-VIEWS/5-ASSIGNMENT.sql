CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.MV_TEST 
AS 
SELECT 10 VALUE 
FROM DUAL;


SELECT * FROM MV_TEST;


SELECT * FROM DUAL;


create materialized view demo_db.public.mv1 as
    select
        sum(value) + 100 val
      from demo_db.public.mv_test;


You are able to execute Step 1 command ?

Yes, as the materialized view is 
referring to a table that already exists,
and only a single table (no multiple tables, no joins).




 create materialized view demo_db.public.mv2 as    
 select
        sum(y) val
      from (
        select
          sum(value) as y
        from demo_db.public.mv_test
      );



No, because the command utilized 
subqueries.


Error:

SQL compilation error: error line 1 at position 22 Invalid materialized view definition: Aggregations on multiple sub-queries are not supported in materialized view definition. Ensure aggregation is done only on one query block.







 create or replace view mv4 as
    select c1 + 10 as c1new
        from (select sum(value) as c1 from demo_db.public.mv_test);




Yes, this command works because it is 
creating a normal view instead of a materialized view (so subqueries are not a problem, in this case).








No, this command cannot be executed, as we are 
trying to use aggregate functions with subqueries, and those operations/features are not supported by materialized views. 

Error:

SQL compilation error: Invalid materialized view: Found invalid function '+' applied over aggregation function 'SUM' in line '2' at position '17'.
