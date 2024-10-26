In this assignment, you will be creating views 

based on given requirement.



















Please go through lecture, Difference between normal view and secure view.



Please go through below requirement,

You have two tables,

1. PRODUCT. ------> size, 500 GB

2 .SALES. ---------> size , 1 TB

-- Business analysts provides you with some complex logic to pull some specific products based on there sales history.

-- Your job is to create a view, based on the provided logic and expose that view to your analytical team which is  handled by Business analysts.



Based on the above requirement, which type of view you will prefer to create and why ?





For the same requirement above, now Business wants to sell this data to different client. In that case, which view you will prefer to create ?

Questions for this assignment


Based on the above requirement, which type of view you will prefer to create and why ?

Normal view, as the Business Analysts are part of our company and are trusted (view-creation command will be exposed)


CREATE OR REPLACE VIEW PRODUCT_VIEW 
AS 
SELECT x, y, z
FROM PRODUCT;


For the same requirement above, now Business wants to sell this data to different client. In that case, which view you will prefer to create ?

Secure view, as the client won't be part of our company, and should not see all details/columns of our original table.

CREATE OR REPLACE SECURE VIEW SECURE_SALES_VIEW 
AS 
SELECT x,y,z 
FROM SALES;

What is the disadvantage of using secure view ?



Secure views degrade performance quite a bit on large tables, as Snowflake's view optimization isn't applied to secure views.