










COPIAMOS RECORDS 
DE "AFGHANISTAN" PARA DENTRO DA TABLE DE "population"..









MAS O PROFESSOR DIZ QUE 


ACONTECEU ALGO ESTRANHO...





A COLUMN DE "HEADER"



FOI COLOCADA COMO ROW TBM...








--> PARA RESOLVER ESSA CHALLENGE, PRECISAMOS:







1) CRIAR 1 FILE FORMAT OBJECT,

COM A PROPERTY DE "SKIP_HEADER=1",


para nao copiar o header, para que ele nao apareca 


como header..











-- PARA ISSO, ESCREVEMOS ASSIM:





CREATE OR REPLACE FILE FORMAT country_file_format 
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
    COMPRESSION=GZIP; 




--> DEPOIS INTEGRAMOS 

ESSE 

FILE FORMAT OBJECT NO 

COMANDO DE COPY, TIPO ASSIM:






TRUNCATE TABLE demo_db.public.population;



COPY INTO demo_db.public.population
FROM @demo_db.public.countries_stage/countries_A/afghanistan-population.csv.gz
FILE_FORMAT=(
    FORMAT_NAME='country_file_format'
);












CERTO... 







ISSO FUNCIONOU...