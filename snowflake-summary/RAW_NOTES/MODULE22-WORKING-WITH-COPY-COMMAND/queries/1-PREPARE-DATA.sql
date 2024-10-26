






NESSA SECTION,

O PROFESSOR VAI NOS MOSTRAR 



1 CENÁRIO EM QUE 

ELE VAI 

BAIXAR DATA LÁ DO "KAGGLE"...










--> VAMOS BAIXAR ESSA DATA,


DAR UMA OLHADA NESSA DATA,

AÍ 


VAMOS 

CRIAR 



1 TABLE NO SNOWFLAKE 


E ENTAO 

VAMOS CARREGAR ESSA TABLE 


NO SNOWFLAKE...












--> DURANTE ESSE PROCESSO,

TEREMOS VÁRIAS ETAPAS....









--> NO PROCESSO DO UPLOAD DA DATA,

TEMOS QUE CONSIDERAR MTAS COISAS...







--. COISAS:





1) COMO ESCOLHER 1 WAREHOUSE 


2) BEST PRACTICES QUANDO REALIZAMOS 

DATA UPLOAD DE VÁRIOS SISTEMAS AO SNOWFLAKE...














VAMOS BAIXAR TAXI TRAJECTORY DATA LÁ DO KAGGLE...










-_> COM ESSA DATA,


DEVEMOS CRIAR 1 TABLE 

NO SNOWFLAKE..












O CÓDIGO FICOU TIPO ASSIM:











CREATE OR REPLACE TRANSIENT TABLE TAXI_DRIVE 
(
    TRIP_ID NUMBER,
    CALL_TYPE VARCHAR(2),
    ORIGIN_CALL NUMBER,
    ORIGIN_STAND NUMBER,
    TAXI_ID NUMBER,
    TIMESTAMP NUMBER,
    DAY_TYPE VARCHAR(10),
    MISSING_DATA BOOLEAN,
    POLYLINE ARRAY
);






A ÚLTIMA COLUMN É DE TYPE "ARRAY"...



baixei a data...










--> PARA UPLOADAR ESSA DATA 

AO SNOWFLAKE ,


PROVAVELMENTE PRECISAREMOS 


DO SNOWSQL...








--> o snowsql ou do aws s3...







--> usaremos o snowflake internal staging area,

A TABLE STAGING AREA,


para aí depois copiarmos isso para dentro da table 


taxi drive...




tipo assim:





put file:///home/arthur/Downloads/archive/train.csv
@DEMO_DB.PUBLIC.%TAXI_DRIVE;
















É CLARO QUE ANTES DEVEMOS FAZER LOGIN 

NO SNOWSQL,
COM ESTE COMANDO:



snowsql -a uu18264.us-east-2.aws -u nothingnothings









ok... rodei o comando de copy, para uploadar 

esse arquivo de 2gb...











mas já fiz errado....



o professor uploadou apenas 1 sample file,

de 100 records...










NA PRÓXIMA LECTURE,

SETTAREMOS ESSE ENVIRONMENT,

CRIAREMOS A TABLE E TENTAREMOS UPLOADAR 

ESSE SAMPLE...