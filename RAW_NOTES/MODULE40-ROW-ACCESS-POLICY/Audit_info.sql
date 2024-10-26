use role policyadmin;
use database governance;
use schema row_access_policy;

select *
from table(information_schema.policy_references(policy_name => 'patient_policy'));


select *
  from table(information_schema.policy_references(ref_entity_name => 'claims.pharmacy.patient', ref_entity_domain => 'table'));
 

use role accountadmin;
use database snowflake;
use schema account_usage;

select *
from row_access_policies-- where deleted is null
order by created
;
