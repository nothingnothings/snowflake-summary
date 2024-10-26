VEREMOS A SINTAXE PARA O 


STAGE,

FILE FORMAT,

INTEGRATION E COPY...












--> ANTES DE CRIAR ESSES 3 OBJECTS, É BOM MANTER 

TODOS ESSES OBJECTS EM 1 MESMO LUGAR...





--> PARA ISSO, O PROFESSOR CRIOU 1 DATABASE DE NOME "CONTROL_DB",


e criou 



schemas para:


1) INTERNAL STAGES


2) EXTERNAL STAGES 



3) FILE FORMATS...
















--> ELE ESCREVE TIPO ASSIM:








CREATE OR REPLACE TRANSIENT DATABASE CONTROL_DB;




CREATE OR REPLACE SCHEMA EXTERNAL_STAGES;


CREATE OR REPLACE SCHEMA INTERNAL_STAGES;



CREATE OR REPLACE SCHEMA FILE_FORMATS;





-- Create external stage:

CREATE OR REPLACE STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE 
    url='s3://snowflake867/test/'
    credentials=(
        aws_key_id='AKIAUIIPUVJBJMSPABKO' 
        aws_secret_key='bgQb6b816dzQdGkT+JPVqeiQ561B'
    );



-- show files 
DESC STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE;




ALTER STAGE MY_EXT_STAGE
SET CREDENTIALS=(
        aws_key_id='d4c3b2a1'
        aws_secret_key='z9y8x7w6'
)






-- CREATE INTERNAL STAGE 











ESSAS KEYS SAO DUMMY, MAS É BOM SABER A SINTAXE....





---------------------------------------
























CREATE OR REPLACE TRANSIENT DATABASE CONTROL_DB;




CREATE OR REPLACE SCHEMA EXTERNAL_STAGES;


CREATE OR REPLACE SCHEMA INTERNAL_STAGES;



CREATE OR REPLACE SCHEMA FILE_FORMATS;





-- Create external stage:

CREATE OR REPLACE STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE 
    url='s3://snowflake867/test/'
    credentials=(
        aws_key_id='AKIAUIIPUVJBJMSPABKO' 
        aws_secret_key='bgQb6b816dzQdGkT+JPVqeiQ561B'
    );



-- show files 
DESC STAGE CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE;




ALTER STAGE MY_EXT_STAGE
SET CREDENTIALS=(
        aws_key_id='d4c3b2a1'
        aws_secret_key='z9y8x7w6'
)






-- CREATE INTERNAL STAGE 























--> OK... MAS É CLARO QUE CRIAR 1 OBJECT ASSIM, DESSA FORMA,

NAO É NADA SECURE...






NAO É SECURE PQ ESTAMOS INSERINDO 

AS CHAVES/USER E PASSWORD DIRETAMENTE 




NO TEXTO DE NOSSA WORKSHEET...









-- ESTAMOS EXPONDO NOSSO ACCESS KEY ID E SECRET KEY... por isso nao é secure...









--> SE ALGUÉM TIVER ACESSO A ESSE STAGE OBJECT,


PODE FACILMENTE 

CHECAR 


ESSA ACCESS KEY E SECRET ID KEY...








--> EXISTE UMA MANEIRA BEM MELHOR DE CONSEGUIR 
ACESSO 

A 


ESSE EXTERNAL STAGE COM CREDENTIALS,

E VEREMOS ISSO NAS PRÓXIMAS AULAS...  (
    com integration objects, provavelmente...
)









O PROFESSOR VE AS FILES DENTRO DESSE STAGE,

COM 



DESC STAGE.CONTROL_DB.EXTERNAL_STAGES.MY_EXT_STAGE;











----------> com DESC,

poedmos ver várias propriedades desse object....








--> dentro do object, temos "s3 location" também...








TAMBÉM PODEMOS USAR "LIST @MY_EXT_STAGE",


PARA 
VER AS FILES 


QUE TEMOS DENTRO DESSE OBJECT..









--> TAMBÉM PODEMOS ALTERAR ESSE OBJECT,


ALTERAR AS CREDENTIALS,


GARANTIR ACESSO A OUTRAS USERS/ROLES,



e droppar esse object...















ok... AÍ O PROFESSOR NOS MOSTRA COMO PODEMOS 

CRIAR 1 INTERNAL STAGE...






TIPO ASSIM:






-- Create internal stage 

CREATE OR REPLACE STAGE CONTROL_DB.INTERNAL_STAGES.MY_INT_STAGE;




DESC STAGE CONTROL_DB.INTERNAL_STAGE.MY_INT_STAGE;










--> COM ISSO, CRIAMOS 1 STAGE "VAZIO"... (certamente nao é um EXTERNAL STAGE)...








PODEMOS RODAR DESC NESSE STAGE,

TIPO ASSIM:





DESC STAGE CONTROL_DB.INTERNAL_STAGES.MY_INT_STAGE;











NESSE DESC,



ENCONTRAMOS QUE A COLUMN DE "Location" ESTÁ VAZIA...








--> ELA ESTÁ VAZIA JUSTAMENTE PQ ESTAMOS NOS conectando
 à STAGING AREA INTERNA DO SNOWFLAKE...









 --> TODAS AS OPTIONS RESTANTES SAO AS MESMAS...








 -> DEPOIS DISSO, O PROFESSOR CRIA O FILE FORMAT,

 COM ESTE CÓDIGO:











 CREATE OR REPLACE FILE FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT
    TYPE=CSV,
    FIELD_DELIMITER=',',
    SKIP_HEADER=1,
    NULL_IF=('NULL', 'null')
    EMPTY_FIELD_AS_NULL=true
    COMPRESSION=gzip;











OK... MAS O QUE É 'Compression=gzip'?










--> ISSO QUER DIZER QUE AS FILES QUE ESTAO ARMAZENADAS 

NESSA EXTERNAL/INTERNAL STAGING AREA 

ESTARAO 


NO FORMATO GZIP COMPRESSED FORMAT (nao sao csvs, portanto)...










OK... CRIADO ESSE FILE FORMAT,



ELE É UM OBJECT...










PODEMOS RODAR 




DESC FILE_FORMAT CONTROL_DB.FILE_FORMATS.MY_CSV_FORMAT;











--> ISSO NOS DÁ TODAS AS PROPERTIES DESSE FILE FORMAT...











--> 

MTAS DAS PROPRIEDADES 




DO FILE FORMAT OBJECT 



SAO IGUAIS ÀS PROPRIEDADES DO STAGE OBJECT...











--> PODEMOS CONFIGURAR AS PROPRIEDADES 


DO FILE FORMAT TAMBÉM DENTRO DO STAGE (

    as configs do stage dao overwrite em cima do 

    file format....
)







--> A MELHOR PRACTICE É 

SEMPRE 


USAR O OBJECT DE FILE FORMAT PARA DEFINIR ESSAS CONFIGURACOES...












-- NO OBJECT DE "STAGE", 


vc pode configurar AS COPY OPTIONS (

    essa é a melhor practice
), 

mas nao deve configurar os file format options...













--> OK... AGORA 


CHECAMOS A SINTAXE DO COMANDO DE COPY:













-- Execute copy command:





COPY INTO SALES 
FROM @my_ext_stage 
FILE_FORMAT=(
    FORMAT_NAME='my_csv_format'
    ERROR_ON_COLUMN_COUNT_MISMATCH=false
)
ON_ERROR='skip_file';











SE QUEREMOS OVERWRITTAR ALGUMAS 

DAS PROPRIEDADES DO OBJECT "FILE FORMAT",


podemos escrever esses overwrites dentro do "FILE_FORMAT=()",

como visto com 

"ERROR_ON_COLUMN_COUNT_MISMATCH"...












E SE QUEREMOS OVERWRITTAR ALGUMA 

DAS OPTIONS DO COMANDO DE "COPY",


DEVEMOS COLOCAR ALI NO FINAL... (

    "ON_ERROR"...
)










--> COM A DEFINICAO DE COPY OPTIONS (como "ON_ERROR") inline 


NO NOSSO COPY COMMAND,


AS CONFIGS DO STAGE OBJECT, CORRESPONDENTES, SAO OVERWRITTADAS (como
 essa propriedade "on_error")...






----------------------------------------












MAS NEM SEMPRE É OBRIGATÓRIO USAR OS OBJECTS DE "FILE_FORMAT"


E 

"STAGE",

dentro 


de 1 comando de copy into...





EX:



COPY INTO employee_basic_external
FROM s3://snowflake867/test/
CREDENTIALS=(
        aws_key_id='AKIAUIIPUVJBJMSPABKO' 
        aws_secret_key='bgQb6b816dzQdGkT+JPVqeiQ561B'
    )
FILE_FORMAT=(
    TYPE=CSV,
    field_optionally_enclosed_by=''
);









-------> É CLARO QUE ISSO É POSSÍVEL,


MAS ESSA NAO É UMA BEST PRACTICE...






















--> POR FIM, PODEMOS SELECIONAR APENAS ALGUMAS COLUMNS 

DOS ARQUIVOS CARREGADOS LÁ DO STAGE,

BASTA USAR A SINTAXE DE 

"table_name.$1", "tab_name.$2', etc...







ex:











COPY INTO employee_basic_local
FROM (
    SELECT
        metadata$filename,
        metadata$file_row_number,
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6
        FROM @emp_basic_local_stage AS t
) 
FILE_FORMAT=(
    TYPE=CSV,
    FIELD_OPTIONALLY_ENCLOSED_BY=''
)
PATTERN='.*employees0[1-5].csv.gz'
ON_ERROR='skip_file'














OK.... JÁ SEI MTO DESSA SINTAXE...











ANTES DE ACABARMOS COM ESSA LICAO,

DEVEMOS 


RECAPITULAr:















APRENDEMOS:






1) SINTAXE PARA A CRIACAO DE STAGE OBJECTS 




2) SINTAXE PARA A CRIACAO DE FILE FORMAT OBJECTS 



3) APRENDEMOS A DIFERENCA ENTRE OS 2 OBJECTS (file format e stage) 

(as propriedades diferentes entre os 2)...




4) APRENDEMOS QUE É UMA BEST PRACTICE CRIAR STAGE 
E FILE FORMAT OBJECTS,


E OS INSERIR EM SCHEMAS PRÓPRIOS...


(control_db, schemas para os object names)...






5) FICAMOS COM 1 HIGH-LEVEL OVERVIEW DO COMANDO DE COPY...






