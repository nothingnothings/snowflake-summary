





OK... 




NAS PRÓXIMAS AULAS,


DISCUTIREMOS DIFERENTES MANEIRAS DE CARREGAR 

UNSTRUCTURED DATA 



NAS TABLES DO SNOWFLAKE...











-> O METHOD 1 É ESTE:








1) data inicial está armazenada 

NO AWS S3...

(aws s3 external staging area)





2) CRIACAO DE TABLE DO SNOWFLAKE,

DE TIPO VARIANT (e de tipo TRANSIENT, para 
nao gastar tanta storage com fail safe e time travel)...




3) REALIZAMOS O PARSE DA DATA, 

COM 1 QUERY, EM CIMA DA COLUMN DE DATA TYPE "VARIANT",

que agora está preenchida...










--> VEREMOS ESSE APPROACH 1 COM 1 EXEMPLO...













PRIMEIRAMENTE CRIAREMOS 1 FILE FORMAT:












CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.JSON_FORMAT
    TYPE=JSON;






CREATE OR REPLACE TABLE BOOK (v VARIANT);









INSERT INTO book 
SELECT 
PARSE_JSON (
    '{
   "_id":{
      "$oid":"595c2c59a7986c0872002043"
   },
   "mdate":"2017-05-24",
   "author":[
      "Injoon Hong",
      "Seongwook Park",
      "Junyoung Park",
      "Hoi-Jun Yoo"
   ],
   "ee":"https://doi.org/10.1109/ASSCC.2015.7387453",
   "booktitle":"A-SSCC",
   "title":"A 1.9nJ/pixel embedded deep neural network processor for high speed visual attention in a mobile vision recognition SoC.",
   "pages":"1-4",
   "url":"db/conf/asscc/asscc2015.html#HongPPY15",
   "year":"2015",
   "type":"inproceedings",
   "_key":"conf::asscc::HongPPY15",
   "crossref":[
      "conf::asscc::2015"
   ]
}'
);






--> VAMOS CARREGAR ESSA file para 

dentro da table...













--> MAS VAMOS FAZER ISSO A PARTIR DE 1 FILE,

QUE COLOCAREMOS NO AWS S3...








--> É A FILE DE dbltp.json ---__> 753 MEGABYTES...











--> TENTAREMOS CARREGAR ESSA FILE NA SNOWFLAKE TABLE...








--> ANTES DE 


CARREGARMOS ESSA FILE NA SNOWFLAKE TABLE,



PRECISAMOS PREPARAR INTEGRATION OBJECT,

FILE FORMAT 

E STAGE 

OBJECT...









--> DEPOIS QUE FIZERMOS TUDO ISSO,

DEVEMOS DAR 1 OLHADA NA JSON FILE...










--> O PROFESSOR PEGOU 1 SAMPLE,


que é 


este document:







INSERT INTO book 
SELECT 
PARSE_JSON (
    '{
   "_id":{
      "$oid":"595c2c59a7986c0872002043"
   },
   "mdate":"2017-05-24",
   "author":[
      "Injoon Hong",
      "Seongwook Park",
      "Junyoung Park",
      "Hoi-Jun Yoo"
   ],
   "ee":"https://doi.org/10.1109/ASSCC.2015.7387453",
   "booktitle":"A-SSCC",
   "title":"A 1.9nJ/pixel embedded deep neural network processor for high speed visual attention in a mobile vision recognition SoC.",
   "pages":"1-4",
   "url":"db/conf/asscc/asscc2015.html#HongPPY15",
   "year":"2015",
   "type":"inproceedings",
   "_key":"conf::asscc::HongPPY15",
   "crossref":[
      "conf::asscc::2015"
   ]
}'
);











AS COLUMNS QUE QUEREMOS COLOCAR 


EM 1 TABLE DO SNOWFLAKE SAO:








OID, AUTHOR, TITLE, BOOKTITLE, YEAR, TYPE...












SELECT 
v:"_id"::"$oid" AS OID,
v:"author"::array AS AUTHOR,
v:"title"::string AS TITLE,
v:"booktitle"::string AS BOOKTITLE,
v:"year"::string AS YEAR
FROM @your_stage
(file_format=>MY_JSON_S3_FORMAT);











É CLARO QUE PRECISAMOS DE UM STAGING OBJECT,

TIPO ASSIM:









CREATE OR REPLACE STAGE MY_S3_UNLOAD_STAGE
STORAGE_INTEGRATION=S3_INTEGRATION
url='s3://hartfordstar/'
FILE_FORMAT=MY_JSON_S3_FORMAT;












O FILE FORMAT:









CREATE OR REPLACE FILE FORMAT MY_CSV_S3_FORMAT
TYPE=JSON;











CERTO...









PRECISAMOS DESSE FILE_FORMAT



EM FORMATO JSON...







--> SE QUEEREMOS 



FAZER QUERY DA NOSSA DATA DIRETAMENTE,



SEM FAZER LOAD DA MESMA,

PODEMOS A QUERIAR 




COM ESTES COMANDOS:






-- query from EXTERNAL STAGING AREA...
SELECT
$1
FROM @MY_S3_UNLOAD_STAGE/dblp.json
(file_format=>JSON_FORMAT);














---> PODEMOS CRIAR 1 TABLE DE STAGING,


PARA PEGAR ESSA DATA RAW, COLOCAR EM 1 COLUMN...









--> outra coisa que devemos ter em mente é que 


CADA RECORD (JSON, ou qualquer outro format)


PODE SEGURAR __ ATÉ __ 16 MEGABYTES DE DATA...







EX:





CREATE OR REPLACE TRANSIENT TABLE BOOK_JSON_RAW (
   book variant
);










DEPOIS DISSO, VAMOS COPIAR A DATA 




DO AWS S3 (UNSTRUCTURED data)



PARA DENTRO 


DESSA STAGING TABLE...











TIPO ASSIM:













COPY INTO BOOK_JSON_RAW
FROM 
@MY_S3_UNLOAD_STAGE
FILE_FORMAT=JSON_FORMAT;













--> PODEMOS RODAR 1 SELECT NA DATA,

ASSIM:




SELECT * fROM BOOK_JSON_RAW;










--> PODEMOS VER TODA A JSON DATA QUE FOI CARREGADA,



CADA RECORD QUE FOI CARREGADO....











--> A PRÓXIMA ETAPA 

É 

CONVERTER 



ESSA DATA TODA,




TRANSFORMAR EM DATA EM 1 TABLE NORMAL 
SQL.....






--> PARA ISSO, 


PODEMOS TESTAR, ANTERIORMENTE,

RODANDO ASSIM:






SELECT 
book:"_id"::"$oid" AS OID,
book:"author"::array AS AUTHOR,
book:"title"::string AS TITLE,
book:"booktitle"::string AS BOOKTITLE,
book:"year"::string AS YEAR,
book:"year"::string AS TYPE
FROM BOOK_JSON_RAW; -- raw staging table...














--> AÍ PODEMOS CRIAR 1 NOVA TABLE,

PERMANENT, EM CIMA DESSA TABLE,

TIPO ASSIM:










CREATE OR REPLACE BOOK_DATA 
AS 
SELECT 
book:"_id"::"$oid" AS OID,
book:"author"::array AS AUTHOR,
book:"title"::string AS TITLE,
book:"booktitle"::string AS BOOKTITLE,
book:"year"::string AS YEAR,
book:"year"::string AS TYPE
FROM BOOK_JSON_RAW; 





------------------------------------










OK, ESSE É O PRIMEIRO METHOD DE LOADING...







RECAPITULANDO:




1) data inicial (json/csv) está armazenada 

NO AWS S3...

(aws s3 external staging area)





2) CRIACAO DE TABLE DO SNOWFLAKE,

DE TIPO VARIANT (e de tipo TRANSIENT, para 
nao gastar tanta storage com fail safe e time travel)...




3) depois de rodar 1 select em cima da 
table com column de type variant (testando 
as transformacoes de data, como se o result set fosse 
1 nova table)

REALIZAMOS O PARSE DA DATA, 

COM 1 QUERY (create or replace 
table as xxx), EM CIMA DESSA 
STAGING, TRANSIENT TABLE, EM 
CIMA DESSA COLUMN DE DATA TYPE "VARIANT",
que agora está preenchida...




















MAS AGORA DISCUTIREMOS ALGUMAS DAS VANTAGENS E 
DESVANTAGENS DESSE METHOD..
















VANTAGENS:



1) QUANDO O SNOWFLAKE 
FAZ LOAD DE "SEMI-STRUCTURED DATA", 
ELE ___ OPTIMIZA__ A MANEIRA PELA QUAL 

ESSA DATA É ARMAZENADA INTERNAMENTE _____ POR MEIO __ 


DA __ DESCOBERTA__ DOS ATTRIBUTES_ E STRUCTURE 

EXISTENTES DENTRO DA DATA... ELE ENTAO USA ESSE CONHECIMENTO 
PARA OPTIMIZAR A MANEIRA PELA QUAL A DATA É STORED.... 


--> O SNOWFLAKE TAMBÉM PROCURA POR ATTRIBUTES 
REPETIDOS AO LONGO DOS RECORDS, ORGANIZANDO E ARMAZENANDO 
ESSES ATTRIBUTES REPETIDOS ___ SEPARADAMENTE__. ISSO PERMITE/ENABLE 

UMA __ MELHOR COMPRESSAO E 1 ACESSO MAIS RÁPIDO,
SIMILARMENTE à OPTIMIZACAO DE STORAGE DE COLUMNS 

OF DATA DE COLUMNAR DATABASES....







--> BASICAMENTE, 


O SNOWFLAKE TOMA CONTA DE BOA PARTE DA OPTIMIZACAO,


SE VC
 
 INSERE DATA NESSA COLUMN DE TYPE "VARIANT"...









 2)  STATISTICS SOBRE AS SUB COLUMNS SAO 

 TAMBÉM COLETADAS, CALCULADAS E ARMAZENADAS 

 NO REPOSITÓRIO DE METADATA DO SNOWFLAKE... ISSO

 CONFERE AO SNOWFLAKE "ADVANCED QUERY OPTIMIZER METADATA" 

 SOBRE A SEMI-STRUCTURED DATA, para optimizar acesso 
 a ela...


 ESSAS ESTATÍSTICAS PERMITEM AO OPTIMIZER USAR "PRUNING"
 PARA __ MINIMIZAR 

 A QUANTIDADE DE DATA NECESSÁRIA PARA O ACESSO,


 RESULTANDO EM UM AUMENTO DA VELOCIDADE 
 DE RETURN DE SUA DATA....









//////////////////////////////////////////////////

 todas essas optimizacoes acontecem quando FAZEMOS 

 LOAD DA UNSTRUCTURED DATA (json) PARA DENTRO 


 DA COLUMN DE TYPE "VARIANT"...

 /////////////////////////////////////////////////







 nosso trabalho é apenas o load da UNSTRUCTURED 
 data para dentro da column de type "variant"...














 DESVANTAGENS:






 1) AINDA QUE VC TENHA UMA __PROMESSA__, POR PARTE 

 DO SNOWFLAKE,

 SOBRE 

 ""OPTIMIZED STORAGE OF UNSTRUCTURED DATA"",



 NEM SEMPRE É UMA BOA IDEIA PARSEAR A DATA.... 




ISSO PQ, À MEDIDA QUE O VOLUME DE DATA AUMENTA,

A PERFORMANCE PODE DECAIR BASTANTE...









--> SEU VOLUME DE DATA VAI AUMENTAR A CADA DIA....



AINDA QUE VC TENHA BOA OPTIMIZATION, COM O SNOWFLAKE,

SUA PERFORMANCE VAI CAIR, COM O TEMPO...










nesse primeiro "method' do professor,

ele NAO CONVERTEU A UNSTRUCTURED DATA (

   nessa table de "variant"
) 


PARA UMA TABLE COMUM, PERMANENT (

   e é por isso que esse approach é ruim,

   ficamos dependendo dessas optimizacoes do 

   snowflake em cima de unstructured data...
)