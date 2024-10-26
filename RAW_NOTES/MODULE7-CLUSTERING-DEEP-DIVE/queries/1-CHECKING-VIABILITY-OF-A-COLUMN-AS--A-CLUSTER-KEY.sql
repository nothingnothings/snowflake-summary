






JÁ VIMOS COMO APLICAR CLUSTERING...







COMO EXEMPLO, TEMOS ESTE CÓDIGO:






/**** Check clustering information ***/

DESC TABLE DEMO_DB.PUBLIC.CUSTOMER_NOCLUSTER

create or replace transient TABLE CUSTOMER_CLUSTERED (
	C_CUSTKEY NUMBER(38,0) NOT NULL,
	C_NAME VARCHAR(25) NOT NULL,
	C_ADDRESS VARCHAR(40) NOT NULL,
	C_NATIONKEY NUMBER(38,0) NOT NULL,
	C_PHONE VARCHAR(15) NOT NULL,
	C_ACCTBAL NUMBER(12,2) NOT NULL,
	C_MKTSEGMENT VARCHAR(10),
	C_COMMENT VARCHAR(117)
) CLUSTER BY (C_MKTSEGMENT)

INSERT INTO  DEMO_DB.PUBLIC.CUSTOMER_CLUSTERED
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10000.CUSTOMER;
















--> PARA CHECAR A CLUSTER INFORMATION, TEMOS:








SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_CLUSTERED');












--> ISSO NOS DÁ DETALHES SOBRE COMO NOSSAS MICROPARTITIONS 

SAO DISTRIBUÍDAS NO BACKEND...




{   "cluster_by_keys" : "LINEAR(C_MKTSEGMENT)",  

 "total_partition_count" : 421,   
 
 "total_constant_partition_count" : 0,   
 
 "average_overlaps" : 420.0,  
 
  "average_depth" : 421.0,  
  
   "partition_depth_histogram" : 
   {     "00000" : 0,     "00001" : 0,     "00002" : 0,     "00003" : 0,     "00004" : 0,     "00005" : 0,     "00006" : 0,     "00007" : 0,     "00008" : 0,     "00009" : 0,     "00010" : 0,     "00011" : 0,     "00012" : 0,     "00013" : 0,     "00014" : 0,     "00015" : 0,     "00016" : 0,     "00512" : 421   },   "clustering_errors" : [ ] }


















AQUI PODEMOS VER QUE APLICAMOS 

CLUSTERING NESSA COLUMN DE "C_MKTSEGMENT"..





--> TAMBÉM VISUALIZAMOS QUE 

TEMOS 

6623 PARTITIONS 

NESSA TABLE...








--> no meu caso, 

fiquei com 421 partitions...








--> nao estou com a mesma table do professor 






---> tanto faz, vou acompanhar a aula...






na aula,

temos:









total_partition_count: 6623 




total_constant_partition_count: 6583 





average_overlaps: 0.1803 


average depth: 1.1386














--> VIMOS ESSA "CONSTANT MICROPARTITION"




NO MÓDULO ANTERIOR...






--> e a average_depth dessa table inteira 


é 1.1386...











--> o que isso significa?










--> BEM, VIMOS QUE 

SE __ A MICROPARTITION É UMA CONSTANT 

MICROPARTITION,

SEU DEPTH SERÁ DE 1...








--> LOGO ABAIXO,

TEMOS O HISTOGRAMA 

DA DEPTH PARA AS MICRO PARTITIONS...






TIPO ASSIM:






00000: 0 
00001: 6580,
00002: 0,
00003: 0,
00004: 0,
00005: 0,
00006: 0,
00007: 0,
00008: 0,
00009: 0,
00010: 0,
00011: 0,
00016: 0,
00032: 43





















--> PODEMOS PERCEBER QUE A MAIOR PARTE DAS MICRO PARTITIONS 

TEM UMA DEPTH DE 1...












--> COMO "DEPTH DE 32",

temos apenas 43 micropartitions...














--> OLHANDO ESSA CLUSTERING INFORMATION,


PODEMOS COMPREENDER COMO 


AS MICROPARTITIONS ESTAO DISTRIBUÍDAS 




NO BACKEND....













------> SE AS MICROPARTITIONS ESTAO BEM DISTRIBUÍDAS (ou seja,
com um NÚMERO ELEVADO no "1",

como esse 

"00001": 6580

),



SEU QUERY RESPONSE TIME SERÁ __ ELEVADO__...










--> MAS AGORA DEVEMOS VER UM SEGUNDO CENÁRIO...











--> IMAGINE QUE VC NAO TEM NENHUMA CLUSTER KEY 

APLICADA SOBRE 1 TABLE....







--> VC NAO TEM NENHUMA CLUSTER KEY APLICADA SOBRE 1 
TABLE,

MAS VC __ QUER __ VER __ INFORMACAO 

BASEDA NA COLUMN QUE VC QUER ADICIONAR 

COMO CLUSTERING KEY... -->   TAMBÉM TEMOS UM COMANDO PARA ISSO (



    pq aí vc consegue TESTAR SE ESSA SERIA UMA BOA CLUSTERING KEY,

    TESTAR __ SEM __ APLICAR DE VERDADE...
)












--> PARA ISSO, O PROFESSOR CRIA 1 TABLE 
SEM CLUSTERING KEY...







ex:






CREATE OR REPLACE TRANSIENT TABLE DEMO_DB.PUBLIC.CUSTOMER_NO_CLUSTER 
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER;










-- PARA CHECARMOS SE 1 COLUMN SERIA UMA BOA COMO 

-- CLUSTERING KEY, NO FUTURO,

-- PODEMOS 

-- RODAR ESTE COMANDO:









SELECT SYSTEM$CLUSTERING_INFORMATION('CUSTOMER_NO_CLUSTER', '(C_MKTSEGMENT)');