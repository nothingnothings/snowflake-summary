/************************************************/

use role policyadmin;
use database governance;
use schema row_access_policy;

insert into access_ctl_tbl
values('ETL_DEV','green'),
('ETL_DEV','orange');

use role etl_dev;
use database claims;
use schema pharmacy;

show tables;

DELETE FROM PATIENT WHERE ICDCODE='F70'
UPDATE  PATIENT SET ICDCODE='F700' WHERE ICDCODE='F70' 
UPDATE PATIENT SET CITY='MISSI' WHERE ZIP_CODE='39425';

select * from patient

