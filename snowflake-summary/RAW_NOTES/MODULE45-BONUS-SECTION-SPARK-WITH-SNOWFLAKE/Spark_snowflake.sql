— Create table in snowflake —

SELECT * FROM DEMO_DB.PUBLIC.CUSTOMER

CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.CUSTOMER
AS
SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF001"."CUSTOMER"

————


-- Run spark notebook

docker run -it --rm -p 8888:8888 pradeephc0671/snowflakespark jupyter notebook --allow-root --ip 0.0.0.0


import findspark
findspark.init("/spark/spark-2.4.6-bin-hadoop2.7")

import pyspark
sc = spark.SparkContext(appName = "Test")
sc.master



-- Run spark with snowflake ( shell )

docker run -u root -it --rm -p 8080:8080  pradeephc0671/snowflakespark   /spark/spark-2.4.6-bin-hadoop2.7/bin/pyspark --master local[2] --jars /spark/snowflake-jdbc-3.4.2.jar,/spark/spark-snowflake_2.11-2.2.8-spark_2.0.jar --packages org.apache.hadoop:hadoop-aws:3.2.1


/********** Try querying data from snowflake *************/


from pyspark import SparkConf, SparkContext
from pyspark.sql import SQLContext
from pyspark.sql.types import *
from pyspark import SparkConf, SparkContext

sc = SparkContext("local", "Simple App")
spark = SQLContext(sc)

sfOptions = {
  "sfURL" : "ega46122.us-east-1.snowflakecomputing.com",
  "sfUser" : "pradeep",
  "sfPassword" : “<your pwd >“,
  "sfDatabase" : "DEMO_DB",
  "sfSchema" : "PUBLIC",
  "sfWarehouse" : "COMPUTE_WH"
}

SNOWFLAKE_SOURCE_NAME = "net.snowflake.spark.snowflake"

df = spark.read.format(SNOWFLAKE_SOURCE_NAME) \
  .options(**sfOptions) \
  .option("query",  "SELECT * FROM DEMO_DB.PUBLIC.CUSTOMER") \
  .load()
  
  