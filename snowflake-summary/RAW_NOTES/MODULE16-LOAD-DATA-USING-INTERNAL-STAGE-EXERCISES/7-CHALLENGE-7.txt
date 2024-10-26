






AGORA, NESSA CHALLENGE,
ASSUMAMOS QUE 

NAO TEMOS 


PERMISSAO 

PARA CRIAR 

ESSA 

STAGE LOCATION (esse named stage)...









--> E SE VC NAO TEM PERMISSAO PARA CRIAR 1 NAMED STAGE,


VC NAO TEM PERMISSAO 



PARA 


UPLOADAR SUAS FILES 


DE SUA LOCAL MACHINE PARA ESSE STAGE...








--> AGORA, O PROFESSOR QUER QUE AINDA COPIEMOS 

OS ARQUIVOS,




OS ARQUIVOS DE COUNTRY QUE COMECAM COM 'A'...








--> PARA ISSO, PRECISAREMOS CRIAR UMA "TABLE STAGING AREA"...







TABLE STAGING AREA === @% ..









--> PARA CRIAR UMA TABLE STAGING AREA,



BASTA CRIAR 1 TABLE...





POR ISSO CRIAREMOS 1 TABLE, DE NOME 

population_afgn,



em que 

vamos copiar 


os conteúdos dessa file...







--> PARA ISSO, AS QUERIES FICAM ASSIM:




-- enter snowsql 
-- snowsql -a <account_identifier> -u <username>






CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.POPULATION_AFGN 
(
    FILE_NAME VARCHAR, -- extra column
    COUNTRY VARCHAR,
    YEAR VARCHAR,
    POPULATION VARCHAR,
    YEARLY_PERCENTAGE_CHANGE VARCHAR,
    YEARLY_CHANGE VARCHAR,
    MIGRANTS_NET VARCHAR,
    MEDIAN_AGE VARCHAR,
    FERTILITY_RATE VARCHAR,
    DENSITY_P_KM_SQ VARCHAR,
    URBAN_POP_PERCENTAGE VARCHAR,
    URBAN_POPULATION VARCHAR,
    COUNTRY_SHARE_OF_WORLDPOP VARCHAR,
    WORLD_POPULATION VARCHAR,
    RANK VARCHAR
);






-- put into table staging area (in snowsql)
put file:///home/arthur/Desktop/PROJETO-SQL-2/MODULE16-LOAD-DATA-USING-INTERNAL-STAGE-EXERCISES/countries-to-be-loaded/afghanistan-population.csv
@demo_db.public.%population_afgn;




-- copy from table staging area into table.
COPY INTO demo_db.public.population_afgn
FROM (
SELECT 

SPLIT_PART(metadata$filename, '/', 2),
T.$1,
T.$2,
T.$3,
REPLACE(T.$4, '%', ''),
T.$5,
T.$6,
T.$7,
T.$8,
T.$9,
T.$10,
T.$11,
T.$12,
T.$13,
T.$14
FROM @demo_db.public.%population_afgn T
)
FILE_FORMAT=(
    FORMAT_NAME='country_file_format'
    ERROR_ON_COLUMN_COUNT_MISMATCH=FALSE
);









CERTO, SUCESSO...