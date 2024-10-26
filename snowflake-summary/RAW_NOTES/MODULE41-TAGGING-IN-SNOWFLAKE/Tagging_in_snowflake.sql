
/************* Lecture: Create and apply tag ******************/

-- Create tag.

create or replace tag demo_db.public.db_data_sensitivity

-- Apply tag to database

create or replace database Revenue with tag (demo_db.public.db_data_sensitivity = 'Red data');
create or replace database marketing with tag (demo_db.public.db_data_sensitivity = 'Orange data');
create or replace database weather with tag (demo_db.public.db_data_sensitivity = 'Green data');

desc tag demo_db.public.db_data_sensitivity;

show tags in schema demo_db.public;
show tags in database demo_db;

alter database Revenue set tag demo_db.public.db_data_sensitivity='confidential'

select system$get_tag('demo_db.public.db_data_sensitivity', 'Revenue', 'database');

select * from snowflake.account_usage.tag_references
order by tag_name, domain, object_id;

/*******************************/



/******************* Lecture :Tag inheritence *******************/

use database revenue;
create or replace schema transport;
   
       create or replace table test_table(a varchar);

create or replace schema media;
create or replace schema supermarket;
create or replace schema realestate;

select system$get_tag('demo_db.public.db_data_sensitivity', 'revenue.transport', 'schema');
select system$get_tag('demo_db.public.db_data_sensitivity', 'transport.test_table', 'table');

//  create or replace schema transport with tag(demo_db.public.cost_center='praco')
//  create or replace schema media with tag(demo_db.public.cost_center='praco')
//  create or replace schema supermarket with tag(demo_db.public.cost_center='praco')
//  create or replace schema realestate with tag(demo_db.public.cost_center='praco')
//

create or replace tag demo_db.public.schema_tables_tag

alter schema transport set tag demo_db.public.schema_tables_tag
alter schema media set tag demo_db.public.schema_tables_tag='kaco',demo_db.public.cost_center='maco'
alter schema test_schema set tag demo_db.public.schema_tables_tag='jambo'

create table phc_test( a varchar )
create table pav_test( b varchar) with tag (demo_db.public.cost_center='junk')


/************************ Lecture: Segregation of duties ****************************/
-- Segregation of duties..

use role useradmin;
create role tag_admin;

use role accountadmin;
grant create tag on schema revenue.media to role tag_admin;
grant apply tag on account to role tag_admin;


use role useradmin;
grant role tag_admin to role sysadmin;

use role tag_admin;
use role sysadmin;
grant usage on warehouse compute_wh to role tag_admin;
grant operate on warehouse compute_wh to role tag_admin;
create database tag;
create schema tag.governance;

grant all privileges on database tag to role tag_admin;
grant usage on database tag to role tag_admin;

grant all privileges on schema tag.governance to role tag_admin;
grant usage on schema tag.governance to role tag_admin;

use role tag_admin;
use database tag;
use schema governance;

/*************************************************/


/************************ Lecture : Prepare environment *************************/
-- Apply tag on tables

use role tag_admin;
use database tag;
use schema governance;

create or replace tag tag.governance.phone_number;
create or replace tag tag.governance.address;
create or replace tag tag.governance.names;
create or replace tag tag.governance.comments;
create or replace tag tag.governance.date;
create or replace tag tag.governance.keys;
create or replace tag tag.governance.region;

use role accountadmin;
use database revenue;
use schema media;

create or replace transient table revenue.media.telecalls as
select * from
"TELECOMMUNICATION_DATA_ATLAS"."TELECOMMUNICATION"."BPU2018"

use schema transport;

create or replace transient table revenue.transport.airline
as select * from
"TRANSPORTATION_DATA_ATLAS"."TRANSPORTATION"."AFATACAP2020" limit 1000


use schema supermarket;

create or replace transient table revenue.supermarket.market_reach as
select * from 
"EYEOTA_REPORTING_PRODUCTION_REPLICABLE_SNOWFLAKE_SECURE_SHARE_1634867393737"."EXTERNAL_SHARES"."EYEOTA_SNOWFLAKE_DATA_MARKETPLACE_LIST";

select * from revenue.supermarket.market_reach limit 100

/*********************************************************************/


/****************************** Lecture : Applying tag *************************/

-- Apply tagging on tables.
use role accountadmin;

grant usage on database revenue to role tag_admin;
grant usage on schema  revenue.media to role tag_admin;
grant usage on schema  revenue.transport to role tag_admin;
grant usage on schema  revenue.supermarket to role tag_admin;

grant select on all tables in schema revenue.media to role tag_admin;
grant select on all tables in schema revenue.transport to role tag_admin;
grant select on all tables in schema revenue.supermarket to role tag_admin;

use role tag_admin;
create or replace tag tag.governance.phone_number
create or replace tag tag.governance.address;
create or replace tag tag.governance.names;
create or replace tag tag.governance.comments;
create or replace tag tag.governance.date;
create or replace tag tag.governance.keys;
create or replace tag tag.governance.region;

create or replace tag tag.governance.transport;
create or replace tag tag.governance.schema_tag;

select * from revenue.transport.airline

alter table revenue.transport.airline modify column "Airlines Name" set tag tag.governance.names='Airline name';
alter table revenue.transport.airline modify column "Airlines RegionId" set tag tag.governance.region='Region of airline';
alter table revenue.transport.airline modify column "Date" set tag tag.governance.date='Airival date';
alter table revenue.transport.airline modify column "Airlines Notes" set tag tag.governance.comments='Traffic control comments';

alter table revenue.transport.airline modify column "Airlines RegionId" unset tag tag.governance.date




 select *
      from table(information_schema.tag_references_all_columns('revenue.transport.airline', 'table'));



alter table revenue.media.telecalls modify column "Country" set tag tag.governance.keys='Country key';
alter table revenue.media.telecalls modify column "Country Name" set tag tag.governance.region='Country name';
alter table revenue.media.telecalls modify column "Topic Notes" set tag tag.governance.comments='Broadband connection notes';
alter table revenue.media.telecalls modify column "Date" set tag tag.governance.date='Connection date';

 select *
      from table(information_schema.tag_references_all_columns('revenue.media.telecalls', 'table'));
      
      
alter table revenue.supermarket.market_reach modify column "COUNTRY" set tag tag.governance.region='Country code';
alter table revenue.supermarket.market_reach modify column "COUNTRY_NAME" set tag tag.governance.region='Country full name';
alter table revenue.supermarket.market_reach2 modify column "DATE" set tag tag.governance.date='promotiondate';



 select *
      from table(information_schema.tag_references_all_columns('revenue.supermarket.market_reach', 'table'));
      
 
select *
      from table(snowflake.account_usage.tag_references_with_lineage('tag.governance.region'));
      
select * from snowflake.account_usage.tag_references
      order by tag_name, domain, object_id;
      
grant  IMPORTED PRIVILEGES  on database snowflake to role tag_admin
      
      
create or replace table ACCOUNT_TAGS as
select * from snowflake.account_usage.tag_references
      order by tag_name, domain, object_id;
      
select * from ACCOUNT_TAGS where tag_name='REGION'

select OBJECT_DATABASE DATABASE,OBJECT_SCHEMA SCHEMA,OBJECT_NAME TABLE_NAME,COLUMN_NAME, TAG_VALUE
from ACCOUNT_TAGS where tag_name='REGION'

select OBJECT_DATABASE DATABASE,OBJECT_SCHEMA SCHEMA,OBJECT_NAME TABLE_NAME,COLUMN_NAME, TAG_VALUE
from ACCOUNT_TAGS where tag_name='DATE'

select OBJECT_DATABASE DATABASE,OBJECT_SCHEMA SCHEMA,OBJECT_NAME TABLE_NAME,COLUMN_NAME, TAG_VALUE
from ACCOUNT_TAGS where tag_name='NAMES'

select OBJECT_DATABASE DATABASE,OBJECT_SCHEMA SCHEMA,OBJECT_NAME TABLE_NAME,COLUMN_NAME, TAG_VALUE
from ACCOUNT_TAGS where tag_name='COMMENTS'


/**********************************************************************************/



/************************** Lecture : Tag based masking policy *****************************/

-- Scenario 1

create or replace masking policy comments_mask as (val string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then '***MASKED***'
    else val
  end;
  
create or replace masking policy name_mask as (val string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then '***MASKED***'
    else val
  end;
  
create or replace masking policy date_mask as (val date) returns date ->
  case
    when current_role() in ('ACCOUNTADMIN') then '1900-01-01'
    else val
  end;
  
/********************** Lecture :  Masking policy by tag value ***************************/

create or replace masking policy date_mask2 as (val string) returns string ->
  case
    when system$get_tag_on_current_column('TAG.GOVERNANCE.DATE') = 'promotiondate' then '***MASKED***'
    else val
  end;

grant all privileges on tag tag.governance.date to role tag_admin

grant all privileges on tag TAG.GOVERNANCE.DATE to role ACCOUNTADMIN

alter tag tag.governance.comments unset
  masking policy comments_mask,
  masking policy date_mask;
  
alter tag tag.governance.date unset
      masking policy date_mask2;

select * from revenue.media.telecalls;
select * from revenue.transport.airline;

grant role tag_admim to role ACCOUNTADMIN
use role tag_admin;

-- Apply at table level.
alter table revenue.transport.airline set tag tag.governance.transport='Indian airline'
alter tag tag.governance.transport unset
        masking policy comments_mask,
        masking policy date_mask;
 
-- Apply at Db level
alter tag demo_db.public.DB_DATA_SENSITIVITY set
        masking policy comments_mask,
        masking policy date_mask;

-- Apply at schema level
alter schema revenue.transport set tag tag.governance.schema_tag='schema governance'
alter tag tag.governance.schema_tag set
        masking policy comments_mask,
        masking policy date_mask;
        
        
select * from revenue.media.telecalls;


-- Scenario 2

create or replace row access policy selected_date_mask4 as (DATE varchar)
returns boolean ->
system$get_tag_on_current_table('TAG.GOVERNANCE.DATE') = 'promotiondate'
--and 'TAG_ADMIN'=current_role()

alter table tag.governance.customer 
   add row access policy TAG.GOVERNANCE.selected_date_mask4 on (C_NAME);
   
alter table tag.governance.market_reach2 
   drop row access policy TAG.GOVERNANCE.selected_date_mask4;

select * from tag.governance.market_reach2 
select * from tag.governance.customer

create or replace transient table customer as select * from
"SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";

drop table customer

alter table tag.governance.customer modify column C_NAME set tag tag.governance.date='promotiondate';

grant modify on table revenue.supermarket.market_reach to role tag_admin

create or replace transient table tag.governance.market_reach2 clone revenue.supermarket.market_reach;

alter table tag.governance.market_reach2 modify column "DATE" set tag tag.governance.date='promotiondate';

show tags

alter tag tag.governance.date unset
      masking policy selected_date_mask
      add row access policy rap_tag_value on (account_number);
      
      
      
/************************* Lecture: Data classification *************************/


SELECT EXTRACT_SEMANTIC_CATEGORIES('revenue.transport.airline');

create or replace table tag.governance.banking as
SELECT * FROM "BANKING_DATA_ATLAS"."BANKING"."BISMS2020";

SELECT
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,  
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  FROM
  TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('tag.governance.banking')::VARIANT)) AS f;

SELECT
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,  
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  FROM
  TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('revenue.transport.airline')::VARIANT)) AS f;


SELECT
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,  
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  FROM
  TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('revenue.transport.airline')::VARIANT)) AS f;
  
  --if the probability is below the 0.80 threshold and the process identified other 
  --possible semantic categories with a probability greater than 0.15
  
  
CALL ASSOCIATE_SEMANTIC_CATEGORY_TAGS('revenue.transport.airline',
                                      EXTRACT_SEMANTIC_CATEGORIES('revenue.transport.airline'));
                                      
                                      
select *
      from table(information_schema.tag_references_all_columns('revenue.transport.airline', 'table'));
      
      
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
    WHERE TAG_NAME = 'PRIVACY_CATEGORY'
    AND TAG_VALUE = 'IDENTIFIER';

