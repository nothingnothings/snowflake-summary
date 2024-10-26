
In this assignment, You will creating a database and sharing it with another account.






Please follow below steps to complete this assignment,

Assume you have two snowflake accounts,

1. gia76901

2. hra87634

You are asked to share database in 1st account with 2nd account.

Database name : Products

Schema : public

Table name : Electronics

share object name : products_s

Questions for this assignment
Write your command to create database.


Write your command to create share object.

Mention below all grant permission you provide to share object.

Mention below your command to add 2nd account to share object.


















1) Write your command to create database.


-- producer account 
CREATE DATABASE PRODUCTS;

-- consumer account
CREATE DATABASE Products FROM SHARE gia76901.PRODUCT_S;


2) Write your command to create share object.



CREATE SHARE PRODUCT_S;



3) Mention below all grant permission you provide to share object.

GRANT USAGE ON DATABASE Products TO SHARE PRODUCT_S;
GRANT USAGE ON SCHEMA Products TO SHARE PRODUCT_S;
GRANT SELECT ON TABLE Products.public.Electronics TO SHARE PRODUCT_S;


4) Mention below your command to add 2nd account to share object.


ALTER SHARE PRODUCT_S
ADD accounts=hra87634;







