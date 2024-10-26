create or replace table source_t(id int, name string);


create or replace  stream delta_s on table source_t;

select * from delta_s

-- Insert 3 rows into the source table.
insert into source_t values (0, 'mharlie brown');
insert into source_t values (1, 'lucy');
insert into source_t values (2, 'linus');

insert into source_t values (3, 'mharlie brown');
insert into source_t values (4, 'kucy');
insert into source_t values (5, 'pinus');

update source_t set name ='llucy' where id=1

delete from source_t where id=0

-- Create consumer table

create or replace  
table target_t(id int, name string, stream_type string default null, rec_version number default 0,REC_DATE TIMESTAMP_LTZ);


update source_t set name ='klucy' where id=1

 -- updating task
CREATE TASK tgt_merge
  WAREHOUSE = compute_wh
  SCHEDULE = '1 minute'
WHEN
  SYSTEM$STREAM_HAS_DATA('delta_s')
AS
merge into target_t t
using delta_s s 
on t.id=s.id and (metadata$action='DELETE')
when matched and metadata$isupdate='FALSE' then update set rec_version=9999, stream_type='DELETE'
when matched and metadata$isupdate='TRUE' then update set rec_version=rec_version-1
when not matched then insert  (id,name,stream_type,rec_version,REC_DATE) values(s.id, s.name, metadata$action,0,CURRENT_TIMESTAMP() )

ALTER TASK tgt_merge RESUME;

select * from target_t
  
 