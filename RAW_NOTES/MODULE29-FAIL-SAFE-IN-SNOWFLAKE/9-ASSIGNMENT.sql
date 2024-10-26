In this assignment, you have to take 
a decision based on the give scenario.















Prerequisites :

Please go through above lectures on 
fail safe before solving this assignment.

Also go through article above this assignment to check the syntax.



Scenario :

You have been give a task to create database in snowflake.

1. You have to create development database by name, UDEMY_DEV.

2. You have to create UAT database by name , UDEMY_UAT.

3. You have to create PROD database by name , UDEMY_PROD.



-- For DEV database time travel and fail safe is not required.

-- For UAT database it's ok to have time travel of 1 day but fail safe is not required.

-- For PROD database time travel of 5 days is required. Enable fail safe for prod.



-- Going through above requirement can you write commands to create respective database.

-- Questions for this assignment
-- Write your command to create DEV database.


CREATE OR REPLACE TRANSIENT DATABASE UDEMY_DEV;

ALTER DATABASE UDEMY_DEV
SET DATA_RETENTION_TIME_IN_DAYS=0;


-- Write your command to create UAT database.


CREATE OR REPLACE TRANSIENT DATABASE UDEMY_UAT;

ALTER DATABASE UDEMY_DEV
SET DATA_RETENTION_TIME_IN_DAYS=1;

-- Write your command to create PROD database.


CREATE DATABASE UDEMY_PROD;

ALTER DATABASE UDEMY_PROD
SET DATA_RETENTION_TIME_IN_DAYS=5;
