/***************************** Parsing Xml *********************/


create or replace table xml_demo (v variant);

insert into xml_demo
select
parse_xml('<bpd:AuctionData xmlns:bpd="http://www.treasurydirect.gov/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.treasurydirect.gov/ http://www.treasurydirect.gov/xsd/Auction_v1_0_0.xsd">
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
</bpd:AuctionData>')


SELECT v FROM xml_demo;


SELECT v:"@" FROM xml_demo;



-- query root elements.

SELECT v:"$" FROM xml_demo;

-- another way
SELECT XMLGET(v, 'AuctionAnnouncement', 0) FROM xml_demo;


-- like json
SELECT XMLGET(v, 'AuctionAnnouncement', 0):"$" FROM xml_demo;



SELECT
auction_announcement.index as auction_contents_index,
auction_announcement.value as auction_contents_value
FROM xml_demo,
LATERAL FLATTEN(to_array(xml_demo.v:"$" )) xml_doc,
LATERAL FLATTEN(to_array(xml_doc.VALUE:"$" )) auction_announcement;


-- Recomended method

SELECT 
XMLGET(value, 'SecurityType' ):"$" as "Security Type",
XMLGET( value, 'MaturityDate' ):"$" as "Maturity Date",
XMLGET( value, 'OfferingAmount' ):"$" as "Offering Amount",
XMLGET( value, 'MatureSecurityAmount' ):"$" as "Mature Security Amount"
FROM xml_demo,
LATERAL FLATTEN(to_array(xml_demo.v:"$" )) auction_announcement;
