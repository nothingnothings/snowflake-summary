






OK, COLOCAMOS TODAS AS FILES PARA DENTRO DESSE STAGE AÍ,

DENTRO DE cada folder...














--> AGORA TEMOS QUE CRIAR UMA NOVA TABLE,



"population",

e aí 

temos que 

COPIAR O 


COUNTRY ESPECÍFICO,

"afghanistan",


PARA 

DENTRO 

DESSA TABLE,

USANDO O COMANDO DE COPY...












--> CRIAMOS A TABLE, COM ESTE COMANDO:





CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.POPULATION (
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







--> PARA ISSO, ACHO QUE A QUERY VAI FICAR ASSIM:







COPY INTO demo_db.public.population
FROM @demo_db.public.country_stage/country_A/afghanistan-population.csv.gz
FILE_FORMAT=(
    SKIP_HEADER=1
    FIELD_DELIMITER=','
    TYPE=CSV
    COMPRESSION=GZIP
)











SUCESSO, FICOU ASSIM:








CREATE OR REPLACE TABLE DEMO_DB.PUBLIC.POPULATION (
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

LIST @demo_db.public.countries_stage/countries_A;


COPY INTO demo_db.public.population
FROM @demo_db.public.countries_stage/countries_A/afghanistan-population.csv.gz
FILE_FORMAT=(
    SKIP_HEADER=1
    FIELD_DELIMITER=','
    TYPE=CSV
    COMPRESSION=GZIP
);



SELECT * FROM demo_db.public.population;



