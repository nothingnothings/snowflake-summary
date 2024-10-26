









CONTINUAMOS A DISCUSSION DA ÚLTIMA LECTURE...












--> VAMOS TENTAR UPLOADAR 1 SAMPLE DATA,


BAIXADA NA ÚLTIMA AULA,


PARA DENTRO 

DA TABLE DE TAXI_DRIVE...



vamos usar a staging area da table:




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




put file:///home/arthur/Downloads/archive/train.csv
@DEMO_DB.PUBLIC.%TAXI_DRIVE;

















--> EU TENTEI FAZER UPLOAD DO ARQUIVO CSV INTEIRO,



MAS NA VERDADE É MELHOR TESTAR COM 1 SIMPLES SAMPLE,

DE 100 ROWS...








-> O PROFESSOR CRIA 1 FILE FORMAT, 

ANTES DE MAIS NADA...









CREATE OR REPLACE FILE FORMAT TAXI_CSV_FORMAT
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    NULL_IF=('NULL','null')
    EMPTY_FIELD_AS_NULL=TRUE
    COMPRESSION=GZIP;









aí o professor roda 

o comando de copy,

para copiar a sample data para dentro da table:








COPY INTO TAXI_DRIVE FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE
FILE_FORMAT=(
    FORMAT_NAME='TAXI_CSV_FORMAT'
    field_optionally_enclosed_by='"'
)
ON_ERROR='CONTINUE';



















ok, mas antes temos que uploadar a file para dentro 

da table staging area..







-> qual a file?









--> nao tenho... --> teria que criar 1 csv a partir 

daquela data..


farei isso...




--> copio para dentro, com este comando:




put file:////home/arthur/Desktop/PROJETO-SQL-2/MODULE22-WORKING-WITH-COPY-COMMAND/train-sample.csv
@demo_db.public.%taxi_drive;




SUCESSO:








arthur@arthur-IdeaPad-3-15ALC6:~/Desktop/PROJETO-SQL-2$ snowsql -a uu18264.us-east-2.aws -u nothingnothings
Password: 
* SnowSQL * v1.2.28
Type SQL statements or !help
nothingnothings#COMPUTE_WH@(no database).(no schema)>put file:////home/arthur/Desktop/PROJETO
                                                     -SQL-2/MODULE22-WORKING-WITH-COPY-COMMAN
                                                     D/train-sample.csv
                                                     @demo_db.public.%taxi_drive;
+------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source           | target              | source_size | target_size | source_compression | target_compression | status   | message |
|------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| train-sample.csv | train-sample.csv.gz |       88171 |       24768 | NONE               | GZIP               | UPLOADED |         |
+------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 2.223s
nothingnothings#COMPUTE_WH@(no database).(no schema)>list @demo_db.public.%taxi_drive;
+---------------------+-------+----------------------------------+-------------------------------+
| name                |  size | md5                              | last_modified                 |
|---------------------+-------+----------------------------------+-------------------------------|
| train-sample.csv.gz | 24768 | df09eec25c3bfb1c984eee91cc6a8d9a | Thu, 17 Aug 2023 21:59:22 GMT |
+---------------------+-------+----------------------------------+-------------------------------+
1 Row(s) produced. Time Elapsed: 0.324s
nothingnothings#COMPUTE_WH@(no database).(no schema)>










EX:







COPY INTO TAXI_DRIVE FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE
FILE_FORMAT=(
    FORMAT_NAME='TAXI_CSV_FORMAT'
    field_optionally_enclosed_by='"'
);






-_> MAS JÁ TEREMOS 1 ERROR....









O ERROR FOI DE 



"NUMERIC VALUE NOT RECOGNIZED"...








File '@TAXI_DRIVE/train-sample.csv.gz', line 2, character 27
  Row 1, column "TAXI_DRIVE"["ORIGIN_CALL":3]
  If you would like to continue loading when an error is encountered, 
  use other values such as 'SKIP_FILE' or 'CONTINUE' for the ON_ERROR option. For more information on
   loading options, please run 'info loading_data' in a SQL client.







O PROFESSOR COMENTA...




COMO RESOLVER?




SE QUEREMOS IGNORAR ESSE ERROR,

PODEMOS 



COLOCAR A OPTION DE "ON_ERROR='CONTINUE'"







o error foi:



Numeric value '"TRIP_ID"' is not recognized













NENHUM DOS RECORDS FORAM CARREGADOS...








O ERROR FOI DE "NUMERIC VALUE " is not recognized"..









--> PARA CHECAR QUAL É O PROBLEMA 

COM ESSE LOAD,



VAMOS COPIAR 


O QUERY ID 


E VAMOS 

RODAR A FUNCTION DE 



"validate"


EM CIMA DESSA TABLE,

TIPO ASSIM:









SELECT * FROM table(validate(TAXI_DRIVE, job_id=>'<your_query_id>'))











CÓDIGO COMPLETO:












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




CREATE OR REPLACE FILE FORMAT TAXI_CSV_FORMAT
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    NULL_IF=('NULL','null')
    field_optionally_enclosed_by='"'
    EMPTY_FIELD_AS_NULL=TRUE;



SELECT 
*
FROM 
@DEMO_DB.PUBLIC.%TAXI_DRIVE
(FILE_FORMAT => 'TAXI_CSV_FORMAT')


COPY INTO DEMO_DB.PUBLIC.TAXI_DRIVE FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE
FILE_FORMAT=(
    FORMAT_NAME='TAXI_CSV_FORMAT'
)
ON_ERROR='CONTINUE';




SELECT * FROM table(validate(TAXI_DRIVE, job_id=>'01ae6078-0001-4831-0000-00046d2ae159'))











E O OUTPUT:






Numeric value '' is not recognized	@TAXI_DRIVE/train-sample.csv.gz	2	27	136	conversion	100,038	22018	"TAXI_DRIVE"["ORIGIN_CALL":3]	1	2	"1372636858620000589","C","","","20000589","1372636858","A","False","[[-8.618643,41.141412],[-8.618499,41.141376],[-8.620326,41.14251],[-8.622153,41.143815],[-8.623953,41.144373],[-8.62668,41.144778],[-8.627373,41.144697],[-8.630226,41.14521],[-8.632746,41.14692],[-8.631738,41.148225],[-8.629938,41.150385],[-8.62911,41.151213],[-8.629128,41.15124],[-8.628786,41.152203],[-8.628687,41.152374],[-8.628759,41.152518],[-8.630838,41.15268],[-8.632323,41.153022],[-8.631144,41.154489],[-8.630829,41.154507],[-8.630829,41.154516],[-8.630829,41.154498],[-8.630838,41.154489]]" 
Numeric value '' is not recognized	@TAXI_DRIVE/train-sample.csv.gz	3	27	707	conversion	100,038	22018	"TAXI_DRIVE"["ORIGIN_CALL":3]	2	3	"1372637303620000596","B","","7","20000596","1372637303","A","False","[[-8.639847,41.159826],[-8.640351,41.159871],[-8.642196,41.160114],[-8.644455,41.160492],[-8.646921,41.160951],[-8.649999,41.161491],[-8.653167,41.162031],[-8.656434,41.16258],[-8.660178,41.163192],[-8.663112,41.163687],[-8.666235,41.1642],[-8.669169,41.164704],[-8.670852,41.165136],[-8.670942,41.166576],[-8.66961,41.167962],[-8.668098,41.168988],[-8.66664,41.170005],[-8.665767,41.170635],[-8.66574,41.170671]]" 
















O BOM É QUE A ÚLTIMA COLUMN NOS DÁ O REJECTED RECORD INTEIRO:





"1372636858620000589","C","","","20000589","1372636858","A","False","[[-8.618643,41.141412],[-8.618499,41.141376],[-8.620326,41.14251],[-8.622153,41.143815],[-8.623953,41.144373],[-8.62668,41.144778],[-8.627373,41.144697],[-8.630226,41.14521],[-8.632746,41.14692],[-8.631738,41.148225],[-8.629938,41.150385],[-8.62911,41.151213],[-8.629128,41.15124],[-8.628786,41.152203],[-8.628687,41.152374],[-8.628759,41.152518],[-8.630838,41.15268],[-8.632323,41.153022],[-8.631144,41.154489],[-8.630829,41.154507],[-8.630829,41.154516],[-8.630829,41.154498],[-8.630838,41.154489]]" 













em "column_name",

podemos encontrar a COLUMN QUE ORIGINOU O ERROR...





FOI 

"ORIGIN_CALL"...



ex:



"TAXI_DRIVE"["ORIGIN_CALL":3]













--> A TERCEIRA COLUMN FOI ESPECIFICADA COMO "NUMBER",


na nossa table,


mas o value está sendo carregado COMO 1 STRING...





quer dizer que empty values como "" deveriam ser tratados como null, possivelmente...


















ESSA É APENAS 1 DAS MANEIRAS 

DE CHECAR ESSE ERROR...





A OUTRA MANEIRA É 






COM A OPTION DE "VALIDATION_MODE='RETURN_ERRORS'",



NO COMANDO DE "copy"...




ex:



COPY INTO DEMO_DB.PUBLIC.TAXI_DRIVE FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE
FILE_FORMAT=(
    FORMAT_NAME='TAXI_CSV_FORMAT'
)
VALIDATION_MODE='RETURN_ERRORS';















essa option vai nos dar o mesmo 

output 

visto com a function de "table(validate())"...












PARA CONSERTAR ESSE VALUE INVÁLIDO 


de  "" na column dos numbers,



o professor 



nos mostra uma function especial...









ex:






COPY INTO DEMO_DB.PUBLIC.TAXI_DRIVE 
FROM (

SELECT 
T.$1,
T.$2,
iff(T.$3='', null, T.$3),
T.$4,
T.$5,
T.$6,
T.$7,
T.$8,
T.$9
FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE AS T
)
FILE_FORMAT=(
    FORMAT_NAME='TAXI_CSV_FORMAT'
)
ON_ERROR='CONTINUE';













OU SEJA,



É ESSE 
"iff()"...










O QUE É ISSO?






É "if function"...








ELA RODA ASSIM


""SE ESSA COLUMN TIVER UM VALUE DE "",

VAMOS QUERER DEIXAR SEU VALUE COMO NULL ""...



""caso contrário, deixe o mesmo value (T.$3)""..










--> QUER DIZER QUE AGORA ENQUANTO 

ESTAMOS RODANDO O COMANDO DE COPY,

ESTAMOS TRANSFORMANDO A DATA (isso é possível,
podemos rodar substring, converter 
coisas usando "::", podemos facilmente 
fazer isso enquanto rodamos 

o comando de copy em si)...





OK, RODAMOS ISSO AÍ,

E AÍ 

CONSEGUIMOS 


COPIAR 


O CONTEUDO DO CSV PARA DENTRO 

DA TABLE...






MAS AGORA FICAMOS COM OUTRO ERROR,


FICAMOS 


COM "PARTIALLY_LOADED"...







--> quer dizer que estamos com problemas...




mas esses problemas nao podem mais ser vistos rodando 

"VALIDATION_MODE='RETURN_ERRORS'"...










MAS PQ?







É PQ QUANDO RODAMOS "VALIDATION_MODE",


o resultado 


ficará diferente....









O PROFESSOR DIZ QUE HÁ UMA DIFERENÇA 

ENTRE AS MANEIRAS PELAS QUAIS FAZEMOS AS OPERACOES:










MANEIRA 1)



COPY INTO TAXI_DRIVE FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE
    FILE_FORMAT=(
        FORMAT_NAME='TAXI_CSV_FORMAT'
        field_optionally_enclosed_by='"'
    )
    VALIDATION_MODE='RETURN_ERRORS';










-----> quando rodamos "VALIDATION_MODE"



assim,


SEM A SELECT CLAUSE,





eram retornadas diversas informacoes,

e também o rejected_record...









--> MAS SE USAMOS ESSE MESMO COMANDO DE COPY,


MAS COM UMA TRANSFORMATION/SUBQUERY:





COPY INTO TAXI_DRIVE FROM 


(
SELECT 
T.$1,
T.$2,
iff(T.$3='', null, T.$3),
T.$4,
T.$5,
T.$6,
T.$7,
T.$8,
T.$9
FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE AS T

)
    FILE_FORMAT=(
        FORMAT_NAME='TAXI_CSV_FORMAT'
        field_optionally_enclosed_by='"'
    )
    VALIDATION_MODE='RETURN_ERRORS';








SE RODAMOS ISSO,


nao SERÁ ENTREGUE O MESMO 

VALUE DE 

"rejected_record",


e sim 

será entregue 

O RESULTADO DAQUELA SUBQUERY 
(
SELECT 
T.$1,
T.$2,
iff(T.$3='', null, T.$3),
T.$4,
T.$5,
T.$6,
T.$7,
T.$8,
T.$9
)





------> quer dizer que podemos RETORNAR 

DATA MANIPULADA DE NOSSO STAGE,



MESMO QUANDO NOS SAO RETORNADOS ERRORS....











O PROFESSOR QUER DIZER:






""ASSIM QUE VC USA QUALQUER TRANSFORMATION 
JUNTO COM SEU COPY COMMAND,

A OPTION __ DE "VALIDATION_MODE='RETURN_ERRORS'" 

NAO VAI MAIS FUNCIONAR...""


(
    devemos ter muito cuidado com isso...



    se utilizarmos 


    a option de VALIDATION_MODE para checar 
    por errors,

    NAO DEVEMOS REALIZAR TRANSFORMACAO 
    ALGUMA NAS COLUMNS COPIADAS 
    DO STAGE....
)













POR ISSO, NAO UTILIZE ESTA SINTAXE:








COPY INTO TAXI_DRIVE FROM 


(
SELECT 
T.$1,
T.$2,
iff(T.$3='', null, T.$3),
T.$4,
T.$5,
T.$6,
T.$7,
T.$8,
T.$9
FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE AS T

)
    FILE_FORMAT=(
        FORMAT_NAME='TAXI_CSV_FORMAT'
        field_optionally_enclosed_by='"'
    )
    VALIDATION_MODE='RETURN_ERRORS';






------------------










OK... 19 RECORDS FORAM CARREGADOS,


E 80 FORAM REJECTED...





SE QUEREMOS VER OS RECORDS QUE FORAM REJEITADOS 

EM DETALHES,

DEVEMOS RODAR ESTE SELECT:












SELECT * FROM TABLE(validate(TAXI_DRIVE, job_id => <your_query_id>));











SE EU ESTOU REALIZANDO 


QUALQUER TRANSFORMATION  DURANTE 

O COMANDO DE COPY,



NAO DEVO USAR "VALIDATION_MODE='RETURN_ERRORS'",



E SIM 




DEVO USAR 


ESSe select de


""
SELECT * FROM TABLE(validate(TAXI_DRIVE, job_id => <your_query_id>));

"",



para que eu consiga visualizar os exatos records que 

foram rejected..









--> 


OS REJECTED RECORDS 


FORAM POR CONTA DA COLUMN DE "ORIGIN_STAND".. -> mesmo 

problema 



da outra column,


estamos com "" em 1 column de number...














PARA RESOLVER O PROBLEMA, FINALMENTE,

O PROFESSOR RODA ASSIM:



COPY INTO TAXI_DRIVE FROM 


(
SELECT 
T.$1,
T.$2,
iff(T.$3='', null, T.$3),
iff(T.$4='', null, T.$4),
T.$5,
T.$6,
T.$7,
T.$8,
T.$9
FROM @DEMO_DB.PUBLIC.%TAXI_DRIVE AS T

)
    FILE_FORMAT=(
        FORMAT_NAME='TAXI_CSV_FORMAT'
        field_optionally_enclosed_by='"'
    )
ON_ERROR='CONTINUE';


















ok... agora toda data foi carregada com sucesso...











NA PRÓXIMA LECTURE CARREGAREMOS A MAIN FILE,

QUE TEM 2GB DE DATA...






--> FAREMOS ISSO COM 1 EXTRA SMALL WAREHOUSE,

PARA VER COMO ELA PERFORMA...