/************* Mapping tables *******************/

F00-- Dementia in Alzheimer disease
W13---Fall from, out of or through building or structure
J09---Influenza and pneumonia
H03--- Disorders of eyelid in diseases classified elsewhere
F70--- Mental retardation
H60--- Diseases of external ear
H30--- Disorders of choroid and retina
E65--  Obesity and other hyperalimentation
O81.0-- Low forceps delivery


use role policyadmin;

create table ICDCODES(ICD varchar , TYPE varchar);

insert into ICDCODES
values('F70','red'),
('W13','red'),
('F00','red');

insert into ICDCODES
values('J09','orange'),
('O81.0','orange'),
('H60','orange');

insert into ICDCODES
values('E65','green'),
('H03','green'),
('H30','green');

create table access_ctl_tbl(role_name varchar, access_for varchar)

insert into access_ctl_tbl
values('UHG','green');

insert into access_ctl_tbl
values('ETL_DEV','green'),
('ETL_DEV','orange');

select * from ICDCODES;
select * from access_ctl_tbl;


select a.* from
governance.row_access_policy.access_ctl_tbl a
inner join 
governance.row_access_policy.icdcodes b
on a.access_for=b.type
where a.role_name='UHG' and ICD='J09'

drop row access policy governance.row_access_policy.patient_policy;

create or replace row access policy governance.row_access_policy.patient_policy as (icdcode varchar) returns boolean ->
       exists (
                select a.* from
                governance.row_access_policy.access_ctl_tbl a
                inner join 
                governance.row_access_policy.icdcodes b
                on a.access_for=b.type
                where a.role_name=current_role() and b.icd=icdcode
          )
;

alter table claims.pharmacy.patient add row access policy governance.row_access_policy.patient_policy on (icdcode);

use role uhg;
use database claims;
use schema pharmacy;

select * from patient;

