










-> OK... AGORA RECEBEMOS OUTRA TAREFA...







--> DEVEMOS CARREGAR TODAS AS FILES 


PARA DENTRO DE 1 "NAMED STAGE"...







--> ANTERIORMENTE,

USAMOS 

"TABLE STAGING AREAS",


que sao justamente 

STAGING AREAS RESTRITAS A 1 TABLE (

    cada table staging area só pode 
    interagir com a table a que está vinculada/a sua própria table...
)










--> MAS AGORA A EMPRESA QUER 

MOVER 1 MONTE DA DATA 

PARA DIFERENTES TABLES...






--> COMO PARTE DE NOSSA TAREFA,


UTILIZAREMOS MAIS DO QUE 



1 ÚNICA TABLE,

E, PORTANTO,

MAIS DO QUE 


1 
ÚNICA "TABLE STAGING AREA"...









--> QUEREMOS TER UMA STAGING AREA "CONJUNTA",


que será usada 

POR TODAS AS TABLES....







A DATA DAS FILES NESSE STAGE OBJECT 


SERÁ TRANSFERIDA A VÁRIAS TABLES...









------> SEMPRE É UMA BETTER PRACTICE USAR 

O NAMED STAGE....










NAMED STAGES SAO SEMPRE MELHORES DE USAR DO QUE 

TABLE STAGES...







--> E, DENTRO DESSE NAMED STAGE,

NOS PEDIRAM PARA CRIAR 


__FOLDERS __ SEPARADOS __ PARA CADA 1 DAS TABLES...



POR FIM, DEVEMOS




FAZER LOAD DA DATA, DESSES FOLDERS AÍ, PARA SUAS 

TABLES RESPECTIVAS...













--> COMO PODEMOS CONSEGUIR ISSO?











--> A PRIMEIRA COISA QUE PRECISAMOS FAZER É CRIAR 1 NOVA TABLE...






ESCREVEMOS ASSIM:







-- create the table
CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.EMP_BASIC_NAMED_STAGE 
    (
        FILE_NAME STRING,
        FILE_ROW_NUMBER STRING,
        FIRST_NAME STRING,
        LAST_NAME STRING,
        EMAIL STRING,
        STREETADDRESS STRING,
        CITY STRING,
        START_DATE DATE
    );


-- create the named stage 
CREATE OR REPLACE STAGE DEMO_DB.INTERNAL_STAGES.MY_INT_STAGE;












a sintaxe de criacao de stages é bem assim... --> 

COM ISSO,

CRIAMOS 1 BLOB STORAGE AREA... ( que é um stage)...









--> a única diferenca de INTERNAL STAGES 

PARA EXTERNAL STAGES 


é a presenca de "url=", que é um indicador 

de que 

nossas files sao extraídas de 1 lugar externo ao snowflake...














ISSO FEITO, O PROFESSOR 

COLOCA ARQUIVOS NESSA STAGING AREA....




COM O COMANDO DE PUT:








put file:///path/on/your/file/system/employees0*.csv
@demo_db.internal_stages.my_int_stage/emp_basic_local;















OK... RESUMINDO:





TABLE STAGES: PRECISAM DE '@%' (arroba e percentage)



NAMED STAGES (gerais, tanto external como internal
): PRECISAM DE APENAS '@'...













COMANDO:


put file:///home/arthur/Desktop/PROJETO-SQL-2/MODULE15-LOADING-DATA-INTO-INTERNAL-STAGE/data-to-be-loaded/* 
@demo_db.internal_stages.my_int_stage/emp_basic_local;





COM ESSE COMANDO, TAMBÉM CRIAMOS 1 FOLDER ESPECÍFICO,

DE NOME 'emp_basic_local'....






carregaremos todas as files nesse folder aí,

dentro da 

table staging area...








COM ISSO, PODEMOS PEGAR ESSAS FILES E CARREGAR SUA DATA/CONTEÚDO 

PARA DENTRO DE NOSSAS ACTUAL TABLES..









vamos até o snowflake web console...







MAS ANTES DISSO O PROFESSOR TRUNCA A TABLE DE 

emp_basic_local

tipo assim:












TRUNCATE TABLE demo_db.public.emp_basic_local;










--> COM A AJUDA DOS NAMED STAGES,




AS FILES COLOCADAS NESSE STAGING AREA 

NAO FICAM "VINCULADAS" A 1 TABLE ESPECÍFICA (
    como as TABLE STAGES...
)













O CÓDIGO FICA TIPO ASSIM:









TRUNCATE TABLE demo_db.public.emp_basic_local;

copy into demo_db.public.emp_basic_local
from (select metadata$filename, metadata$file_row_number, t.$1 , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.internal_stages.my_int_stage/emp_basic_named_stage t)
file_format = (type = csv field_optionally_enclosed_by='"')
pattern = '.*employees0[1-5].csv.gz'
on_error = 'skip_file';

TRUNCATE TABLE demo_db.public.emp_basic_named_stage;

copy into demo_db.public.emp_basic_named_stage
from (select metadata$filename, metadata$file_row_number, t.$1 , t.$2 , t.$3 , t.$4 , t.$5 , t.$6 from @control_db.internal_stages.my_int_stage/emp_basic_local t)
file_format = (type = csv field_optionally_enclosed_by='"')
pattern = '.*employees0[1-5].csv.gz'
on_error = 'skip_file';






COM ISSO, PODMOS COPIAR 


DATA PARA DENTRO DE DIFERENTES TABLES, A PARTIR DE DIFERENTES ARQUIVOS, DE FOLDERS DISTINTOS DENTRO 

DE NOSSO 

NAMED STAGE...











COM NAMED STAGES, PODEMOS SHAREAR A DATA, O QUE É BEM MELHOR, PRINCIPALMENTE 

SE TEMOS MÚLTIPLAS PESSOAS 


VAO USAR NOSSAS TABLES...









essas pessoas podem compartilhar essa 

staging area,

mas devemos sempre ter disciplina...








--> É MELHOR SEMPRE 


CRIAR OS FOLDERS COM OS NOMES DAS TABLES,

PARA QUE SEJA BEM INTUITITOV...













--> COMO O NAMED STAGE É UM OBJECT,

PODEMOS FAZER DESCRIBE DELE,

COM 



"DESC STAGE DEMO_DB.INTERNAL_STAGES.MY_INT_STAGE"...










--> VOCE DEVE COPIAR A DATA USANDO STAGES 
E FILE FORMATS...







OK... o stage é um object... e manageia a blog storage area...,


de onde vc carrega a data/solta a data...