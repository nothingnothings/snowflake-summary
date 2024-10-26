In this assignment,
 You need to list queries based 
 on order of performance.



1. SELECT * FROM CUSTOMER LIMIT 100;

-- we get less rows, less volume of data being processed.

2. SELECT NAME , CUSTOMER FROM CUSTOMER ;

-- we get less amount of columns selected, less volume of data being processed than a full table scan.

3. SELECT * FROM CUSTOMER ;

-- we select entire table, worst performance possible, greatest amount of volume being processed/retrieved.