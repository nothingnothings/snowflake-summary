nessa aula,


VEREMOS COMO É FEITO O LOAD DE XML DATA 

NO SNOWFLAKE...








O PROFESSOR ESCREVE ASSIM:












------------------ PARSING XML ------------










CREATE OR REPLACE TABLE XML_DEMO (v variant);









-- INSERT XML DATA INTO VARIANT COLUMN:





INSERT INTO xml_demo
SELECT
PARSE_XML('<bpd:AuctionData xmlns:bpd="http://www.treasurydirect.gov/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.treasurydirect.gov/ http://www.treasurydirect.gov/xsd/Auction_v1_0_0.xsd">
<AuctionAnnouncement>
<SecurityTermWeekYear>26-WEEK</SecurityTermWeekYear>
<SecurityTermDayMonth>182-DAY</SecurityTermDayMonth>
<SecurityType>BILL</SecurityType>
<CUSIP>912795G96</CUSIP>
<AnnouncementDate>2008-04-03</AnnouncementDate>
<AuctionDate>2008-04-07</AuctionDate>
<IssueDate>2008-04-10</IssueDate>
<MaturityDate>2008-10-09</MaturityDate>
<OfferingAmount>21.0</OfferingAmount>
<CompetitiveTenderAccepted>Y</CompetitiveTenderAccepted>
<NonCompetitiveTenderAccepted>Y</NonCompetitiveTenderAccepted>
<TreasuryDirectTenderAccepted>Y</TreasuryDirectTenderAccepted>
<AllTenderAccepted>Y</AllTenderAccepted>
<TypeOfAuction>SINGLE PRICE</TypeOfAuction>
<CompetitiveClosingTime>13:00</CompetitiveClosingTime>
<NonCompetitiveClosingTime>12:00</NonCompetitiveClosingTime>
<NetLongPositionReport>7350000000.0</NetLongPositionReport>
<MaxAward>7350000000</MaxAward>
<MaxSingleBid>7350000000</MaxSingleBid>
<CompetitiveBidDecimals>3</CompetitiveBidDecimals>
<CompetitiveBidIncrement>0.005</CompetitiveBidIncrement>
<AllocationPercentageDecimals>2</AllocationPercentageDecimals>
<MinBidAmount>100</MinBidAmount>
<MultiplesToBid>100</MultiplesToBid>
<MinToIssue>100</MinToIssue>
<MultiplesToIssue>100</MultiplesToIssue>
<MatureSecurityAmount>65002000000.0</MatureSecurityAmount>
<CurrentlyOutstanding/>
<SOMAIncluded>N</SOMAIncluded>
<SOMAHoldings>11511000000.0</SOMAHoldings>
<FIMAIncluded>Y</FIMAIncluded>
<Series/>
<InterestRate/>
<FirstInterestPaymentDate/>
<StandardInterestPayment/>
<FrequencyInterestPayment>NONE</FrequencyInterestPayment>
<StrippableIndicator/>
<MinStripAmount/>
<CorpusCUSIP/>
<TINTCUSIP1/>
<TINTCUSIP2/>
<ReOpeningIndicator>N</ReOpeningIndicator>
<OriginalIssueDate/>
<BackDated/>
<BackDatedDate/>
<LongShortNormalCoupon/>
<LongShortCouponFirstIntPmt/>
<Callable/>
<CallDate/>
<InflationIndexSecurity>N</InflationIndexSecurity>
<RefCPIDatedDate/>
<IndexRatioOnIssueDate/>
<CPIBasePeriod/>
<TIINConversionFactor/>
<AccruedInterest/>
<DatedDate/>
<AnnouncedCUSIP/>
<UnadjustedPrice/>
<UnadjustedAccruedInterest/>
<ScheduledPurchasesInTD>772000000.0</ScheduledPurchasesInTD>
<AnnouncementPDFName>A_20080403_1.pdf</AnnouncementPDFName>
<OriginalDatedDate/>
<AdjustedAmountCurrentlyOutstanding/>
<NLPExclusionAmount>0.0</NLPExclusionAmount>
<MaximumNonCompAward>5000000.0</MaximumNonCompAward>
<AdjustedAccruedInterest/>
</AuctionAnnouncement>
</bpd:AuctionData>');











certo... acho que entendo mais ou menos como 
funciona esse formato...








ok... inserimos a data...







-> COM A DATA INSERIDA NESSA TABLE,



o próximo passo é 

PARSEÁ-LA...














--> PARA CONSEGUIRMOS INSERIR XML DATA,

PRECISAMOS DA FUNCTION DE 


"parse_xml()"















--> OK, MAS QUAL É A ESTRUTURA DE XML DATA?











1) TEMOS 1 "ROOT NODE",


CHAMADO DE "AuctionAnnouncement"






2) TODOS OS NODES NESTEADOS 

NESSE NODE 


NOS FORNECEM MAIS INFO SOBRE ESSE ANNOUNCEMENT...





ex: SecurityTermWeekYear

SecurityTermDayMonth











--> E ESSE TIPO DE INFO É PROVIDENCIADA


PELOS NODES....










--> esse xml é relativamente simples..








temos todos esses nodes...









--> INSERIMOS ESSA XML DATA NA TABLE...









--> DEPOIS DISSO, PODEMOS RODAR 1 SELECT NA TABLE....







ex:






SELECT * FROM xml_demo;







ficamos com isto, de value:


<bpd:AuctionData xmlns:bpd="http://www.treasurydirect.gov/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.treasurydirect.gov/ http://www.treasurydirect.gov/xsd/Auction_v1_0_0.xsd">   <AuctionAnnouncement>     <SecurityTermWeekYear>26-WEEK</SecurityTermWeekYear>     <SecurityTermDayMonth>182-DAY</SecurityTermDayMonth>     <SecurityType>BILL</SecurityType>     <CUSIP>912795G96</CUSIP>     <AnnouncementDate>2008-04-03</AnnouncementDate>     <AuctionDate>2008-04-07</AuctionDate>     <IssueDate>2008-04-10</IssueDate>     <MaturityDate>2008-10-09</MaturityDate>     <OfferingAmount>21.0</OfferingAmount>     <CompetitiveTenderAccepted>Y</CompetitiveTenderAccepted>     <NonCompetitiveTenderAccepted>Y</NonCompetitiveTenderAccepted>     <TreasuryDirectTenderAccepted>Y</TreasuryDirectTenderAccepted>     <AllTenderAccepted>Y</AllTenderAccepted>     <TypeOfAuction>SINGLE PRICE</TypeOfAuction>     <CompetitiveClosingTime>13:00</CompetitiveClosingTime>     <NonCompetitiveClosingTime>12:00</NonCompetitiveClosingTime>     <NetLongPositionReport>7350000000.0</NetLongPositionReport>     <MaxAward>7350000000</MaxAward>     <MaxSingleBid>7350000000</MaxSingleBid>     <CompetitiveBidDecimals>3</CompetitiveBidDecimals>     <CompetitiveBidIncrement>0.005</CompetitiveBidIncrement>     <AllocationPercentageDecimals>2</AllocationPercentageDecimals>     <MinBidAmount>100</MinBidAmount>     <MultiplesToBid>100</MultiplesToBid>     <MinToIssue>100</MinToIssue>     <MultiplesToIssue>100</MultiplesToIssue>     <MatureSecurityAmount>65002000000.0</MatureSecurityAmount>     <CurrentlyOutstanding></CurrentlyOutstanding>     <SOMAIncluded>N</SOMAIncluded>     <SOMAHoldings>11511000000.0</SOMAHoldings>     <FIMAIncluded>Y</FIMAIncluded>     <Series></Series>     <InterestRate></InterestRate>     <FirstInterestPaymentDate></FirstInterestPaymentDate>     <StandardInterestPayment></StandardInterestPayment>     <FrequencyInterestPayment>NONE</FrequencyInterestPayment>     <StrippableIndicator></StrippableIndicator>     <MinStripAmount></MinStripAmount>     <CorpusCUSIP></CorpusCUSIP>     <TINTCUSIP1></TINTCUSIP1>     <TINTCUSIP2></TINTCUSIP2>     <ReOpeningIndicator>N</ReOpeningIndicator>     <OriginalIssueDate></OriginalIssueDate>     <BackDated></BackDated>     <BackDatedDate></BackDatedDate>     <LongShortNormalCoupon></LongShortNormalCoupon>     <LongShortCouponFirstIntPmt></LongShortCouponFirstIntPmt>     <Callable></Callable>     <CallDate></CallDate>     <InflationIndexSecurity>N</InflationIndexSecurity>     <RefCPIDatedDate></RefCPIDatedDate>     <IndexRatioOnIssueDate></IndexRatioOnIssueDate>     <CPIBasePeriod></CPIBasePeriod>     <TIINConversionFactor></TIINConversionFactor>     <AccruedInterest></AccruedInterest>     <DatedDate></DatedDate>     <AnnouncedCUSIP></AnnouncedCUSIP>     <UnadjustedPrice></UnadjustedPrice>     <UnadjustedAccruedInterest></UnadjustedAccruedInterest>     <ScheduledPurchasesInTD>772000000.0</ScheduledPurchasesInTD>     <AnnouncementPDFName>A_20080403_1.pdf</AnnouncementPDFName>     <OriginalDatedDate></OriginalDatedDate>     <AdjustedAmountCurrentlyOutstanding></AdjustedAmountCurrentlyOutstanding>     <NLPExclusionAmount>0.0</NLPExclusionAmount>     <MaximumNonCompAward>5000000.0</MaximumNonCompAward>     <AdjustedAccruedInterest></AdjustedAccruedInterest>   </AuctionAnnouncement> </bpd:AuctionData>









--> OK... QUEREMOS QUERIAR ESSA DATA 

NO SNOWFLAKE...












--> PARA QUERIAR, RODAMOS ASSIM:









SELECT v:"@" FROM xml_demo;









---> COM ISSO, TENTAMOS QUERIAR 

O ___ROOT__ NODE DESSE XML...










O RESULTADO APARECERÁ ASSIM:





"bpd:AuctionData"






esse é o ROOTNODE,


rootnode do xml...








SE QUISERMOS MAIS DETALHES SOBRE OS ROOT 
ELEMENTS,

PODEMOS 

USAR isto:








SELECT v:"$" FROM xml_demo;




ISSO NOS DÁ TODOS OS ROOT ELEMENTS (os sub-nodes 
embaixo do root):





<AuctionAnnouncement>
   <SecurityTermWeekYear>26-WEEK</SecurityTermWeekYear>
      <SecurityTermDayMonth>182-DAY</SecurityTermDayMonth> 
        <SecurityType>BILL</SecurityType> 
          <CUSIP>912795G96</CUSIP> 
            <AnnouncementDate>2008-04-03</AnnouncementDate>
               <AuctionDate>2008-04-07</AuctionDate>
                  <IssueDate>2008-04-10</IssueDate>  
                   <MaturityDate>2008-10-09</MaturityDate>
                      <OfferingAmount>21.0</OfferingAmount> 
                        <CompetitiveTenderAccepted>Y</CompetitiveTenderAccepted>   
                        <NonCompetitiveTenderAccepted>Y</NonCompetitiveTenderAccepted>
                           <TreasuryDirectTenderAccepted>Y</TreasuryDirectTenderAccepted>
                              <AllTenderAccepted>Y</AllTenderAccepted>
                                 <TypeOfAuction>SINGLE PRICE</TypeOfAuction>
                                    <CompetitiveClosingTime>13:00</CompetitiveClosingTime>
                                       <NonCompetitiveClosingTime>12:00</NonCompetitiveClosingTime>
                                          <NetLongPositionReport>7350000000.0</NetLongPositionReport> 
                                            <MaxAward>7350000000</MaxAward>
                                               <MaxSingleBid>7350000000</MaxSingleBid>   <CompetitiveBidDecimals>3</CompetitiveBidDecimals>   <CompetitiveBidIncrement>0.005</CompetitiveBidIncrement>   <AllocationPercentageDecimals>2</AllocationPercentageDecimals>   <MinBidAmount>100</MinBidAmount>   <MultiplesToBid>100</MultiplesToBid>   <MinToIssue>100</MinToIssue>   <MultiplesToIssue>100</MultiplesToIssue>   <MatureSecurityAmount>65002000000.0</MatureSecurityAmount>   <CurrentlyOutstanding></CurrentlyOutstanding>   <SOMAIncluded>N</SOMAIncluded>   <SOMAHoldings>11511000000.0</SOMAHoldings>   <FIMAIncluded>Y</FIMAIncluded>   <Series></Series>   <InterestRate></InterestRate>   <FirstInterestPaymentDate></FirstInterestPaymentDate>   <StandardInterestPayment></StandardInterestPayment>   <FrequencyInterestPayment>NONE</FrequencyInterestPayment>   <StrippableIndicator></StrippableIndicator>   <MinStripAmount></MinStripAmount>   <CorpusCUSIP></CorpusCUSIP>   <TINTCUSIP1></TINTCUSIP1>   <TINTCUSIP2></TINTCUSIP2>   <ReOpeningIndicator>N</ReOpeningIndicator>   <OriginalIssueDate></OriginalIssueDate>   <BackDated></BackDated>   <BackDatedDate></BackDatedDate>   <LongShortNormalCoupon></LongShortNormalCoupon>   <LongShortCouponFirstIntPmt></LongShortCouponFirstIntPmt>   <Callable></Callable>   <CallDate></CallDate>   <InflationIndexSecurity>N</InflationIndexSecurity>   <RefCPIDatedDate></RefCPIDatedDate>   <IndexRatioOnIssueDate></IndexRatioOnIssueDate>   <CPIBasePeriod></CPIBasePeriod>   <TIINConversionFactor></TIINConversionFactor>   <AccruedInterest></AccruedInterest>   <DatedDate></DatedDate>   <AnnouncedCUSIP></AnnouncedCUSIP>   <UnadjustedPrice></UnadjustedPrice>   <UnadjustedAccruedInterest></UnadjustedAccruedInterest>   <ScheduledPurchasesInTD>772000000.0</ScheduledPurchasesInTD>   <AnnouncementPDFName>A_20080403_1.pdf</AnnouncementPDFName>   <OriginalDatedDate></OriginalDatedDate>   <AdjustedAmountCurrentlyOutstanding></AdjustedAmountCurrentlyOutstanding>   <NLPExclusionAmount>0.0</NLPExclusionAmount>   <MaximumNonCompAward>5000000.0</MaximumNonCompAward>   <AdjustedAccruedInterest></AdjustedAccruedInterest> </AuctionAnnouncement>





se QUISERMOS DRILLAR MAIS FUNDO NESSE XML,



rodamos assim:





-- another way 

SELECT XMLGET(v, 'AuctionAnnouncement', 0) FROM xml_demo;





OUTPUT:










<AuctionAnnouncement> 
  <SecurityTermWeekYear>26-WEEK</SecurityTermWeekYear>  
   <SecurityTermDayMonth>182-DAY</SecurityTermDayMonth>
      <SecurityType>BILL</SecurityType> 
        <CUSIP>912795G96</CUSIP>
           <AnnouncementDate>2008-04-03</AnnouncementDate>   <AuctionDate>2008-04-07</AuctionDate>   <IssueDate>2008-04-10</IssueDate>   <MaturityDate>2008-10-09</MaturityDate>   <OfferingAmount>21.0</OfferingAmount>   <CompetitiveTenderAccepted>Y</CompetitiveTenderAccepted>   <NonCompetitiveTenderAccepted>Y</NonCompetitiveTenderAccepted>   <TreasuryDirectTenderAccepted>Y</TreasuryDirectTenderAccepted>   <AllTenderAccepted>Y</AllTenderAccepted>   <TypeOfAuction>SINGLE PRICE</TypeOfAuction>   <CompetitiveClosingTime>13:00</CompetitiveClosingTime>   <NonCompetitiveClosingTime>12:00</NonCompetitiveClosingTime>   <NetLongPositionReport>7350000000.0</NetLongPositionReport>   <MaxAward>7350000000</MaxAward>   <MaxSingleBid>7350000000</MaxSingleBid>   <CompetitiveBidDecimals>3</CompetitiveBidDecimals>   <CompetitiveBidIncrement>0.005</CompetitiveBidIncrement>   <AllocationPercentageDecimals>2</AllocationPercentageDecimals>   <MinBidAmount>100</MinBidAmount>   <MultiplesToBid>100</MultiplesToBid>   <MinToIssue>100</MinToIssue>   <MultiplesToIssue>100</MultiplesToIssue>   <MatureSecurityAmount>65002000000.0</MatureSecurityAmount>   <CurrentlyOutstanding></CurrentlyOutstanding>   <SOMAIncluded>N</SOMAIncluded>   <SOMAHoldings>11511000000.0</SOMAHoldings>   <FIMAIncluded>Y</FIMAIncluded>   <Series></Series>   <InterestRate></InterestRate>   <FirstInterestPaymentDate></FirstInterestPaymentDate>   <StandardInterestPayment></StandardInterestPayment>   <FrequencyInterestPayment>NONE</FrequencyInterestPayment>   <StrippableIndicator></StrippableIndicator>   <MinStripAmount></MinStripAmount>   <CorpusCUSIP></CorpusCUSIP>   <TINTCUSIP1></TINTCUSIP1>   <TINTCUSIP2></TINTCUSIP2>   <ReOpeningIndicator>N</ReOpeningIndicator>   <OriginalIssueDate></OriginalIssueDate>   <BackDated></BackDated>   <BackDatedDate></BackDatedDate>   <LongShortNormalCoupon></LongShortNormalCoupon>   <LongShortCouponFirstIntPmt></LongShortCouponFirstIntPmt>   <Callable></Callable>   <CallDate></CallDate>   <InflationIndexSecurity>N</InflationIndexSecurity>   <RefCPIDatedDate></RefCPIDatedDate>   <IndexRatioOnIssueDate></IndexRatioOnIssueDate>   <CPIBasePeriod></CPIBasePeriod>   <TIINConversionFactor></TIINConversionFactor>   <AccruedInterest></AccruedInterest>   <DatedDate></DatedDate>   <AnnouncedCUSIP></AnnouncedCUSIP>   <UnadjustedPrice></UnadjustedPrice>   <UnadjustedAccruedInterest></UnadjustedAccruedInterest>   <ScheduledPurchasesInTD>772000000.0</ScheduledPurchasesInTD>   <AnnouncementPDFName>A_20080403_1.pdf</AnnouncementPDFName>   <OriginalDatedDate></OriginalDatedDate>   <AdjustedAmountCurrentlyOutstanding></AdjustedAmountCurrentlyOutstanding>   <NLPExclusionAmount>0.0</NLPExclusionAmount>   <MaximumNonCompAward>5000000.0</MaximumNonCompAward>   <AdjustedAccruedInterest></AdjustedAccruedInterest> </AuctionAnnouncement>






^^ essa maneira nos dá tudo que fica debaixo do root 
node...







ok... é o mesmo output...















-> SE VOCE QUER VER ESSE XML 


NO FORMATO JSON,



BASTA ADICIONAR UM ":$":





SELECT XMLGET(v, 'AuctionAnnouncement', 0):"$" FROM xml_demo;




O FORMATO FICA ASSIM:



-- [   {     "$": "26-WEEK",     "@": "SecurityTermWeekYear"   },
--    {     "$": "182-DAY",     "@": "SecurityTermDayMonth"   },  
--     {     "$": "BILL",     "@": "SecurityType"   },
--        {     "$": "912795G96",     "@": "CUSIP"   },   {     "$": "2008-04-03",     "@": "AnnouncementDate"   },   {     "$": "2008-04-07",     "@": "AuctionDate"   },   {     "$": "2008-04-10",     "@": "IssueDate"   },   {     "$": "2008-10-09",     "@": "MaturityDate"   },   {     "$": 21,     "@": "OfferingAmount"   },   {     "$": "Y",     "@": "CompetitiveTenderAccepted"   },   {     "$": "Y",     "@": "NonCompetitiveTenderAccepted"   },   {     "$": "Y",     "@": "TreasuryDirectTenderAccepted"   },   {     "$": "Y",     "@": "AllTenderAccepted"   },   {     "$": "SINGLE PRICE",     "@": "TypeOfAuction"   },   {     "$": "13:00",     "@": "CompetitiveClosingTime"   },   {     "$": "12:00",     "@": "NonCompetitiveClosingTime"   },   {     "$": 7350000000,     "@": "NetLongPositionReport"   },   {     "$": 7350000000,     "@": "MaxAward"   },   {     "$": 7350000000,     "@": "MaxSingleBid"   },   {     "$": 3,     "@": "CompetitiveBidDecimals"   },   {     "$": 0.005,     "@": "CompetitiveBidIncrement"   },   {     "$": 2,     "@": "AllocationPercentageDecimals"   },   {     "$": 100,     "@": "MinBidAmount"   },   {     "$": 100,     "@": "MultiplesToBid"   },   {     "$": 100,     "@": "MinToIssue"   },   {     "$": 100,     "@": "MultiplesToIssue"   },   {     "$": 65002000000,     "@": "MatureSecurityAmount"   },   {     "$": "",     "@": "CurrentlyOutstanding"   },   {     "$": "N",     "@": "SOMAIncluded"   },   {     "$": 11511000000,     "@": "SOMAHoldings"   },   {     "$": "Y",     "@": "FIMAIncluded"   },   {     "$": "",     "@": "Series"   },   {     "$": "",     "@": "InterestRate"   },   {     "$": "",     "@": "FirstInterestPaymentDate"   },   {     "$": "",     "@": "StandardInterestPayment"   },   {     "$": "NONE",     "@": "FrequencyInterestPayment"   },   {     "$": "",     "@": "StrippableIndicator"   },   {     "$": "",     "@": "MinStripAmount"   },   {     "$": "",     "@": "CorpusCUSIP"   },   {     "$": "",     "@": "TINTCUSIP1"   },   {     "$": "",     "@": "TINTCUSIP2"   },   {     "$": "N",     "@": "ReOpeningIndicator"   },   {     "$": "",     "@": "OriginalIssueDate"   },   {     "$": "",     "@": "BackDated"   },   {     "$": "",     "@": "BackDatedDate"   },   {     "$": "",     "@": "LongShortNormalCoupon"   },   {     "$": "",     "@": "LongShortCouponFirstIntPmt"   },   {     "$": "",     "@": "Callable"   },   {     "$": "",     "@": "CallDate"   },   {     "$": "N",     "@": "InflationIndexSecurity"   },   {     "$": "",     "@": "RefCPIDatedDate"   },   {     "$": "",     "@": "IndexRatioOnIssueDate"   },   {     "$": "",     "@": "CPIBasePeriod"   },   {     "$": "",     "@": "TIINConversionFactor"   },   {     "$": "",     "@": "AccruedInterest"   },   {     "$": "",     "@": "DatedDate"   },   {     "$": "",     "@": "AnnouncedCUSIP"   },   {     "$": "",     "@": "UnadjustedPrice"   },   {     "$": "",     "@": "UnadjustedAccruedInterest"   },   {     "$": 772000000,     "@": "ScheduledPurchasesInTD"   },   {     "$": "A_20080403_1.pdf",     "@": "AnnouncementPDFName"   },   {     "$": "",     "@": "OriginalDatedDate"   },   {     "$": "",     "@": "AdjustedAmountCurrentlyOutstanding"   },   {     "$": 0,     "@": "NLPExclusionAmount"   },   {     "$": 5000000,     "@": "MaximumNonCompAward"   },   {     "$": "",     "@": "AdjustedAccruedInterest"   } ]















  {     "$": "912795G96",     "@": "CUSIP"   }










  --> quer dizer que "@" É O ROOT ELEMENT,

  E O "$" É O __ VALUE _ DESSE ROOT ELEMENT...



  EX:



  {     "$": "BILL",     "@": "SecurityType"   },




  (a key é "securityType", e o valor é "BILL")




  ---------------------------------------






OK... DEPOIS DISSO,


TEMOS ESTE CÓDIGO:








SELECT 
auction_announcement.index AS auction_contents_index,
auction_announcement.value AS auction_contents_value
FROM xml_demo,
LATERAL FLATTEN(to_array(xml_demo.v:"$")) AS  XML_DOC,
LATERAL FLATTEN(to_array(xml_doc.value:"$")) AS auction_announcement;












O "LATERAL FLATTEN()"


É MUITO USADO 



COM A FUNCTION DE "to_array()",


principalmente quando 


vc 



está processando sua unstructured data 

armazenada no snowflake (
    tanto json como xml...
)







AQUI, NO CASO,
QUEREMOS FLATTENAR O ROOT ELEMENT 

DO XML,





E AO MESMO TEMPO CONVERTER EM JSON (por isso escrevemos ":$")






os 2 "LATERAL FLATTEN" vao KINDOF 

criar 1 virtual table (cada um deles)...







o segundo lateral flatten 

utiliza a primeira virtual table como input,


e aí acessa seu value... --> retrieva o value DE CADA 
ELEMENTO....









O OUTPUT FICA ASSIM:





AUCTION_CONTENTS_INDEX	AUCTION_CONTENTS_VALUE
0	                    <SecurityTermWeekYear>26-WEEK</SecurityTermWeekYear>
1	                    <SecurityTermDayMonth>182-DAY</SecurityTermDayMonth>
2	                    <SecurityType>BILL</SecurityType>
3	                    <CUSIP>912795G96</CUSIP>
4	                    <AnnouncementDate>2008-04-03</AnnouncementDate>
5	                    <AuctionDate>2008-04-07</AuctionDate>
6	                    <IssueDate>2008-04-10</IssueDate>
7	                    <MaturityDate>2008-10-09</MaturityDate>
8	                    <OfferingAmount>21.0</OfferingAmount>
9	                    <CompetitiveTenderAccepted>Y</CompetitiveTenderAccepted>
10	                    <NonCompetitiveTenderAccepted>Y</NonCompetitiveTenderAccepted>
11	                    <TreasuryDirectTenderAccepted>Y</TreasuryDirectTenderAccepted>
12	                    <AllTenderAccepted>Y</AllTenderAccepted>
13	                    <TypeOfAuction>SINGLE PRICE</TypeOfAuction>
14	                    <CompetitiveClosingTime>13:00</CompetitiveClosingTime>
15	                    <NonCompetitiveClosingTime>12:00</NonCompetitiveClosingTime>
16	                    <NetLongPositionReport>7350000000.0</NetLongPositionReport>
17	                    <MaxAward>7350000000</MaxAward>
18	                    <MaxSingleBid>7350000000</MaxSingleBid>
19	                    <CompetitiveBidDecimals>3</CompetitiveBidDecimals>
20	                    <CompetitiveBidIncrement>0.005</CompetitiveBidIncrement>
21	                    <AllocationPercentageDecimals>2</AllocationPercentageDecimals>
22	                    <MinBidAmount>100</MinBidAmount>
23	                    <MultiplesToBid>100</MultiplesToBid>
24	                    <MinToIssue>100</MinToIssue>
25	                    <MultiplesToIssue>100</MultiplesToIssue>
26	                    <MatureSecurityAmount>65002000000.0</MatureSecurityAmount>
27	                    <CurrentlyOutstanding></CurrentlyOutstanding>
28	                    <SOMAIncluded>N</SOMAIncluded>
29	                    <SOMAHoldings>11511000000.0</SOMAHoldings>
30	                    <FIMAIncluded>Y</FIMAIncluded>
31	                    <Series></Series>
32	                    <InterestRate></InterestRate>
33	                    <FirstInterestPaymentDate></FirstInterestPaymentDate>
34	                    <StandardInterestPayment></StandardInterestPayment>
35	                    <FrequencyInterestPayment>NONE</FrequencyInterestPayment>
36	                    <StrippableIndicator></StrippableIndicator>
37	                    <MinStripAmount></MinStripAmount>
38	                    <CorpusCUSIP></CorpusCUSIP>
39	                    <TINTCUSIP1></TINTCUSIP1>
40	                    <TINTCUSIP2></TINTCUSIP2>
41	                    <ReOpeningIndicator>N</ReOpeningIndicator>
42	                    <OriginalIssueDate></OriginalIssueDate>
43	                    <BackDated></BackDated>
44	                    <BackDatedDate></BackDatedDate>
45	                    <LongShortNormalCoupon></LongShortNormalCoupon>
46	                    <LongShortCouponFirstIntPmt></LongShortCouponFirstIntPmt>
47	                    <Callable></Callable>
48	                    <CallDate></CallDate>
49	                    <InflationIndexSecurity>N</InflationIndexSecurity>
50	                    <RefCPIDatedDate></RefCPIDatedDate>
51	                    <IndexRatioOnIssueDate></IndexRatioOnIssueDate>
52	                    <CPIBasePeriod></CPIBasePeriod>
53	                    <TIINConversionFactor></TIINConversionFactor>
54	                    <AccruedInterest></AccruedInterest>
55	                    <DatedDate></DatedDate>
56	                    <AnnouncedCUSIP></AnnouncedCUSIP>
57	                    <UnadjustedPrice></UnadjustedPrice>
58	                    <UnadjustedAccruedInterest></UnadjustedAccruedInterest>
59	                    <ScheduledPurchasesInTD>772000000.0</ScheduledPurchasesInTD>
60	                    <AnnouncementPDFName>A_20080403_1.pdf</AnnouncementPDFName>
61	                    <OriginalDatedDate></OriginalDatedDate>
62	                    <AdjustedAmountCurrentlyOutstanding></AdjustedAmountCurrentlyOutstanding>
63	                    <NLPExclusionAmount>0.0</NLPExclusionAmount>
64	                    <MaximumNonCompAward>5000000.0</MaximumNonCompAward>
65	                    <AdjustedAccruedInterest></AdjustedAccruedInterest>











--> OK, MAS O NODE INTEIRO ESTÁ SENDO RETORNADO COMO 
VALUE...










-->  mas ainda nao está no formato mais readable possível...










---> COMO PODEMOS DEIXAR MAIS READABLE AINDA?










-> A MANEIRA MAIS RECOMENDADA, A BEST PRACTICE,

QUANDO VC ESTÁ TENTANDO PARSEAR 

XML DATA,



É COM 



ESTE APPROACH:








SELECT 
XMLGET(value, 'SecurityType'):"$" AS 'Security Type',
XMLGET(value, 'MaturityDate'):"$" AS "Maturity Date",
XMLGET(value, 'OfferingAmount'):"$" AS 'Offering Amount',
XMLGET(value, 'MatureSecurityAmount'):"$" AS 'Mature Security Amount'
FROM xml_demo,
LATERAL FLATTEN(to_array(xml_demo.v:"$")) auction_announcement;










--> USE "XMLGET", e aí 

passe "value"



e entao o nome do node que vc quer acessar....



já esta parte pega o root element 

do xml:




xml_demo.v:"$"




CADA COLUMN É OUTPUTTADA 




EM 1 FORMATO JSON...










--> O OUTPUT FICA TIPO ASSIM:






SECURITY TYPE:     MATURITY DATE          OFFERING AMOUNT      MATURE SECURITY AMOUNT


"BILL"             "2008-10-09"            21                   650020000000000










ok, aí conseguimos algo readable,

no formato de uma table...









OK, QUER DIZER QUE ESSA É A MANEIRA RECOMENDADA,

USANDO 

"XMLGET()"












--> OK... 








--> a coisa mais importante que 

temos que discutir e entender 



é a TECNICA PARA CARREGAR 


ESSA UNSTRUCTURED DATA...






--> DISCUTIREMOS ESSA TECNICA/APPROACH/STEP-BY-STEP 


NA PRÓXIMA AULA....








--> É IMPORTANTE PQ A PARTE DO "pARSING" 
É BEM FÁCIL DE PEGAR, NO SNOWFLAKE....








-> MAS TEMOS QUE 
APRENDER A TECHNIQUE 



PARA CARREGAR ESSA UNSTRUCTURED DATA NO SNOWFLAKE...







