









O PRÓXIMO DESAFIO É:









__ PROFESSOR QUER QUE REMOVAMOS 

O "countries_a/"


ENQUANTO FAZEMOS LOAD DA DATA,

na string de "metadata$filename"....







--> O PROFESSOR TAMBÉM QUER QUE


O SÍMBOLO DE PORCENTAGEM 

EM "YEARLY_PERCENTAGE_CHANGE"



SEJA REMOVIDO (manipulacao de data básica)...


ok...



ACHO QUE A QUERY FICA ASSIM:










COPY INTO demo_db.public.population
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
FROM @demo_db.public.countries_stage/countries_A/ T
)
FILE_FORMAT=(
    FORMAT_NAME='country_file_format'
    ERROR_ON_COLUMN_COUNT_MISMATCH=FALSE
);


TRUNCATE demo_db.public.population;


SELECT * FROM demo_db.public.population;