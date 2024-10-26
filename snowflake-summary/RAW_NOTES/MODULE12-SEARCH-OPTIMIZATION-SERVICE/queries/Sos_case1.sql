


CREATE DATABASE DEMO_DB;

-- Create table -- table with 6 billion rows.
CREATE TABLE DEMO_DB.PUBLIC.LINEITEM_SOS
AS
SELECT * FROM
SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.LINEITEM;

-- Clone table structure and data (zero-copy-clone)
CREATE TABLE DEMO_DB.PUBLIC.LINEITEM_NO_SOS CLONE DEMO_DB.PUBLIC.LINEITEM_SOS;

-- update few records in huge table.
UPDATE DEMO_DB.PUBLIC.LINEITEM_SOS 
SET L_COMMENT='GOOD PRODUCTS'
WHERE l_orderkey = '4509487233';

UPDATE DEMO_DB.PUBLIC.LINEITEM_NO_SOS 
SET L_COMMENT='GOOD PRODUCTS'
WHERE l_orderkey = '4509487233';

-- add search optimization on certain columns - this CREATED/USES EXTRA STORAGE, SO BE CAREFUL! (185gb table gets 30gb extra storage, for these 2 columns with SOS)
ALTER TABLE DEMO_DB.PUBLIC.LINEITEM_SOS ADD SEARCH OPTIMIZATION ON EQUALITY(L_COMMENT);

ALTER TABLE DEMO_DB.PUBLIC.LINEITEM_SOS ADD SEARCH OPTIMIZATION ON EQUALITY(l_orderkey);

show tables;


-- shows the difference with search optimization enabled 

-- takes 3 seconds, roughly
select * from DEMO_DB.PUBLIC.lINEITEM_SOS where L_orderkey = '4509487233' 

select * from DEMO_DB.PUBLIC.lINEITEM_SOS where l_COMMENT = 'GOOD PRODUCTS' 

-- takes 43 seconds, roughly
select * from DEMO_DB.PUBLIC.lINEITEM_NO_SOS where L_orderkey = '4509487233'

select * from DEMO_DB.PUBLIC.lINEITEM_NO_SOS where L_COMMENT = 'GOOD PRODUCTS'


