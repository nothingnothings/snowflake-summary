

NA ÚLTIMA AULA,

FIZEMOS O COPY DE 1 TABLE STAGING AREA (@%)



PARA DENTRO 



DE 1 TABLE...






--> VC DEVE USAR TABLE STAGING AREAS 

QUANDO N TIVER PERMISSAO PARA CRIAR NAMED STAGE AREAS 
DEFAULT (internas)...











NESSA CHALLENGE FINAL, O QUE FAREMOS É:






1) recriar a named staging area 


de "population" 




com 



CREATE OR REPLACE STAGE population_staging_area;









2) DEPOIS DISSO,

TENTE COPIAR TODOS OS ARQUIVOS CSV PARA 

DENTRO 

DESSA NAMED STAGING AREA INTERNA...








3) mas queremos copiar APENAS 

OS ARQUIVOS QUE COMECEM COM "A"...







---> já fiz isso....





o código do professor/meu código ficou assim:









PUT file:///workspace/snowflake/Module-2/Snowflake-stages/Data/Practice_data/countries/a* @%population_afgn/countries/;

create or replace table demo_db.public.population_afgn
(
file_name varchar,
country	varchar,
Year	varchar,
Population	varchar,
Yearly_percentage_change	varchar,
Yearly_Change	varchar,
Migrants_net	varchar,
Median_Age	varchar,
Fertility_Rate	varchar,
Density_P_Km_sq	varchar,
Urban_Pop_percentage	varchar,
Urban_Population	varchar,
Country_Share_of_WorldPop	varchar,
World_Population	varchar,
Rank	varchar
);


copy into demo_db.public.population_afgn
from (select split_part(metadata$filename,'/',2), t.$1,t.$2,t.$3,
replace(t.$4,'%',''),t.$5,t.$6,t.$7,t.$8,t.$9,t.$10,t.$11,
t.$12,t.$13,t.$14
from @population/countries/ t)
file_format = my_csv_format
pattern = '^.*/a.*$'

truncate table demo_db.public.population_afgn

select * from demo_db.public.population_afgn;

create or replace stage population;


