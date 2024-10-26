create or replace table t1 (
   id number(8) not null,
   c1 varchar(255) default null
 );
 
-- Enable change tracking on the table.
 alter table t1 set change_tracking = true;

 -- Initialize a session variable for the current timestamp.
 set ts1 = (select current_timestamp());

 insert into t1 (id,c1)
 values
 (1,'red'),
 (2,'blue'),
 (3,'green');

 delete from t1 where id = 1;

 update t1 set c1 = 'purple' where id = 2;

 -- Query the change tracking metadata in the table during the interval from $ts1 to the current time.
 -- Return the full delta of the changes.
 select *
 from t1
   changes(information => default)
   at(timestamp => $ts1);

 +----+--------+-----------------+-------------------+------------------------------------------+
 | ID | C1     | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID                          |
 |----+--------+-----------------+-------------------+------------------------------------------|
 |  2 | purple | INSERT          | False             | 1614e92e93f86af6348f15af01a85c4229b42907 |
 |  3 | green  | INSERT          | False             | 86df000054a4d1dc64d5d74a44c3131c4c046a1f |
 +----+--------+-----------------+-------------------+------------------------------------------+

 -- Query the change tracking metadata in the table during the interval from $ts1 to the current time.
 -- Return the append-only changes.
 select *
 from t1
   changes(information => append_only)
   at(timestamp => $ts1);

 +----+-------+-----------------+-------------------+------------------------------------------+
 | ID | C1    | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID                          |
 |----+-------+-----------------+-------------------+------------------------------------------|
 |  1 | red   | INSERT          | False             | 6a964a652fa82974f3f20b4f49685de54eeb4093 |
 |  2 | blue  | INSERT          | False             | 1614e92e93f86af6348f15af01a85c4229b42907 |
 |  3 | green | INSERT          | False             | 86df000054a4d1dc64d5d74a44c3131c4c046a1f |
 +----+-------+-----------------+-------------------+------------------------------------------+