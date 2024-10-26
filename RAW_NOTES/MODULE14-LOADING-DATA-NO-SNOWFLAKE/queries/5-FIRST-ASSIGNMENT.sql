






Please go through lecture 47. Before taking this assignment.



Step 1 :

Create internal stage object by name , MY_PRACTICE_INTERNAL_STAGE in DEMO_DB and PUBLIC schema.

Mention your syntax.





CREATE OR REPLACE STAGE DEMO_DB.PUBLIC.MY_PRACTICE_INTERNAL_STAGE;





Step 2 :

Alter above stage object to enable file format property TRIM_SPACE=TRUE.

Mention your syntax below.

You can refer to , https://docs.snowflake.com/en/sql-reference/sql/alter-stage.html for more information.


ALTER STAGE DEMO_DB.PUBLIC.MY_PRACTICE_INTERNAL_STAGE
    SET FILE_FORMAT=(
        TRIM_SPACE=TRUE
    );



Step 3 :

Alter stage object again and set copy option property PURGE to true.

Mention your syntax below.

    ALTER STAGE DEMO_DB.PUBLIC.MY_PRACTICE_INTERNAL_STAGE
        SET COPY_OPTIONS=( PURGE=TRUE );



Step 4 :

Write command to drop stage object you created in step 1.

Mention your syntax below,


DROP STAGE DEMO_DB.PUBLIC.MY_PRACTICE_INTERNAL_STAGE;

Questions for this assignment
Write syntax for step 1 ( create stage object )

Write syntax for step 2 ( Alter and set file format property , TRIM_SPACE )

Write syntax for step 3 ( Alter and set copy option property , PURGE )

Write syntax for step 4 ( DROP )