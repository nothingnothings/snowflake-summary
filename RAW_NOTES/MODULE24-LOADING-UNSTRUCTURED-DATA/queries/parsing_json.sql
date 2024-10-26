/***************************** Parsing Json *********************/

create or replace table json_demo (v variant);

select * from json_demo

insert into json_demo
select
parse_json(
'{
   "fullName":"Johnny Appleseed",
   "age":42,
   "gender":"Male",
   "phoneNumber":{
      "areaCode":"415",
      "subscriberNumber":"5551234"
   },
   "children":[
      {
         "name":"Jayden",
         "gender":"Male",
         "age":"10"
      },
      {
         "name":"Emma",
         "gender":"Female",
         "age":"8"
      },
      {
         "name":"Madelyn",
         "gender":"Female",
         "age":"6"
      }
   ],
   "citiesLived":[
      {
         "cityName":"London",
         "yearsLived":[
            "1989",
            "1993",
            "1998",
            "2002"
         ]
      },
      {
         "cityName":"San Francisco",
         "yearsLived":[
            "1990",
            "1993",
            "1998",
            "2008"
         ]
      },
      {
         "cityName":"Portland",
         "yearsLived":[
            "1993",
            "1998",
            "2003",
            "2005"
         ]
      },
      {
         "cityName":"Austin",
         "yearsLived":[
            "1973",
            "1998",
            "2001",
            "2005"
         ]
      }
   ]
}');


-- Let's start parsing data.

select v:fullName from json_demo;

-- Cast name to string data type


select v:fullName::string as full_name
from json_demo;


-- Let's parse more to get age and gender

select
v:fullName::string as full_name,
v:age::int as age,
v:gender::string as gender
from json_demo;


-- Let's parse more nested json nodes

select
v:phoneNumber.areaCode::string as area_code,
v:phoneNumber.subscriberNumber::string as subscriber_number
from json_demo;


select
v:phoneNumber.areaCode::string as area_code,
v:phoneNumber.subscriberNumber::string as subscriber_number,
v:phoneNumber.extensionNumber::string as extension_number
from json_demo;


-- Let's parse array in json

select v:children[0].name::string from json_demo
union all
select v:children[1].name::string from json_demo
union all
select v:children[2].name::string from json_demo;

-- Table functions

select
f.value:name::string as child_name,
f.value:gender::string as child_gender,
f.value:age::string as child_age
from json_demo, table(flatten(v:children)) f;


select
v:fullName::string as parent_name,
f.value:name::string as child_name,
f.value:gender::string as child_gender,
f.value:age::string as child_age
from json_demo, table(flatten(v:children)) f;

-- How many children John have

select
v:fullName::string as Parent_Name,
array_size(v:children) as Number_of_Children
from json_demo;


-- How many cities john lived and how many children he has

select
v:fullName::string as Parent_Name,
array_size(v:citiesLived) as Cities_lived_in,
array_size(v:children) as Number_of_Children
from json_demo;


-- Parse array within array.

select
cl.value:cityName::string as city_name,
yl.value::string as year_lived
from json_demo,
table(flatten(v:citiesLived)) cl,        -- Higher array
table(flatten(cl.value:yearsLived)) yl;  -- Nested array


-- attach parent name 

select
v:fullName::string as parent_name,
cl.value:cityName::string as city_name,
yl.value::string as year_lived
from json_demo,
table(flatten(v:citiesLived)) cl,
table(flatten(cl.value:yearsLived)) yl


select
v:fullName::string as parent_name,
cl.value:yearsLived
from json_demo,
table(flatten(v:citiesLived)) cl,
table(flatten(cl.value:yearsLived)) yl


---- Aggregation

select
 cl.value:cityName::string as city_name,
 count(*) as year_lived
from json_demo,
 table(flatten(v:citiesLived)) cl,
 table(flatten(cl.value:yearsLived)) yl
group by 1;


--  Filter data

select
 cl.value:cityName::string as city_name,
 count(*) as years_lived
from json_demo,
 table(flatten(v:citiesLived)) cl,
 table(flatten(cl.value:yearsLived)) yl
where city_name = 'Portland'
group by 1;

