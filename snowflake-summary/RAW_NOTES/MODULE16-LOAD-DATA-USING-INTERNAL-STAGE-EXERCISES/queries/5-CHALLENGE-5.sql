

ACABAMOS COM A CHALLENGE ANTERIOR, E 249 

ROWS FORAM INSERIDOS...







--> OK... NESSE assignment,





TEREMOS QUE CAPTURAR 


O NOME DA FILE TAMBÉM, ENQUANTO FAZEMOS LOAD
DA DATA 

NA TABLE...







--> OU SEJA, ADICIONAREMOS UMA COLUMN A MAIS NESSA TABLE,



POR ISSO FICA ASSIM:





CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.POPULATION (
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






FICOU TIPO ASSIM:














CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.POPULATION (
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



COPY INTO demo_db.public.population
FROM (
SELECT metadata$filename,
T.$1,
T.$2,
T.$3,
T.$4,
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
FROM @demo_db.public.countries_stage/countries_A/ T
)
FILE_FORMAT=(
    FORMAT_NAME='country_file_format'
    ERROR_ON_COLUMN_COUNT_MISMATCH=FALSE
);



SELECT * FROM DEMO_DB.PUBLIC.POPULATION;