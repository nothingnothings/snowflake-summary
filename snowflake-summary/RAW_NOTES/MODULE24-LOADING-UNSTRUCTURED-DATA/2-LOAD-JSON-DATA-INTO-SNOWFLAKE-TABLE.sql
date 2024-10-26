


AGORA VEREMOS O QUAO FÁCIL É O PARSE 

E LOAD 


DE JSON DATA NO SNOWFLAKE...












--> CONSIDEREMOS ESTE EXEMPLO:




------- PARSING JSON -------------











CREATE OR REPLACE TABLE JSON DEMO (
    V variant
);









--> esta aula nos ajudará
 
 a compreender diferentes aspectos
  

  do processo de json parsing...





--> como vc pode perceber, essa table tem apenas 


1 ÚNICA COLUMN,

DE DATA TYPE 'variant'...













--> ISSO FEITO,

VAMOS INSERIR 

DATA 


DENTRO 


DA TABLE, COM ESTE COMANDO:








INSERT INTO json_demo
SELECT 
    PARSE_JSON(
'{
   "fullName":"Johnny Appleseed",
   "age":42,
   "gender":"Male",
   "phoneNumber":{
      "areaCode":"415",
      "subscriberNumber":"5551234"
   },
   "children":[
      {
         "name":"Jayden",
         "gender":"Male",
         "age":"10"
      },
      {
         "name":"Emma",
         "gender":"Female",
         "age":"8"
      },
      {
         "name":"Madelyn",
         "gender":"Female",
         "age":"6"
      }
   ],
   "citiesLived":[
      {
         "cityName":"London",
         "yearsLived":[
            "1989",
            "1993",
            "1998",
            "2002"
         ]
      },
      {
         "cityName":"San Francisco",
         "yearsLived":[
            "1990",
            "1993",
            "1998",
            "2008"
         ]
      },
      {
         "cityName":"Portland",
         "yearsLived":[
            "1993",
            "1998",
            "2003",
            "2005"
         ]
      },
      {
         "cityName":"Austin",
         "yearsLived":[
            "1973",
            "1998",
            "2001",
            "2005"
         ]
      }
   ]
}'
    );












--> ESSE JSON TEM DETALHES SOBRE 1 PESSOA 

QUE 




MOROU EM DIFERENTES CIDADES...



TAMBÉM INFO SOBRE SEUS FILHOS,




O GENDER E AGE DE SEUS FILHOS,



SEUS NOMES...










--> TAMBÉM AGE, PHONE NUMBER E AREA CODE...














--> NESSE EXEMPLO, VAMOS PARSEAR ESSA JSON DATA,

USANDO O SNOWFLAKE (com parse_json)...











-----_> MAS ANTES DE PARSEARMOS,

DEVEMOS VER COMO ESSA TABLE É CRIADA...









--> O NOME DA COLUMN SERÁ "V",

E SEU DATA TYPE SERÁ DE "VARIANT"....





VEREMOS QUE A TABLE ESTÁ VAZIA...










--> MAS AÍ VAMOS INSERIR A DATA,

COM ESTE COMANDO:







INSERT INTO json_demo
SELECT 
    PARSE_JSON(
'{
   "fullName":"Johnny Appleseed",
   "age":42,
   "gender":"Male",
   "phoneNumber":{
      "areaCode":"415",
      "subscriberNumber":"5551234"
   },
   "children":[
      {
         "name":"Jayden",
         "gender":"Male",
         "age":"10"
      },
      {
         "name":"Emma",
         "gender":"Female",
         "age":"8"
      },
      {
         "name":"Madelyn",
         "gender":"Female",
         "age":"6"
      }
   ],
   "citiesLived":[
      {
         "cityName":"London",
         "yearsLived":[
            "1989",
            "1993",
            "1998",
            "2002"
         ]
      },
      {
         "cityName":"San Francisco",
         "yearsLived":[
            "1990",
            "1993",
            "1998",
            "2008"
         ]
      },
      {
         "cityName":"Portland",
         "yearsLived":[
            "1993",
            "1998",
            "2003",
            "2005"
         ]
      },
      {
         "cityName":"Austin",
         "yearsLived":[
            "1973",
            "1998",
            "2001",
            "2005"
         ]
      }
   ]
}'
    );







O PRÓXIMO PASSO É PARSEAR ESSA DATA....










--> PARA PARSEAR,




O PROFESSOR TEM ESTE CÓDIGO:







-- Let's parse the JSON:


-- cast name to string data type... 
SELECT v:fullName::string AS full_name
FROM json_demo;














--> certo....







ISSO ESTÁ EM 1 NÍVEL MAIOR DA HIERARQUIA....







--> certo...





se selecionamos sem fazer typecasting,


fica assim:






SELECT v:fullName AS full_name 
FROM json_demo;



(
   fica tipo "Johnny Appleseed"
)













--> AGORA RODAMOS MAIS TRANSFORMACOES:





SELECT 
v:fullName::string AS full_name,
v:age::int AS age,
v:gender::string AS gender
FROM json_demo;








certo... isso nos deu o name, age e gender...













--> AGORA PARSEAMOS DATA MAIS NESTEADA, DENTRO DO JSON:




SELECT 
v:phoneNumber.areaCode::string AS area_code,
v:phoneNumber.subscriberNumber::string AS subscriber_number
FROM json_demo;



-------------------------------








ok... mas e se, em um cenário hipotético,




MAIS UMA COLUMN FOR ADICIONADA, no futuro... (
   uma column que NAO ESTÁ NESSE JSON NOSSO, ANTIGO...
)









EXEMPLO:






SELECT 
v:phoneNumber.areaCode::string AS area_code,
v:phoneNumber.subscriberNumber::string AS subscriber_number,
v:phoneNumber:extensionNumber::string AS extension_number -- essa column nao existia antes/nao existe na nossa json data atual....
FROM json_demo;















--> COMO ESSA COLUMN NAO EXISTE NA NOSSA CURRENT 

JSON DATA,

O QUE VAI ACONTECER É QUE 


ESSA DATA/A COLUMN DE "extension_number"


VAI APARECER COMO "NULL" (para essa entry aí)...












EX:






area_code      subscriberNumber        EXTENSION_NUMBER
415            55234233424             1231221313











QUER DIZER QUE NAO HÁ RISCO ALGUM DE SUA 
QUERY SER CANCELADA 


SE, NO FUTURO,

MAIS COLUMNS FOREM ADICIONADAS...











--> OK... AGORA DEVEMOS IR EM FRENTE 


E PASSAR 

O ARRAY, DENTRO DO JSON ,

NA NOSSA QUERY...



TIPO ASSIM:














SELECT 
v:children[0].name::string FROM json_demo
UNION ALL
SELECT v:children[1].name::string FROM json_demo
UNION ALL 
SELECT v:children[2].name::string FROM json_demo;












--> COM ESSA QUERY, QUE JÁ VIMOS ANTES,




O OUTPUT 


FICA ASSIM:




V:children[0].name.string 

JAYDEN 
EMILY 
MADELYN










OU SEJA,

CONSEGUIMOS O NOME DAS CHILDREN...









--> OK... MAS SE TIVERMOS MTAS NESTED 

STRUCTURES, TIPO ASSIM,



COMEÇA A FICAR MT DIFÍCIL 




ESCREVER A QUERY USANDO "union all"













--> QUANDO ISSO COMECA A ACONTECER,


O QUE DEVEMOS FAZER, NO SNOWFLAKE,

É 

USAR UMA DAS FUNCTIONS MAIS ÚTEIS 


DELE,

QUE É 

"FLATTEN()"...










--> USAMOS "FLATTEN()" JUNTO COM "TABLE()",


TIPO ASSIM:









-- table function with FLATTEN:




SELECT 
F.value:name::string AS child_name,
F.value:gender::string AS child_gender,
F.value::string AS child_age
FROM json_demo, TABLE(flatten(v:children)) AS F;
















--> ISSO FAZ COM QUE FIQUEMOS COM O MESMO OUTPUT 

DE ANTES,


MAS COM BEM MENOS CÓDIGO (sem todos aqueles 
union alls horríveis)...












--> TAMBÉM PODEMOS MISTURARA ESSAS INFOS,

DAS CHILD,

COM AS INFO DO PARENT DELAS,

TIPO ASSIM:










SELECT
v:fullName::string AS parent_name,
F.value:name::string AS child_name,
F.value:gender::string AS child_gender,
F.value::string AS child_age
FROM json_demo, TABLE(flatten(v:children)) AS F;















--> PARA CHECARMOS QUANTAS CRIANCAS O JOHN TEM,


podemos rodar assim:







SELECT 
v:fullName::string AS parent_name,
array_size(v:children) AS number_of_children
FROM json_demo;






VEREMOS:








Johnny            3  



(3 children...)..











--> OK.... MAS EM QUANTAS CITIES 

O JOHN VIVE,


E QUANTAS CHILDREN ELE TEM..








--> PODEMOS RODAR ASSIM:




SELECT 
v:fullName::string AS parent_name,
array_size(v:citiesLived) AS cities_lived_in,
array_size(v:children) AS number_of_children
FROM json_demo;







CADA 

"CITY" também existe como object dentro 

da list de cities,

dentro do json,



POR ISSO 

PODEMOS 

PARSEAR MAIS AINDA...













---- Parse array within array 






SELECT 
c1.value:cityName::string AS city_name,
y1.value:string AS year_lived
FROM json_demo
TABLE(FLATTEN(v:citiesLived)) c1,  -- outer array 
TABLE(FLATTEN(c1.value.yearsLived)) y1  -- inner array
ORDER BY year_lived ASC;











OK... ISSO NOS MOSTRARÁ EM QUE CIDADE O 


JOHN VIVEU, em cada ano..

























-- {
--    "fullName":"Johnny Appleseed",
--    "age":42,
--    "gender":"Male",
--    "phoneNumber":{
--       "areaCode":"415",
--       "subscriberNumber":"5551234"
--    },
--    "children":[
--       {
--          "name":"Jayden",
--          "gender":"Male",
--          "age":"10"
--       },
--       {
--          "name":"Emma",
--          "gender":"Female",
--          "age":"8"
--       },
--       {
--          "name":"Madelyn",
--          "gender":"Female",
--          "age":"6"
--       }
--    ],
--    "citiesLived":[
--       {
--          "cityName":"London",
--          "yearsLived":[
--             "1989",
--             "1993",
--             "1998",
--             "2002"
--          ]
--       },
--       {
--          "cityName":"San Francisco",
--          "yearsLived":[
--             "1990",
--             "1993",
--             "1998",
--             "2008"
--          ]
--       },
--       {
--          "cityName":"Portland",
--          "yearsLived":[
--             "1993",
--             "1998",
--             "2003",
--             "2005"
--          ]
--       },
--       {
--          "cityName":"Austin",
--          "yearsLived":[
--             "1973",
--             "1998",
--             "2001",
--             "2005"
--          ]
--       }
--    ]
-- }'









ok... podemos facilmente parsear a json data,

portanto....







--> podemos attachear o parent name,

também, tipo assim:





SELECT
v:fullName::string AS parent_name,
c1.value:cityName::string AS city_name,
y1.value:string AS year_lived
FROM json_demo
TABLE(FLATTEN(v:citiesLived)) c1,  -- outer array 
TABLE(FLATTEN(c1.value.yearsLived)) y1  -- inner array
ORDER BY year_lived ASC;




TAMBÉM PODEMOS RODAR AGGREGATION,

TIPO ASSIM:








---- AGGREGATION ---- 



SELECT 
C1.value:cityName::string AS city_name,
count(*) AS year_lived
FROM json_demo
TABLE(FLATTEN(v:citiesLived)) C1,
TABLE(FLATTEN(c1.value:yearsLived)) Y1
GROUP BY city_name;








AÍ VEMOS:


LONDON         4
SAN FRANCISCO   4 


PORTLAND         4










TAMBÉM PODEMOS RODAR FILTERS, TIPO ASSIM:







SELECT 
C1.value:cityName::string AS city_name,
count(*) AS year_lived
FROM json_demo
TABLE(FLATTEN(v:citiesLived)) C1,
TABLE(FLATTEN(c1.value:yearsLived)) Y1
WHERE city_name = 'Portland'
GROUP BY city_name;


E PODEMOS AGRUPAR 



GROUP BY, FILTER,

QUALQUER OUTRO TIPO DE CONDITION...









ASSIM QUE VC PARSEOU A DATA, VC 
PODE A ARMAZENAR EM 1 TABLE,

OU USAR EM SUBQUERIES...