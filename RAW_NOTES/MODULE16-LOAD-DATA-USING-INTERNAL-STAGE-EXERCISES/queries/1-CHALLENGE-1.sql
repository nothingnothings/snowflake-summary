DEVEMOS PEGAR A DATA LÁ 


DO repo github do professor...




--> temos a pasta de "Practice Data"...








--> temos o folder de "countries",

que tem 1 

lista 


de population data, 

para cada 1 dos countries..










--> o professor usa o gitpod, mas vou usar o ambiente 
local...






--> devemos entrar no snowsql...








QUE PROBLEMA RESOLVEREMOS, NESSE EXERCISE?









TEMOS O FOLDER DE COUNTRIES...












--> CHALLENGE:



1) CREATE INTERNAL STAGE BY NAME, POPULATION...



(named stage, de nome "population")..







2) WRITE A PUT COMMAND (upload),


PARA UPLOADAR AS FILES 


PARA DENTRO DESSE STAGE...




--> temos que UPLOADAR TODAS AS FILES


PARA DENTRO DO STAGE,

MAS AS FILES DEVEM 



FICAR EM FOLDERS COM UM FORMATO DE 





COUNTRIES_A 


COUNTRIES_B 


COUNTRIES_C (todos países que comecam com a letra C, etc)...




---------------------







ok... agora vamos tentar resolver essa challenge...






faço login no snowsql, nada de mais...






--> preciso criar 1 named stage, faço isso 

dentro de uma worksheet...








EX:







-- named stage (INTERNAL)
CREATE OR REPLACE STAGE countries_stage;













--> DEPOIS, PRECISO DAS FILES, QUE VOU COLOCAR NA PASTA 
"countries-to-be-loaded"...











OK.... CONSEGUI...





O FORMATO DO PUT FICOU TIPO ASSIM:






put file:///home/arthur/Desktop/PROJETO-SQL-2/MODULE16-LOAD-DATA-USING-INTERNAL-STAGE-EXERCISES/countries-to-be-loaded/z*.csv  
@demo_db.public.countries_stage/countries_Z;








ok... sucesso:













nothingnothings#COMPUTE_WH@(no database).(no schema)>ls @demo_db.public.countr
                                                     ies_stage;
                                                                              +--------------------------------------------------------------------------------+------+----------------------------------+-------------------------------+
| name                                                                           | size | md5                              | last_modified                 |
|--------------------------------------------------------------------------------+------+----------------------------------+-------------------------------|
| countries_stage/countries_A/afghanistan-population.csv.gz                      |  960 | cb7e27afa3225fcb2898ff300821134d | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/albania-population.csv.gz                          |  896 | 374a28a17677013e4df3ffb7852eac34 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/algeria-population.csv.gz                          |  960 | cc55d12d66868bc717cb6acd7fd1b843 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/american-samoa-population.csv.gz                   |  672 | d6625caf5f262f033ae30298ae32dde7 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/andorra-population.csv.gz                          |  672 | 9d0a0a450ba2f7c00a3c05b8b8b32766 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/angola-population.csv.gz                           |  944 | 85df5c6e8724cc705110e76830750f43 | Wed, 16 Aug 2023 14:05:06 GMT |
| countries_stage/countries_A/anguilla-population.csv.gz                         |  624 | 1761448348f305f084eed00a8949ab17 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/antigua-and-barbuda-population.csv.gz              |  880 | 8f1060bf05199f8368bd1f41dec26d7e | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/argentina-population.csv.gz                        |  912 | d978984f33f590664a4c9eb5dd5d3e7b | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/armenia-population.csv.gz                          |  912 | c40a0f4c02f9a66fec29714f861b71dc | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/aruba-population.csv.gz                            |  848 | a7dc03f6077ff869eff7fc8cbf9d2c64 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/australia-population.csv.gz                        |  928 | d3314d92351fa5b60f91be282d3c8a55 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/austria-population.csv.gz                          |  912 | c3a45f162c2b6a4185f45c8203911fdb | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_A/azerbaijan-population.csv.gz                       |  912 | 3259f496c2a3589a78572afd533c8d97 | Wed, 16 Aug 2023 14:05:08 GMT |
| countries_stage/countries_B/bahamas-population.csv.gz                          |  864 | cad7ae378966bab2e88c1238c0b08f18 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/bahrain-population.csv.gz                          |  912 | 7dad19e638df216f68666f8d52e0d901 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/bangladesh-population.csv.gz                       |  992 | 063241a1aa7ce63f54726dedb65a3697 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/barbados-population.csv.gz                         |  864 | d4a482d34d9f96b5bb5b3c8e1bb37f1f | Wed, 16 Aug 2023 14:05:26 GMT |
| countries_stage/countries_B/belarus-population.csv.gz                          |  928 | e5386b4fdd2fc42d5c501e7acf7f9c52 | Wed, 16 Aug 2023 14:05:26 GMT |
| countries_stage/countries_B/belgium-population.csv.gz                          |  928 | a9ee730b34d3c9eb7ea75568e6723d54 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/belize-population.csv.gz                           |  864 | 319e8c6ace8a8b7fc0b1109f328bc504 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/benin-population.csv.gz                            |  928 | dfef0a06a38adc22e9c28a8c1eac7040 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/bermuda-population.csv.gz                          |  656 | acd5cb3756f7f80d6378750724879b34 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/bhutan-population.csv.gz                           |  832 | e053c3bece2a909b8cb974cda50a587a | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/bolivia-population.csv.gz                          |  912 | c30efcba09401d11e840650e4ba2fa83 | Wed, 16 Aug 2023 14:05:26 GMT |
| countries_stage/countries_B/bosnia-and-herzegovina-population.csv.gz           |  976 | 7ed44881359de10812c97671380781c9 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/botswana-population.csv.gz                         |  896 | 1b90cc37cf9fa700c4d111d79e7df58f | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/brazil-population.csv.gz                           |  944 | dee865bb5dc0332f27e2ee1f83d39d50 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/british-virgin-islands-population.csv.gz           |  688 | eef2767a1428cb85cc930eeeec5890ca | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/brunei-population.csv.gz                           |  864 | d761b59b9b4150125a6ada08c0d88bee | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/bulgaria-population.csv.gz                         |  944 | 71ec73061da62056259d6e6fcc3f668c | Wed, 16 Aug 2023 14:05:26 GMT |
| countries_stage/countries_B/burkina-faso-population.csv.gz                     |  944 | 14dcdfbe7b0a2e6fdcff6051d5f1a858 | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_B/burundi-population.csv.gz                          |  944 | 153b1a7e11e646e9e91ee06b3f25e15e | Wed, 16 Aug 2023 14:05:27 GMT |
| countries_stage/countries_C/cabo-verde-population.csv.gz                       |  896 | 18cb5d2edf3d2a636db8a82888c279f1 | Wed, 16 Aug 2023 14:05:43 GMT |
| countries_stage/countries_C/cambodia-population.csv.gz                         |  928 | cdc1f78111b8f23e4852984c1452a955 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/cameroon-population.csv.gz                         |  944 | 7a977a3147e362e2ee75a8f5a842645a | Wed, 16 Aug 2023 14:05:43 GMT |
| countries_stage/countries_C/canada-population.csv.gz                           |  912 | 0e8873109e2d1773b037cb6e756516f9 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/caribbean-netherlands-population.csv.gz            |  672 | 634a06988e1f8dd70b13a7609fa0184f | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/cayman-islands-population.csv.gz                   |  656 | aff43be114378bd04bf2ebecf74c20ab | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/central-african-republic-population.csv.gz         |  928 | a7e9e8af7d176d88b62e8f84e8322a98 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/chad-population.csv.gz                             |  912 | ab37e75361a73a9707a908b642aa278c | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/channel-islands-population.csv.gz                  |  880 | d389e067858071c1b6a567df7322253e | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/chile-population.csv.gz                            |  944 | 6755ab811b87501524d240f548887682 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/china-population.csv.gz                            | 1024 | 7f66c6915fac26203105086715b56d3b | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/colombia-population.csv.gz                         |  960 | 1de76f785ce6ab07373bf71fed35e797 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/comoros-population.csv.gz                          |  848 | d0086dcc9f51d89d0a0c96dc24ac7753 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/congo-population.csv.gz                            |  880 | 5f418c1262650bfadeb553c2fd05d511 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/cook-islands-population.csv.gz                     |  656 | 21ffeeed8b866d72200a1da618da0391 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/costa-rica-population.csv.gz                       |  928 | df93fd10bb787b8e4afc7e0de4c38375 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/cote-d-ivoire-population.csv.gz                    |  960 | 07c268af6e9a52c3af9d83201a0ad63e | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/croatia-population.csv.gz                          |  912 | e8b0b572da22affb933442d5fbad6773 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/cuba-population.csv.gz                             |  928 | fe6eced1bb630131942f6538066b4f19 | Wed, 16 Aug 2023 14:05:42 GMT |
| countries_stage/countries_C/curaao-population.csv.gz                           |  880 | d26388c2db06a827b12189b3f568e362 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/cyprus-population.csv.gz                           |  880 | 1dfd028af3b6428987ffc8d9231d01c0 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_C/czech-republic-population.csv.gz                   |  928 | af606d68caecc30f7f4683a179f85014 | Wed, 16 Aug 2023 14:05:41 GMT |
| countries_stage/countries_D/democratic-republic-of-the-congo-population.csv.gz | 1024 | f9ef57f33a8e8b5d1c8567ff06958aec | Wed, 16 Aug 2023 14:05:57 GMT |
| countries_stage/countries_D/denmark-population.csv.gz                          |  928 | 298d6a20162bd56cf24d928e319ea610 | Wed, 16 Aug 2023 14:05:56 GMT |
| countries_stage/countries_D/djibouti-population.csv.gz                         |  880 | 541d09018a08863446fcb376d00c63c9 | Wed, 16 Aug 2023 14:05:56 GMT |
| countries_stage/countries_D/dominica-population.csv.gz                         |  656 | ea7223aa0e8a2d0d0907de9452b2bdea | Wed, 16 Aug 2023 14:05:56 GMT |
| countries_stage/countries_D/dominican-republic-population.csv.gz               |  960 | ccb891a2aff47ab8330107c88291ade9 | Wed, 16 Aug 2023 14:05:56 GMT |
| countries_stage/countries_E/ecuador-population.csv.gz                          |  928 | f9d1c2cd224a4c8c6fe5cd1ec45ed31f | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_E/egypt-population.csv.gz                            |  960 | 2dcb5f3e31912fc31a8f14c3dedf3b3e | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_E/el-salvador-population.csv.gz                      |  944 | 3e8673e18a999e4b8d8a2ccf35eb9e80 | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_E/equatorial-guinea-population.csv.gz                |  912 | 44cf3707049881adb4c9aa97afb85db3 | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_E/eritrea-population.csv.gz                          |  896 | 40ea1361d98c51b6794192b782b78d2e | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_E/estonia-population.csv.gz                          |  880 | d8b3104302f119f409a64e85099ca9bf | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_E/ethiopia-population.csv.gz                         |  976 | 4e4f6d5074df071786c1161f33cb4a85 | Wed, 16 Aug 2023 14:06:07 GMT |
| countries_stage/countries_F/faeroe-islands-population.csv.gz                   |  656 | 46430dfcf673c7d877926a9ba1ca971b | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_F/falkland-islands-malvinas-population.csv.gz        |  640 | 9fa5658c6e234bc3eeb739029423cc5a | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_F/fiji-population.csv.gz                             |  880 | 7f1c209fcdcf2897b2894aec12322962 | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_F/finland-population.csv.gz                          |  896 | d123f91edf256092dd3ce7dc1dcb6787 | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_F/france-population.csv.gz                           |  960 | 52625a70af425946c347adfb331bc7d4 | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_F/french-guiana-population.csv.gz                    |  864 | 4ef095d94ced71a85536971c5d10a3b3 | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_F/french-polynesia-population.csv.gz                 |  880 | 7f60d7cabc49d90720bddbd934483064 | Wed, 16 Aug 2023 14:06:21 GMT |
| countries_stage/countries_G/gabon-population.csv.gz                            |  848 | df8b12361057234b66712f52ca872591 | Wed, 16 Aug 2023 14:06:31 GMT |
| countries_stage/countries_G/gambia-population.csv.gz                           |  896 | 41be1502f0627cc880a875368498f5a0 | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/georgia-population.csv.gz                          |  944 | eb6704c3227adbf4b28b87e2c61b4e45 | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/germany-population.csv.gz                          |  960 | d6de5ef196091a14fe9e44db39c53801 | Wed, 16 Aug 2023 14:06:31 GMT |
| countries_stage/countries_G/ghana-population.csv.gz                            |  960 | 55e9867007ecab87a953ad7ed9f7f047 | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/gibraltar-population.csv.gz                        |  608 | 0284e3fe99a46f4d5ce771e1dc66f640 | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/greece-population.csv.gz                           |  944 | 31f1ed925b5e424a4bbfb1990f7924a3 | Wed, 16 Aug 2023 14:06:32 GMT |
| countries_stage/countries_G/greenland-population.csv.gz                        |  640 | 509aa00734c9e731b34a0e63dff5710a | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/grenada-population.csv.gz                          |  848 | 7bac1b1cd85a025943365e1dd7c41287 | Wed, 16 Aug 2023 14:06:31 GMT |
| countries_stage/countries_G/guadeloupe-population.csv.gz                       |  832 | ec1e0987644b3def0e7bc5dc0db05d43 | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/guam-population.csv.gz                             |  848 | 78784b18b94ea0eb8749d0347ea2aa55 | Wed, 16 Aug 2023 14:06:31 GMT |
| countries_stage/countries_G/guatemala-population.csv.gz                        |  960 | 0b4865e468c0bc07b99fc11abfabe877 | Wed, 16 Aug 2023 14:06:30 GMT |
| countries_stage/countries_G/guinea-bissau-population.csv.gz                    |  912 | 4e7f92e052a05a6356da5abcb3c49e28 | Wed, 16 Aug 2023 14:06:32 GMT |
| countries_stage/countries_G/guinea-population.csv.gz                           |  928 | f81e23990c853ab5e5953869727cb0ae | Wed, 16 Aug 2023 14:06:31 GMT |
| countries_stage/countries_G/guyana-population.csv.gz                           |  848 | 667b5d110751be5d15b9b428c044779d | Wed, 16 Aug 2023 14:06:31 GMT |
| countries_stage/countries_H/haiti-population.csv.gz                            |  912 | 0cc67664a04cb33ad5c2b34b5b358e50 | Wed, 16 Aug 2023 14:06:41 GMT |
| countries_stage/countries_H/holy-see-population.csv.gz                         |  544 | 1b4034f37f057b64b3fc827bfca93506 | Wed, 16 Aug 2023 14:06:41 GMT |
| countries_stage/countries_H/honduras-population.csv.gz                         |  928 | 2c5bbdf36985a61cdc87034215cae889 | Wed, 16 Aug 2023 14:06:41 GMT |
| countries_stage/countries_H/hong-kong-population.csv.gz                        |  880 | 221aa378c5688a18e08a1c8a0afe7278 | Wed, 16 Aug 2023 14:06:42 GMT |
| countries_stage/countries_H/hungary-population.csv.gz                          |  928 | 3b1f53eb5a115d3ae592a08b4cd1f6c8 | Wed, 16 Aug 2023 14:06:41 GMT |
| countries_stage/countries_I/iceland-population.csv.gz                          |  848 | 91eaf8994fa4b53a4abfdaca5aea4e75 | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/india-population.csv.gz                            | 1024 | e5fed0c9d418efc34b54cdfb6ef97b14 | Wed, 16 Aug 2023 14:06:52 GMT |
| countries_stage/countries_I/indonesia-population.csv.gz                        |  992 | d6d699de0ee5f7f47408ea7f66749292 | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/iran-population.csv.gz                             |  960 | 077fa6d27d5e510591ee2ef921b54b8d | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/iraq-population.csv.gz                             |  976 | 2567b959fde7dd5ddacd20307c7c6a39 | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/ireland-population.csv.gz                          |  928 | 2aeda093bf2c06f2d05597ff6f752bf9 | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/isle-of-man-population.csv.gz                      |  672 | 1900dba549557cbc949f70cbbd01371e | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/israel-population.csv.gz                           |  912 | c5ba606b51e4b5fb69702a827bde0bce | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_I/italy-population.csv.gz                            |  944 | 3fec6ae71eea8cb04137a63ecda77516 | Wed, 16 Aug 2023 14:06:51 GMT |
| countries_stage/countries_J/jamaica-population.csv.gz                          |  928 | 0112960c14f36dac849c9e313932de28 | Wed, 16 Aug 2023 14:07:00 GMT |
| countries_stage/countries_J/japan-population.csv.gz                            |  976 | baf9323af8d3a75231faa3c4d505a99c | Wed, 16 Aug 2023 14:07:00 GMT |
| countries_stage/countries_J/jordan-population.csv.gz                           |  960 | 5530c2b1ed869983d8945dfccea696e7 | Wed, 16 Aug 2023 14:07:00 GMT |
| countries_stage/countries_K/kazakhstan-population.csv.gz                       |  944 | 15dd9307668a1210b198a461ebbe653b | Wed, 16 Aug 2023 14:07:10 GMT |
| countries_stage/countries_K/kenya-population.csv.gz                            |  960 | e2db8d42b9b41e0fe1bfaa292f741d45 | Wed, 16 Aug 2023 14:07:10 GMT |
| countries_stage/countries_K/kiribati-population.csv.gz                         |  864 | b230489513c4cf0cadfd9708896f6dd0 | Wed, 16 Aug 2023 14:07:10 GMT |
| countries_stage/countries_K/kuwait-population.csv.gz                           |  896 | fb63ecba85e8d7c4012f65630657af82 | Wed, 16 Aug 2023 14:07:10 GMT |
| countries_stage/countries_K/kyrgyzstan-population.csv.gz                       |  912 | d2d71b6b77d52744f5dfc7a1e603283b | Wed, 16 Aug 2023 14:07:10 GMT |
| countries_stage/countries_L/laos-population.csv.gz                             |  880 | 72e845377539660bcd03414a0563a1e2 | Wed, 16 Aug 2023 14:07:18 GMT |
| countries_stage/countries_L/latvia-population.csv.gz                           |  912 | 2fa6d82fa2e1f6096f4c7b81fcf4aefc | Wed, 16 Aug 2023 14:07:17 GMT |
| countries_stage/countries_L/lebanon-population.csv.gz                          |  928 | cbe0513ce7675291472f5bf8ffa5c0e1 | Wed, 16 Aug 2023 14:07:17 GMT |
| countries_stage/countries_L/lesotho-population.csv.gz                          |  896 | 8824ff008de0f75e8bcb5372cd74fcc6 | Wed, 16 Aug 2023 14:07:18 GMT |
| countries_stage/countries_L/liberia-population.csv.gz                          |  912 | 1bca7e7f400e31aff04060f44f8b089f | Wed, 16 Aug 2023 14:07:18 GMT |
| countries_stage/countries_L/libya-population.csv.gz                            |  912 | bbeb0ae20dded7d77db01f96610b870c | Wed, 16 Aug 2023 14:07:18 GMT |
| countries_stage/countries_L/liechtenstein-population.csv.gz                    |  656 | a0315cc541607b89535c44ddd0b4b020 | Wed, 16 Aug 2023 14:07:18 GMT |
| countries_stage/countries_L/lithuania-population.csv.gz                        |  944 | cc408a9ef4b7a610b384756eb6d5e8d7 | Wed, 16 Aug 2023 14:07:17 GMT |
| countries_stage/countries_L/luxembourg-population.csv.gz                       |  896 | fe6233a5da4ab298d9ed5cd789a78b71 | Wed, 16 Aug 2023 14:07:17 GMT |
| countries_stage/countries_M/macao-population.csv.gz                            |  880 | fd9058c595f7f0fb006c0a7851c62566 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/madagascar-population.csv.gz                       |  928 | 1bcf0eddb0f54d0b2f1a657657337c04 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/malawi-population.csv.gz                           |  928 | 82e3b9d1a068d8d825d04dcbd6d471e3 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/malaysia-population.csv.gz                         |  960 | 1b2529573da613f41cca95d1dedb3a7e | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/maldives-population.csv.gz                         |  880 | 8733ad82a0d11f912d1611155631af98 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/mali-population.csv.gz                             |  912 | 9080ce60ad724922c4d5a8181f4d72b9 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/malta-population.csv.gz                            |  864 | 3ff6ce9639619ae5d8f6ccb2f78f98c3 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/marshall-islands-population.csv.gz                 |  688 | 795e5fa836ba799dc5ef1999add1b57c | Wed, 16 Aug 2023 14:07:25 GMT |
| countries_stage/countries_M/martinique-population.csv.gz                       |  880 | 5fb2bfb2b72196078fc0c21168c22a7c | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/mauritania-population.csv.gz                       |  896 | 59d752d0176b08f820289f4a53f03d99 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/mauritius-population.csv.gz                        |  896 | 5445120408ad7c0c752b7f0d2645bca6 | Wed, 16 Aug 2023 14:07:25 GMT |
| countries_stage/countries_M/mayotte-population.csv.gz                          |  864 | 3d7d4a659b56481ed3d62e4549ada194 | Wed, 16 Aug 2023 14:07:27 GMT |
| countries_stage/countries_M/mexico-population.csv.gz                           |  992 | 21e2e1b15832f22e924fa95196813805 | Wed, 16 Aug 2023 14:07:27 GMT |
| countries_stage/countries_M/micronesia-population.csv.gz                       |  880 | 8eac1ae21c3718cb450b83f704a2663b | Wed, 16 Aug 2023 14:07:27 GMT |
| countries_stage/countries_M/moldova-population.csv.gz                          |  912 | bcaf6b13b2d616bedddbb0d80d0cc0f5 | Wed, 16 Aug 2023 14:07:27 GMT |
| countries_stage/countries_M/monaco-population.csv.gz                           |  624 | d49a3c2cde44d6e1c271090a906025eb | Wed, 16 Aug 2023 14:07:27 GMT |
| countries_stage/countries_M/mongolia-population.csv.gz                         |  864 | 02cf198cf6a019593def4eb82d134dbe | Wed, 16 Aug 2023 14:07:25 GMT |
| countries_stage/countries_M/montenegro-population.csv.gz                       |  864 | 5fc080c71ea4ea877530b04cf90c7627 | Wed, 16 Aug 2023 14:07:25 GMT |
| countries_stage/countries_M/montserrat-population.csv.gz                       |  624 | faded4064039e0a0a6c9d013a9f731c1 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/morocco-population.csv.gz                          |  960 | 5f12becc4bbcaa603ebc2c6de36f5341 | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/mozambique-population.csv.gz                       |  944 | 1617df9e8dfaf259c2b679aac3ef056c | Wed, 16 Aug 2023 14:07:26 GMT |
| countries_stage/countries_M/myanmar-population.csv.gz                          |  928 | 4124d5792860dfb5473fc75fa87e3521 | Wed, 16 Aug 2023 14:07:27 GMT |
| countries_stage/countries_N/namibia-population.csv.gz                          |  864 | ad4a47c11d29aa12a21c176893feb1bd | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/nauru-population.csv.gz                            |  608 | 9d8b2ee884284bb4dc3e31a5cd11e824 | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/nepal-population.csv.gz                            |  928 | f2cfa71726fd3970fdfb1ffcb0dae8e7 | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/netherlands-population.csv.gz                      |  960 | 3d7a9e4533ffa757335e2340af9056e4 | Wed, 16 Aug 2023 14:07:34 GMT |
| countries_stage/countries_N/new-caledonia-population.csv.gz                    |  864 | 78d58f4535449e964df4b93c6e564e3e | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/new-zealand-population.csv.gz                      |  928 | 3b84b94091f84607bc599b110adf502a | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/nicaragua-population.csv.gz                        |  928 | c15823bb86175eacdd13f459cf1fd081 | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/niger-population.csv.gz                            |  896 | 01e25a6dabb6e605444e239bdaac04fa | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/nigeria-population.csv.gz                          |  976 | 18c6998d754164f6ba6f8e10598ea555 | Wed, 16 Aug 2023 14:07:34 GMT |
| countries_stage/countries_N/niue-population.csv.gz                             |  592 | d9249565570302764e597628cccd3a0b | Wed, 16 Aug 2023 14:07:34 GMT |
| countries_stage/countries_N/north-korea-population.csv.gz                      |  960 | ea3d56d21c32e0653138b70e75cef38e | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/north-macedonia-population.csv.gz                  |  912 | c51921152d85db633d12eaaa8ecb005d | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_N/northern-mariana-islands-population.csv.gz         |  704 | b604d7ce1ad98a63f1d4bd8e12839df3 | Wed, 16 Aug 2023 14:07:34 GMT |
| countries_stage/countries_N/norway-population.csv.gz                           |  912 | 06fae23236cc22604d10a483ebb919be | Wed, 16 Aug 2023 14:07:35 GMT |
| countries_stage/countries_O/oman-population.csv.gz                             |  896 | 2ec535c11acc9aab930d28467075311f | Wed, 16 Aug 2023 14:07:43 GMT |
| countries_stage/countries_P/pakistan-population.csv.gz                         |  992 | 6b990cfe6a3adcd3cf2e6ecdc0337065 | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_P/palau-population.csv.gz                            |  640 | 2f884ce2fa673579faa80aceea0376a7 | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_P/panama-population.csv.gz                           |  912 | f1f7cffe1a9eb871c82191aee12eff9a | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_P/papua-new-guinea-population.csv.gz                 |  928 | 8ef8c6dfeedc283973147b9fbc99cb9d | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_P/paraguay-population.csv.gz                         |  928 | 01f612ce5c2126a025b553c3cd027c55 | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_P/peru-population.csv.gz                             |  944 | 97bd2a3c8f8cfae4d5aaa9cfbf143406 | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_P/philippines-population.csv.gz                      | 1008 | 7f42c6f29de45b143c8309bc515c731f | Wed, 16 Aug 2023 14:07:52 GMT |
| countries_stage/countries_P/poland-population.csv.gz                           |  944 | 3422e6157b5d0657a4aad1bcf1a3e04f | Wed, 16 Aug 2023 14:07:52 GMT |
| countries_stage/countries_P/portugal-population.csv.gz                         |  944 | e77dca890c5214bb972f36c6b0f0b7dd | Wed, 16 Aug 2023 14:07:52 GMT |
| countries_stage/countries_P/puerto-rico-population.csv.gz                      |  928 | f2bf495e31c627155f229a7c14a7cc46 | Wed, 16 Aug 2023 14:07:51 GMT |
| countries_stage/countries_Q/qatar-population.csv.gz                            |  912 | 93527e94f7bdd4cbce8e215d096d5454 | Wed, 16 Aug 2023 14:07:58 GMT |
| countries_stage/countries_R/reunion-population.csv.gz                          |  880 | 839f35a2bbe7923bfa2d869cf499159e | Wed, 16 Aug 2023 14:08:08 GMT |
| countries_stage/countries_R/romania-population.csv.gz                          |  944 | f6bc743f49fc032c8cc589612f1d9623 | Wed, 16 Aug 2023 14:08:08 GMT |
| countries_stage/countries_R/russia-population.csv.gz                           |  944 | 1a844682716c1fde8bacfe6641230735 | Wed, 16 Aug 2023 14:08:08 GMT |
| countries_stage/countries_R/rwanda-population.csv.gz                           |  912 | 83926eeba90ff559719d4df3b43d010e | Wed, 16 Aug 2023 14:08:08 GMT |
| countries_stage/countries_S/saint-barthelemy-population.csv.gz                 |  576 | 726ebeab4d878fe929ae801bb186d482 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/saint-helena-population.csv.gz                     |  640 | 7aec9e9594783e2fe399ca4203c56a74 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/saint-kitts-and-nevis-population.csv.gz            |  688 | cd45c2c93ec54051bf6c2e4382552e82 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/saint-lucia-population.csv.gz                      |  864 | 5bd70567104fc2e02ee6fa00048a2182 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/saint-martin-population.csv.gz                     |  592 | 7228ebb6db531c7295d6ed7eae348777 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/saint-pierre-and-miquelon-population.csv.gz        |  656 | 3a36713e8146281332dae684ab8109c2 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/saint-vincent-and-the-grenadines-population.csv.gz |  928 | 5cb05d02d384a83b14ac8be0a4da0bab | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/samoa-population.csv.gz                            |  848 | 68649283cd117e0f95dc14ddb049be53 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/san-marino-population.csv.gz                       |  672 | 8d9d8061a0af0fcdb8c3a40955416688 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/sao-tome-and-principe-population.csv.gz            |  896 | 1c5a2408e6fb90e2300836058cbce059 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/saudi-arabia-population.csv.gz                     |  960 | 092c97243708136a75f6702783ca48be | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/senegal-population.csv.gz                          |  944 | c68a82ddbc3ac54a91d0d423ba6dc6ac | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/serbia-population.csv.gz                           |  928 | d762c57e0ac3fe009c70f4b2721cacc0 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/seychelles-population.csv.gz                       |  864 | 493ad9704a5c7ee6500060526e2fa303 | Wed, 16 Aug 2023 14:08:18 GMT |
| countries_stage/countries_S/sierra-leone-population.csv.gz                     |  912 | f5fbe6186ee9dca9ac3731460d0c4a9a | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/singapore-population.csv.gz                        |  896 | 1cd34e7fea6954ea5ecc8097cb9cb3cb | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/sint-maarten-population.csv.gz                     |  672 | fd5a0398b49e2ceaaecaab4106ff7d47 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/slovakia-population.csv.gz                         |  896 | b44e6d1011c21e2db6279b21719d13c6 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/slovenia-population.csv.gz                         |  896 | 64c570cc3251e35cf4edbaca0342f2ac | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/solomon-islands-population.csv.gz                  |  880 | 9cc3b6feb489581a571d8a315090cdc5 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/somalia-population.csv.gz                          |  928 | 8f98c8346aee7fa9b58f642cc2bcf30e | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/south-africa-population.csv.gz                     |  960 | 47baeddf1c79f1646b1222b87d3825fc | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/south-korea-population.csv.gz                      |  976 | 2d9d13df57eb400904191b881fa30236 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/south-sudan-population.csv.gz                      |  912 | fca382a1538bf46eb4d5df943ad9befb | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/spain-population.csv.gz                            |  944 | 3620ccb164e16ff0cad1af93de213035 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/sri-lanka-population.csv.gz                        |  928 | 3d56ade8f7fcebd4a79aadd2b78e0cde | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/state-of-palestine-population.csv.gz               |  976 | 4ae10bd65b8506675cce7472d870041c | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/sudan-population.csv.gz                            |  928 | aec417044e0e9d7dc6fe3d4588fa56cf | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/suriname-population.csv.gz                         |  864 | 82e59c4cb637f790e55dc673cb3dd991 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/swaziland-population.csv.gz                        |  896 | 34e19618599eaa08eb38bdb9b0221973 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/sweden-population.csv.gz                           |  896 | 949b851f60d93be4686f1e7b80fe3933 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_S/switzerland-population.csv.gz                      |  944 | 17dca66fcdb3228aa30a8997aed767b6 | Wed, 16 Aug 2023 14:08:17 GMT |
| countries_stage/countries_S/syria-population.csv.gz                            |  960 | 523352fc9c13712b7f43b8eeb806efc6 | Wed, 16 Aug 2023 14:08:16 GMT |
| countries_stage/countries_T/taiwan-population.csv.gz                           |  960 | 04376ad20471fabab2b672e2a4e77e2d | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/tajikistan-population.csv.gz                       |  928 | 6936f1cfda6ecb1641a8114c3190763e | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/tanzania-population.csv.gz                         |  960 | 81a72112f6a90c10d4b6791824dc0126 | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/thailand-population.csv.gz                         |  944 | 2ab809bf28879c4e6fae93f78830fcf8 | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/timor-leste-population.csv.gz                      |  880 | 623fb826899800f2ef9bf09dd0ae1485 | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/togo-population.csv.gz                             |  928 | d5203ef866c4ae99e564f7147fd2b348 | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/tokelau-population.csv.gz                          |  528 | e05b859ea8e69695213e5826d52790a1 | Wed, 16 Aug 2023 14:08:24 GMT |
| countries_stage/countries_T/tonga-population.csv.gz                            |  848 | b4c3ce9bf8fb2dd48239d64ef5860e0d | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/trinidad-and-tobago-population.csv.gz              |  928 | 22873873a6b8b50689e9b9df899b381f | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/tunisia-population.csv.gz                          |  928 | 2567c3f095fe3cec02a624f3a4ca1e5d | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/turkey-population.csv.gz                           |  960 | ecefdd25962b38e8b5ee00041615d237 | Wed, 16 Aug 2023 14:08:24 GMT |
| countries_stage/countries_T/turkmenistan-population.csv.gz                     |  928 | 9fe6466f802039da5292c33258c277a6 | Wed, 16 Aug 2023 14:08:25 GMT |
| countries_stage/countries_T/turks-and-caicos-islands-population.csv.gz         |  688 | 5f80a978612e1ac7754dee8562848d6c | Wed, 16 Aug 2023 14:08:24 GMT |
| countries_stage/countries_T/tuvalu-population.csv.gz                           |  640 | 5ba9e86a0147d62d4d0e0a5bb48fdd5b | Wed, 16 Aug 2023 14:08:24 GMT |
| countries_stage/countries_U/uganda-population.csv.gz                           |  944 | ceabb32d6e21cf62c1bb23dcf8c7a97c | Wed, 16 Aug 2023 14:08:32 GMT |
| countries_stage/countries_U/ukraine-population.csv.gz                          |  960 | 1fea5e8bf659ebc8d282ea8657efc068 | Wed, 16 Aug 2023 14:08:33 GMT |
| countries_stage/countries_U/united-arab-emirates-population.csv.gz             |  960 | 16a01292ca453b53120a66422fc44553 | Wed, 16 Aug 2023 14:08:32 GMT |
| countries_stage/countries_U/united-kingdom-population.csv.gz                   |  976 | 3e91d4a220d571f2114d646995c38ed6 | Wed, 16 Aug 2023 14:08:33 GMT |
| countries_stage/countries_U/united-states-population.csv.gz                    |  992 | 021f570f6bf77cb5f44e70e8ad7eb1cb | Wed, 16 Aug 2023 14:08:33 GMT |
| countries_stage/countries_U/united-states-virgin-islands-population.csv.gz     |  928 | c24612b6cd923b06995b2469b4c0dc40 | Wed, 16 Aug 2023 14:08:33 GMT |
| countries_stage/countries_U/uruguay-population.csv.gz                          |  880 | 612cbbd70ac6f01b059772039c68a4a3 | Wed, 16 Aug 2023 14:08:32 GMT |
| countries_stage/countries_U/uzbekistan-population.csv.gz                       |  960 | 5bf2eb6c4df6b6b7cc0e43cf4e3daa3e | Wed, 16 Aug 2023 14:08:32 GMT |
| countries_stage/countries_V/vanuatu-population.csv.gz                          |  848 | f3b9fbe649a9b4ff8c4fc06d81e14beb | Wed, 16 Aug 2023 14:08:40 GMT |
| countries_stage/countries_V/venezuela-population.csv.gz                        |  976 | 28ed0a820e83621ae1a394b7f97d0623 | Wed, 16 Aug 2023 14:08:40 GMT |
| countries_stage/countries_V/vietnam-population.csv.gz                          |  944 | 8353bacc2a45abaee3e7adb7b476fb77 | Wed, 16 Aug 2023 14:08:40 GMT |
| countries_stage/countries_W/wallis-and-futuna-islands-population.csv.gz        |  608 | 4c3032d5af9b9988122bbca3e1c740d7 | Wed, 16 Aug 2023 14:08:48 GMT |
| countries_stage/countries_W/western-sahara-population.csv.gz                   |  880 | 7d6796271f3c8f7ecce1aba4a6cf43da | Wed, 16 Aug 2023 14:08:48 GMT |
| countries_stage/countries_Y/yemen-population.csv.gz                            |  944 | 893039fa86aae819c883bb5b9f271a08 | Wed, 16 Aug 2023 14:08:56 GMT |
| countries_stage/countries_Z/zambia-population.csv.gz                           |  928 | a12df713f5ec4e5c16c3d4c283c42222 | Wed, 16 Aug 2023 14:09:04 GMT |
| countries_stage/countries_Z/zimbabwe-population.csv.gz                         |  944 | 4d8d1996429a01398dfb598404680aea | Wed, 16 Aug 2023 14:09:04 GMT |
+--------------------------------------------------------------------------------+------+----------------------------------+-------------------------------+



SOLUCAO DO PROFESSOR:




create or replace stage population;

PUT file:///workspace/snowflake/Module-2/Snowflake-stages/Data/Practice_data/countries/a* @population/countries_a/;

list @population;


