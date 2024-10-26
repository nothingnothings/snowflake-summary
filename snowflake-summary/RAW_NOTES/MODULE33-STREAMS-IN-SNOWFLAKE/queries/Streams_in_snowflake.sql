-- Create a table to store the names and fees paid by members of a gym
create or replace table members (
  id number(8) not null,
  name varchar(255) default null,
  fee number(3) null
);


-- Create a stream to track changes to date in the MEMBERS table
create or replace stream member_check on table members;


-- Create a table to store the dates when gym members joined
create or replace table signup (
  id number(8),
  dt date
  );

insert into members (id,name,fee)
values
(1,'Joe',0),
(2,'Jane',0),
(3,'George',0),
(4,'Betty',0),
(5,'Sally',0);

insert into signup
values
(1,'2018-01-01'),
(2,'2018-02-15'),
(3,'2018-05-01'),
(4,'2018-07-16'),
(5,'2018-08-21');

-- The stream records the inserted rows
select * from member_check;

+----+--------+-----+-----------------+-------------------+------------------------------------------+
| ID | NAME   | FEE | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID                          |
|----+--------+-----+-----------------+-------------------+------------------------------------------|
|  1 | Joe    |   0 | INSERT          | False             | d200504bf3049a7d515214408d9a804fd03b46cd |
|  2 | Jane   |   0 | INSERT          | False             | d0a551cecbee0f9ad2b8a9e81bcc33b15a525a1e |
|  3 | George |   0 | INSERT          | False             | b98ad609fffdd6f00369485a896c52ca93b92b1f |
|  4 | Betty  |   0 | INSERT          | False             | e554e6e68293a51d8e69d68e9b6be991453cc901 |
|  5 | Sally  |   0 | INSERT          | False             | c94366cf8a4270cf299b049af68a04401c13976d |
+----+--------+-----+-----------------+-------------------+------------------------------------------+

-- Apply a $90 fee to members who joined the gym after a free trial period ended:
merge into members m
  using (
    select id, dt
    from signup s
    where datediff(day, '2018-08-15'::date, s.dt::date) < -30) s
    on m.id = s.id
  when matched then update set m.fee = 90;

select * from members;

+----+--------+-----+
| ID | NAME   | FEE |
|----+--------+-----|
|  1 | Joe    |  90 |
|  2 | Jane   |  90 |
|  3 | George |  90 |
|  4 | Betty  |   0 |
|  5 | Sally  |   0 |
+----+--------+-----+

-- The stream records the updated FEE column as a set of inserts
-- rather than deletes and inserts because the stream contents
-- have not been consumed yet
select * from member_check;

+----+--------+-----+-----------------+-------------------+------------------------------------------+
| ID | NAME   | FEE | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID                          |
|----+--------+-----+-----------------+-------------------+------------------------------------------|
|  1 | Joe    |  90 | INSERT          | False             | 957e84b34ef0f3d957470e02bddccb027810892c |
|  2 | Jane   |  90 | INSERT          | False             | b00168a4edb9fb399dd5cc015e5f78cbea158956 |
|  3 | George |  90 | INSERT          | False             | 75206259362a7c89126b7cb039371a39d821f76a |
|  4 | Betty  |   0 | INSERT          | False             | 9b225bc2612d5e57b775feea01dd04a32ce2ad18 |
|  5 | Sally  |   0 | INSERT          | False             | 5a68f6296c975980fbbc569ce01033c192168eca |
+----+--------+-----+-----------------+-------------------+------------------------------------------+

-- Create a table to store member details in production
create or replace table members_prod (
  id number(8) not null,
  name varchar(255) default null,
  fee number(3) null
);

-- Insert the first batch of stream data into the production table
insert into members_prod(id,name,fee) select id, name, fee from member_check where metadata$action = 'INSERT';

-- The stream position is advanced
select * from member_check;

+----+------+-----+-----------------+-------------------+-----------------+
| ID | NAME | FEE | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID |
|----+------+-----+-----------------+-------------------+-----------------|
+----+------+-----+-----------------+-------------------+-----------------+

-- Access and lock the stream
begin;

-- Increase the fee paid by paying members
update members set fee = fee + 17 where fee > 0;

+------------------------+-------------------------------------+
| number of rows updated | number of multi-joined rows updated |
|------------------------+-------------------------------------|
|                      3 |                                   0 |
+------------------------+-------------------------------------+

-- These changes are not visible because the change interval of the stream object starts at the current offset and ends at the current transactional time point, which is the beginning time of the transaction
select * from member_check;

+----+------+-----+-----------------+-------------------+-----------------+
| ID | NAME | FEE | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID |
|----+------+-----+-----------------+-------------------+-----------------|
+----+------+-----+-----------------+-------------------+-----------------+

-- Commit changes
commit;

-- The changes surface now because the stream object uses the current transactional time as the end point of the change interval that now includes the changes in the source table
select * from member_check;

+----+--------+-----+-----------------+-------------------+------------------------------------------+
| ID | NAME   | FEE | METADATA$ACTION | METADATA$ISUPDATE | METADATA$ROW_ID                          |
|----+--------+-----+-----------------+-------------------+------------------------------------------|
|  1 | Joe    | 105 | INSERT          | True              | 123a45b67cd0e8f012345g01abcdef012345678a |
|  2 | Jane   | 105 | INSERT          | True              | 456b45b67cd1e8f123456g01ghijkl123456779b |
|  3 | George | 105 | INSERT          | True              | 567890c89de2f9g765438j20jklmn0234567890d |
|  1 | Joe    |  90 | DELETE          | True              | 123a45b67cd0e8f012345g01abcdef012345678a |
|  2 | Jane   |  90 | DELETE          | True              | 456b45b67cd1e8f123456g01ghijkl123456779b |
|  3 | George |  90 | DELETE          | True              | 567890c89de2f9g765438j20jklmn0234567890d |
+----+--------+-----+-----------------+-------------------+------------------------------------------+


-- adding a task to consume stream...

CREATE TASK mytask1
  WAREHOUSE = mywh
  SCHEDULE = '1 minute'
WHEN
  SYSTEM$STREAM_HAS_DATA('member_check')
AS
  insert into members_prod(id,name,fee) select id, name, fee from member_check where metadata$action = 'INSERT';

select * from members_prod

-- ofset check.

select SYSTEM$STREAM_GET_TABLE_TIMESTAMP('member_check')

select to_timestamp('1586582147496')  -- 2020-04-11 05:15:47.496

select to_timestamp('1586582761213')  -- 2020-04-11 05:26:01.213


--- multiple stream objects..

create or replace stream member_check2 on table members;

select * from member_check2; 