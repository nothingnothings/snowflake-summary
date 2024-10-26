use role sysadmin;
create database claims;
create schema pharmacy;

create table patient
(
Name varchar,
age integer,
icdcode varchar,
zip_code varchar,
city varchar,
provider_name varchar

)
insert into patient
values('john','12','E910','49715','Michigan','CVS Health Corp'),
('Simon','25','F00','43009','Ohio','McKesson Corp'),
('Mike','58','W13','61727','Illinois','Cigna Corp'),
('Andrew','32','J09','39425','Mississipp','UnitedHealth Group Inc'),
('Brian','40','H03','39425','Mississipp','UnitedHealth Group Inc'),
('David','37','F70','63013','Beaufort','UnitedHealth Group Inc'),
('Dom','23','H60','63013','Beaufort','UnitedHealth Group Inc'),
('Jack','30','H30','46030','Indiana','Cigna Corp'),
('Doli','35','E65','64722','Amoret','Cigna Corp'),
('Padma','50','O81.0','64722','Amoret','Cigna Corp');

F00-- Dementia in Alzheimer disease
W13---Fall from, out of or through building or structure
J09---Influenza and pneumonia
H03--- Disorders of eyelid in diseases classified elsewhere
F70--- Mental retardation
H60--- Diseases of external ear
H30--- Disorders of choroid and retina
E65-- Obesity and other hyperalimentation
O81.0-- Low forceps delivery

create or replace row access policy patient_policy as (icdcode varchar) returns boolean ->
           CASE WHEN icdcode='F70' THEN FALSE ELSE TRUE END
;

create or replace row access policy patient_policy as (icdcode varchar) returns boolean ->
           CASE WHEN icdcode='F70' THEN 'F60' ELSE icdcode END
;

alter table claims.pharmacy.patient add row access policy patient_policy on (icdcode);
alter table claims.pharmacy.patient add row access policy patient_policy_2 on (icdcode,zip_code);
alter table claims.pharmacy.patient drop row access policy patient_policy_2; 

drop row access policy  governance.row_access_policy.patient_policy

-- Create another policy and attach
create or replace row access policy patient_policy_2 as (icdcode varchar , zip_code varchar) returns boolean ->
           CASE WHEN icdcode='F70' OR ZIP_CODE='61727' THEN FALSE ELSE TRUE END
;
alter table claims.pharmacy.patient add row access policy patient_policy_2 on (icdcode,zip_code);


create or replace row access policy patient_policy as (icdcode varchar) returns boolean ->
      CASE WHEN 'SYSADMIN'=current_role() THEN TRUE ELSE
                                                    CASE WHEN icdcode='F70' THEN FALSE ELSE TRUE END
                                                    END
;


/************************** Grant to another role *************************/

use role securityadmin;
create role UHG;
use role sysadmin;
grant usage on database claims to role UHG;
grant usage on schema pharmacy to role UHG;
grant select on table patient to role UHG;
grant usage on warehouse compute_wh to role UHG;
grant operate on warehouse compute_wh to role UHG;
grant role UHG to role securityadmin;
use role UHG;
use database claims;
use schema pharmacy;

select * from patient;

