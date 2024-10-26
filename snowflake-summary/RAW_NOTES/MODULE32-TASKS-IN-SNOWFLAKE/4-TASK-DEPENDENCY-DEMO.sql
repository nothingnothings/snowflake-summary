



A SINTAXE DE DEPENDENCIES ENTRE TASKS É BEM SIMPLES:






CREATE TASK <task_name>
    AFTER <parent_task_name>
    AS ... (código normal de definicao dessa task, com o código sql a ser executado, o single statement a ser executado)























MAS O SEGUNDO PROFESSOR ESCREVE ASSIM:





--- SCENE 2:


CREATE TABLE TASK_1
(ITERATION NUMBER);




CREATE TABLE TASK_2
(ITERATION NUMBER);




CREATE TABLE TASK_3
(ITERATION NUMBER);



CREATE TABLE TASK_4
(ITERATION NUMBER);



CREATE TABLE TASK_5
(ITERATION NUMBER);



CREATE TABLE TASK_6
(ITERATION NUMBER);




CREATE TABLE TASK_7
(ITERATION NUMBER);












--> ENTAO O PROFESSOR CRIOU A "ROOT TASK",

com este comando:











CREATE TASK ROOT_TASK
    WAREHOUSE = COMPUTE_WH
    SCHEDULE='1 MINUTE'
AS INSERT INTO TASK_1 SELECT '1';

















-> PARA CRIAR AS TASKS DEPENDENTES DELA,


ELE ESCREVE:









CREATE TASK TASK_2
    WAREHOUSE = COMPUTE_WH
AFTER ROOT_TASK
AS INSERT INTO TASK_2 SELECT '2';





CREATE TASK TASK_3
    WAREHOUSE = COMPUTE_WH
AFTER TASK_2
AS INSERT INTO TASK_3 SELECT '3';




CREATE TASK TASK_4
    WAREHOUSE = COMPUTE_WH
AFTER TASK_3
AS INSERT INTO TASK_4 SELECT '4';




CREATE TASK TASK_5
    WAREHOUSE = COMPUTE_WH
AFTER TASK_4
AS INSERT INTO TASK_5 SELECT '5';





CREATE TASK TASK_6
    WAREHOUSE = COMPUTE_WH
AFTER TASK_5
AS INSERT INTO TASK_6 SELECT '6';



CREATE TASK TASK_7
    WAREHOUSE = COMPUTE_WH
AFTER TASK_6
AS INSERT INTO TASK_7 SELECT '7';


















--> ok... quer dizer que as tasks serao triggadas a partir 


do execute 




da ROOT_TASK (
    uma vai triggar a outra, consecutivamente...
)











--> PODEMOS CHECAR AS DEPENDENCIES 


ENTRE ESSAS TASKS,

COM ESTE COMANDO:











SHOW TASKS LIKE 'TASKS';













FICAMOS COM 1 LISTA DAS TASKS,



E AÍ 


DENTRO DE CADA 1 DELAS TEMOS 












created_on	name	id	database_name	schema_name	owner	comment	warehouse	schedule	predecessors	state	definition	condition	allow_overlapping_execution	error_integration	last_committed_on	last_suspended_on	owner_role_type	config
2023-08-23 06:59:18.025 -0700	ROOT_TASK	01ae8047-fc25-c825-0000-000000000001	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH	1 MINUTE	[]	suspended	INSERT INTO TASK_1 SELECT '1'		false	null			ROLE	
2023-08-23 07:03:06.995 -0700	TASK_2	01ae804b-3db6-103f-0000-000000000008	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH		[   "DEMO_DB.PUBLIC.ROOT_TASK" ]	suspended	INSERT INTO TASK_2 SELECT '2'		null	null			ROLE	
2023-08-23 07:03:07.507 -0700	TASK_3	01ae804b-face-424d-0000-000000000009	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH		[   "DEMO_DB.PUBLIC.TASK_2" ]	suspended	INSERT INTO TASK_3 SELECT '3'		null	null			ROLE	
2023-08-23 07:03:08.084 -0700	TASK_4	01ae804b-20da-76ea-0000-00000000000a	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH		[   "DEMO_DB.PUBLIC.TASK_3" ]	suspended	INSERT INTO TASK_4 SELECT '4'		null	null			ROLE	
2023-08-23 07:03:08.703 -0700	TASK_5	01ae804b-7a0d-3e5a-0000-00000000000b	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH		[   "DEMO_DB.PUBLIC.TASK_4" ]	suspended	INSERT INTO TASK_5 SELECT '5'		null	null			ROLE	
2023-08-23 07:03:09.304 -0700	TASK_6	01ae804b-6952-19ba-0000-00000000000c	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH		[   "DEMO_DB.PUBLIC.TASK_5" ]	suspended	INSERT INTO TASK_6 SELECT '6'		null	null			ROLE	
2023-08-23 07:03:09.835 -0700	TASK_7	01ae804b-d719-e232-0000-00000000000d	DEMO_DB	PUBLIC	ACCOUNTADMIN		COMPUTE_WH		[   "DEMO_DB.PUBLIC.TASK_6" ]	suspended	INSERT INTO TASK_7 SELECT '7'		null	null			ROLE	





















EM "PREDECESSORS",


é possível ver 



QUEM É O "PARENT" de cada 1 das tasks....







(o estranho é que o correto seria "predecessor", e nao 

"predecessors", pq tasks nao podem ter 2 parents)....














O PROFESSOR ENTAO ALTERA O STATE 



DA ROOT_TASK



PARA RESUMED,


COM 



ALTER TASK ROOT_TASK RESUME;














--> ESSA TASK AGORA ESTARÁ COMO "STARTED"...










--> MAS AS OUTRAS TASKS  AINDA NAO ESTARAO STARTADAS,

ESTARAO COMO "SUSPENDED"...











--> PRECISAMOS RESUMIR TUDO,

COM ESTES COMANDOS:






ALTER TASK ROOT_TASK RESUME;

ALTER TASK TASK_2 RESUME;
ALTER TASK TASK_3 RESUME;
ALTER TASK TASK_4 RESUME;
ALTER TASK TASK_5 RESUME;
ALTER TASK TASK_6 RESUME;
ALTER TASK TASK_7 RESUME;









MAS AÍ GANHAMOS O ERRO DE "ORDEM", QUE É ESTE:








Unable to update graph with root task DEMO_DB.PUBLIC.ROOT_TASK since that root task is not suspended.









--> PARA RESOLVER ISSO, DEVEMOS SUSPENDER A ROOT TASK,

E AÍ


COMECAR O RESUME DAS CHILD TASKS...





ex:















ALTER TASK ROOT_TASK SUSPEND;

ALTER TASK TASK_2 RESUME;
ALTER TASK TASK_3 RESUME;
ALTER TASK TASK_4 RESUME;
ALTER TASK TASK_5 RESUME;
ALTER TASK TASK_6 RESUME;
ALTER TASK TASK_7 RESUME;

ALTER TASK ROOT_TASK RESUME;







--> CERTO, AÍ PODEMOS CHECAR OS RESULTS,
ASSIM:






SELECT * FROM TASK_1;
SELECT * FROM TASK_2;
SELECT * FROM TASK_7;












OK, FUNCIONOU....













--> MAS ESSA FEATURE DAS TASKS É MEIO RECENTE,


PQ TEMOS QUE PARAR E STARTAR CADA TASK MANUALMENTE...









TAMBÉM TEMOS A LIMITACAO 

DE "APENAS 1 PARENT POR TASK"...







-->  E TAMBÉM NAO EXISTE NENHUMA NOTIFICATION, EM CASO DE TASK FAILURE.....






PARA SUSPENDERMOS NOSSAS TASKS,

TEMOS DE RODAR ASSIM:












ALTER TASK ROOT_TASK SUSPEND;

ALTER TASK TASK_2 SUSPEND;
ALTER TASK TASK_3 SUSPEND;
ALTER TASK TASK_4 SUSPEND;
ALTER TASK TASK_5 SUSPEND;
ALTER TASK TASK_6 SUSPEND;
ALTER TASK TASK_7 SUSPEND;