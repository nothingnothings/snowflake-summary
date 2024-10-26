Please go through lecture 47. Before taking this assignment.



Step 1 :

Create file format object by name , MY_PRACTICE_FILE_FORMAT in DEMO_DB and public schema.





CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.MY_PRACTICE_FILE_FORMAT;


Step 2 :

            Alter above file format and set properties,

            trim_space=true and skip_header=1

            Mention your syntax below.



ALTER FILE FORMAT DEMO_DB.PUBLIC.MY_PRACTICE_FILE_FORMAT
    SET TRIM_SPACE=TRUE
    SKIP_HEADER=1;


Step 3 :

             Drop file format object you created in step 1.


DROP FILE FORMAT DEMO_DB.PUBLIC.MY_PRACTICE_FILE_FORMAT;


Questions for this assignment
Write syntax for step 1. ( create )

Write syntax for step 2. ( alter )

Write syntax for step 3. ( drop )