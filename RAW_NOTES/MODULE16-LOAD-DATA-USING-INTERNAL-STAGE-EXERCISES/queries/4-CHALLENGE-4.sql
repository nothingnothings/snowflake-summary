









COPIAMOS RECORDS PARA DENTRO DA TABLE DE POPULATION,

USANDO 1 FILE FORMAT CRIADO POR NÓS...











O PRÓXIMO DESAFIO É:

















TEMOS QUE COPIAR TODAS AS 

FILES QUE COMECAM COM "A" PARA DENTRO 

DE NOSSA TABLE...





ENTRETANTO, ALGUMAS FILES ESTAO COM 

1 NÚMERO ERRADO DE COLUMNS,

SÓ 11 COLUMNS...



O QUE QUER DIZER QUE 


SE 


TENTAMOS COPIAR ESSE CONTEÚDO,

O COMANDO DE COPY VAI FALHAR...







--> PARA CONSERTAR ESSE PROBLEMA,

TEMOS QUE SEGUIR



O AVISO/WARNING DE ERRO,



E CONSERTAR ESSE COPY COMMAND...









--> OK... COMO PODEMOS ESCREVER ISSO?








TIPO ASSIM:









TRUNCATE demo_db.public.population;




COPY INTO demo_db.public.population
FROM @demo_db.public.countries_stage/countries_A/
FILE_FORMAT=(
    FORMAT_NAME='country_file_format'
);














CONSEGUI... FICOU TIPO ASSIM:










TRUNCATE demo_db.public.population;


COPY INTO demo_db.public.population
FROM @demo_db.public.countries_stage/countries_A/
FILE_FORMAT=(
    FORMAT_NAME='country_file_format'
    ERROR_ON_COLUMN_COUNT_MISMATCH=FALSE  -- eis o código em questao.
);




SELECT * FROM demo_db.public.population;













MEU OUTPUT FICOU TIPO ASSIM:


Armenia	1980	3099754	1.82 %	53399	3443	23.5	2.6	109	66.0 %	2047372	0.07 %	4458003514	120     null    null    null
Armenia	1975	2832759	2.33 %	61538	17281	21.8	3.04	99	63.6 %	1801955	0.07 %	4079480606	118  null  null   null














OU SEJA,


AS FILES QUE NAO TINHAM AQUELA COLUMN FICARAM COM "NULL"


NAS COLUMNS QUE NAO EXISTIAM/NAO EXISTEM...










CÓDIGO DO PROFESSOR: 




/*** you will see error ****/
copy into demo_db.public.population
from '@population/countries_a/'
file_format = my_csv_format

alter file format my_csv_format
set error_on_column_count_mismatch=false


copy into demo_db.public.population
from '@population/countries_a/'
file_format = my_csv_format