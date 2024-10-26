/*********************************************************************************************/

-- DIGNOSIS CODE REDACTION


--drop masking policy diagnosis_code_mask

create or replace masking policy diagnosis_code_mask as (val varchar) returns string ->
  case when current_role() in ('ANALYST','CONTRACTOR') then 
        case when val in ('G9382','O312','O3120','O3120X1','7681','39791') then  NULL
         else
            case when val in ('S55091D', 'S82421H', 'S37828D', 'J239', 'R019') then substring(val,1,3)
             else
                case when val in ('Y09', 'Y09', 'V3101', 'V3101', '79913', 'Y389X1A', 'E9688') then '00'
                 else
                   val
                    end
               end
           end      
    else
      val
     
  end;
 
  
create or replace masking policy state_code_mask as (val varchar) returns string ->
  case when current_role() in ('ANALYST','CONTRACTOR') then 
        case when val in ('AA', 'DU', 'GV', 'MH', 'NP', 'OT', 'TT') then  NULL
         else
         val
             end       
    else
      val
  end;
  

create or replace masking policy zip_code_mask as (val number) returns number ->
  case when current_role() in ('ANALYST','CONTRACTOR') then 
        case when val in ('967', '431', '965', '963', '966', '945') then  NULL
         else
         val
             end       
    else
      val
  end;

/*********** Alter masking policy **********************/

alter table if exists patient modify column diagnosis set masking policy diagnosis_code_mask;

alter table if exists patient modify column state set masking policy state_code_mask;

alter table if exists patient modify column zip set masking policy zip_code_mask;




show tables*

select * from patient


alter masking policy diagnosis_code_mask set body ->
  case when current_role() in ('ANALYST','CONTRACTOR','ACCOUNTADMIN') then 
        case when val in ('G9382','O312','O3120','O3120X1','7681','39791') then  NULL
         else
            case when val in ('S55091D', 'S82421H', 'S37828D', 'J239', 'R019') then substring(val,1,3)
             else
                case when val in ('Y09', 'Y09', 'V3101', 'V3101', '79913', 'Y389X1A', 'E9688') then '00'
                 else
                   val
                    end
               end
           end      
    else
      val
     
  end;
 

/*********** revoke policy **********************/

alter table if exists patient modify column diagnosis unset masking policy;

alter table if exists patient modify column state unset masking policy;
