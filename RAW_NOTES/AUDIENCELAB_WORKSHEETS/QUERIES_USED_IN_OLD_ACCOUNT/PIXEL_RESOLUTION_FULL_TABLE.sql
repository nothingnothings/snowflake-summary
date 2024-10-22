// 0) Tables that should be used are:

// A) STATISTICS.PUBLIC.RESOLVED_TROVO_FEED (first check if all historical data has been copied)

// B) AUDIENCELAB_INTERNAL_PROD.PUBLIC.UNIVERSAL_PERSON

// C) STATISTICS.PUBLIC.VISITS (first check if all visits historical data has been copied)








// 0.5) Copy all recent historical data into VISITS and RESOLVED_TROVO_FEED tables:
COPY INTO STATISTICS.PUBLIC.VISITS
FROM (
SELECT
    REPLACE(T.$1, '"', '') AS ACCOUNT_ID,
    T.$2::string  AS TITLE,
    T.$3  AS PATH,
    T.$4 AS URL,
    REPLACE(T.$5::string, '"', '') AS COOKIE_SYNC_ID,
    REPLACE(T.$6::string, '"', '') AS PIXEL_ID,
    T.$7::string AS "AS",
    REPLACE(T.$8::string, '"', '') AS CITY,
    REPLACE(T.$9::string, '"', '') AS COUNTRY,
    REPLACE(T.$10::string, '"', '') AS COUNTRY_CODE,
    T.$11 AS ISP,
    TRY_CAST(REPLACE(T.$12, '"', '') AS DOUBLE) AS LAT, -- DOUBLE
    TRY_CAST(REPLACE(T.$13, '"', '') AS DOUBLE) AS LON, -- DOUBLE
    T.$14 AS ORG,
    REPLACE(T.$15, '"', '') AS QUERY,
    REPLACE(T.$16, '"', '') AS REGION,
    REPLACE(T.$17, '"', '') AS REGION_NAME,
    REPLACE(T.$18, '"', '') AS STATUS,
    REPLACE(T.$19, '"', '') as TIME_ZONE,
    REPLACE(T.$20, '"', '') AS ZIP,
    REPLACE(T.$21, '"', '') AS MONTH,
    REPLACE(T.$22, '"', '') AS __V,
    CONCAT(TO_TIMESTAMP_NTZ(CONCAT(SUBSTR(T.$23, 13, 4), '-', 
    CASE SUBSTR(T.$23, 6, 3)
                WHEN 'Jan' THEN '01'
                WHEN 'Feb' THEN '02'
                WHEN 'Mar' THEN '03'
                WHEN 'Apr' THEN '04'
                WHEN 'May' THEN '05'
                WHEN 'Jun' THEN '06'
                WHEN 'Jul' THEN '07'
                WHEN 'Aug' THEN '08'
                WHEN 'Sep' THEN '09'
                WHEN 'Oct' THEN '10'
                WHEN 'Nov' THEN '11'
                WHEN 'Dec' THEN '12'
            END, '-',
    SUBSTR(T.$23, 10, 2), ' ', SUBSTR(T.$23, 18, 8)) ), ' ', SUBSTR(T.$23, 30, 5)) AS CREATED_AT,
    CONCAT(TO_TIMESTAMP_NTZ(CONCAT(SUBSTR(T.$24, 13, 4), '-', 
    CASE SUBSTR(T.$24, 6, 3)
                WHEN 'Jan' THEN '01'
                WHEN 'Feb' THEN '02'
                WHEN 'Mar' THEN '03'
                WHEN 'Apr' THEN '04'
                WHEN 'May' THEN '05'
                WHEN 'Jun' THEN '06'
                WHEN 'Jul' THEN '07'
                WHEN 'Aug' THEN '08'
                WHEN 'Sep' THEN '09'
                WHEN 'Oct' THEN '10'
                WHEN 'Nov' THEN '11'
                WHEN 'Dec' THEN '12'
            END, '-',
    SUBSTR(T.$24, 10, 2), ' ', SUBSTR(T.$24, 18, 8)) ), ' ', SUBSTR(T.$24, 30, 5)) AS UPDATED_AT,
    REPLACE(T.$25, '"', '') AS YEAR
        FROM @STATISTICS.PUBLIC.VISITS_STAGE/visit/ T
)
ON_ERROR=CONTINUE;








COPY INTO STATISTICS.PUBLIC.RESOLVED_TROVO_FEED
FROM (
SELECT 
REPLACE(T.$1, '"', '') AS _ID,
REPLACE(T.$2, '"', '') AS PARTNERUID,
REPLACE(T.$3, '"', '') AS PIXEL_ID,
REPLACE(T.$4, '"', '') AS SHA256,
REPLACE(T.$5, '"', '') AS _V,
REPLACE(T.$6, '"', '') AS CELL_PHONE_1,
REPLACE(T.$7, '"', '') AS CELL_PHONE_2,
REPLACE(T.$8, '"', '') AS CONSUMER_ID,
REPLACE(T.$9, '"', '') AS COOKIE_SYNC,
CONCAT(TO_TIMESTAMP_NTZ(CONCAT(SUBSTR(T.$10, 13, 4), '-', 
CASE SUBSTR(T.$10, 6, 3)
                WHEN 'Jan' THEN '01'
                WHEN 'Feb' THEN '02'
                WHEN 'Mar' THEN '03'
                WHEN 'Apr' THEN '04'
                WHEN 'May' THEN '05'
                WHEN 'Jun' THEN '06'
                WHEN 'Jul' THEN '07'
                WHEN 'Aug' THEN '08'
                WHEN 'Sep' THEN '09'
                WHEN 'Oct' THEN '10'
                WHEN 'Nov' THEN '11'
                WHEN 'Dec' THEN '12'
            END, '-',
SUBSTR(T.$10, 10, 2), ' ', SUBSTR(T.$10, 18, 8)) ), ' ', SUBSTR(T.$10, 30, 5)) AS CREATED_AT,
CONCAT(TO_TIMESTAMP_NTZ(CONCAT(SUBSTR(T.$11, 13, 4), '-', 
CASE SUBSTR(T.$11, 6, 3)
                WHEN 'Jan' THEN '01'
                WHEN 'Feb' THEN '02'
                WHEN 'Mar' THEN '03'
                WHEN 'Apr' THEN '04'
                WHEN 'May' THEN '05'
                WHEN 'Jun' THEN '06'
                WHEN 'Jul' THEN '07'
                WHEN 'Aug' THEN '08'
                WHEN 'Sep' THEN '09'
                WHEN 'Oct' THEN '10'
                WHEN 'Nov' THEN '11'
                WHEN 'Dec' THEN '12'
            END, '-',
SUBSTR(T.$11, 10, 2), ' ', SUBSTR(T.$11, 18, 8)) ), ' ', SUBSTR(T.$11, 30, 5)) AS UPDATED_AT,
REPLACE(T.$12, '"', '') AS EMAIL_ADDRESS_1,
REPLACE(T.$13, '"', '') AS FIRST_NAME,
REPLACE(T.$14, '"', '') AS INDIVIDUALID,
REPLACE(T.$15, '"', '') AS LAST_NAME
FROM @STATISTICS.PUBLIC.PIXEL_RESOLUTION_STAGE/ T
)
ON_ERROR=CONTINUE;






// 1) Validate tables:

SELECT * FROM STATISTICS.PUBLIC.RESOLVED_TROVO_FEED LIMIT 10;

// 20.515.934
SELECT COUNT(*) FROM STATISTICS.PUBLIC.RESOLVED_TROVO_FEED

SELECT * FROM AUDIENCELAB_INTERNAL_PROD.PUBLIC.UNIVERSAL_PERSON LIMIT 10;

// 350.753.273
SELECT COUNT(*) FROM AUDIENCELAB_INTERNAL_PROD.PUBLIC.UNIVERSAL_PERSON

SELECT * FROM STATISTICS.PUBLIC.VISITS LIMIT 10;

// 60.839.682
SELECT COUNT(*) FROM STATISTICS.PUBLIC.VISITS





// 2) Create the "STATISTICS.PUBLIC.RESOLVED_TROVO_FEED_FULL" table, joining on the three tables:
CREATE OR REPLACE TRANSIENT TABLE STATISTICS.PUBLIC.RESOLVED_TROVO_FEED_FULL
AS 
SELECT 
-- Info from Universal Person:
UP.FIRST_NAME AS "FIRST_NAME",
UP.LAST_NAME AS "LAST_NAME",
UP.BUSINESS_EMAIL AS "BUSINESS_EMAIL",
UP.PROGRAMMATIC_BUSINESS_EMAILS AS "PROGRAMMATIC_BUSINESS_EMAILS", 
UP.MOBILE_PHONE AS "MOBILE_PHONE",
UP.DIRECT_NUMBER AS "DIRECT_NUMBER",
UP.PERSONAL_PHONE AS "PERSONAL_PHONE",
UP.LINKEDIN_URL AS "LINKEDIN_URL",
UP.PERSONAL_ADDRESS AS "PERSONAL_ADDRESS",
UP.PERSONAL_ADDRESS_2 AS "PERSONAL_ADDRESS_2",
UP.PERSONAL_CITY AS "PERSONAL_CITY",
UP.PERSONAL_STATE AS "PERSONAL_STATE",
UP.PERSONAL_ZIP AS "PERSONAL_ZIP",
UP.PERSONAL_ZIP4 AS "PERSONAL_ZIP4",
UP.PERSONAL_EMAIL AS "PERSONAL_EMAIL",
UP.ADDITIONAL_PERSONAL_EMAILS AS "ADDITIONAL_PERSONAL_EMAILS",
UP.GENDER AS "GENDER",
UP.AGE_RANGE AS "AGE_RANGE",
UP.MARRIED AS "MARRIED",
UP.CHILDREN AS "CHILDREN",
UP.INCOME_RANGE AS "INCOME_RANGE",
UP.NET_WORTH AS "NET_WORTH",
UP.HOMEOWNER AS "HOMEOWNER",
UP.JOB_TITLE AS "JOB_TITLE",
UP.SENIORITY_LEVEL AS "SENIORITY_LEVEL",
UP.DEPARTMENT AS "DEPARTMENT",
UP.PROFESSIONAL_ADDRESS AS "PROFESSIONAL_ADDRESS",
UP.PROFESSIONAL_ADDRESS2 AS "PROFESSIONAL_ADDRESS2",
UP.PROFESSIONAL_CITY AS "PROFESSIONAL_CITY",
UP.PROFESSIONAL_STATE AS "PROFESSIONAL_STATE",
UP.PROFESSIONAL_ZIP AS "PROFESSIONAL_ZIP",
UP.PROFESSIONAL_ZIP4 AS "PROFESSIONAL_ZIP4",
UP.COMPANY_NAME AS "COMPANY_NAME",
UP.COMPANY_DOMAIN AS "COMPANY_DOMAIN",
UP.COMPANY_PHONE AS "COMPANY_PHONE",
UP.COMPANY_SIC AS "COMPANY_SIC",
UP.COMPANY_ADDRESS AS "COMPANY_ADDRESS",
UP.COMPANY_CITY AS "COMPANY_CITY",
UP.COMPANY_STATE AS "COMPANY_STATE",
UP.COMPANY_ZIP AS "COMPANY_ZIP",
UP.COMPANY_LINKEDIN_URL AS "COMPANY_LINKEDIN_URL",
UP.COMPANY_REVENUE AS "COMPANY_REVENUE",
UP.COMPANY_EMPLOYEE_COUNT AS "COMPANY_EMPLOYEE_COUNT",
UP.PRIMARY_INDUSTRY AS "PRIMARY_INDUSTRY",
UP.BUSINESS_EMAIL_VALIDATION_STATUS AS "BUSINESS_EMAIL_VALIDATION_STATUS",
UP.BUSINES_EMAIL_LAST_SEEN AS "BUSINES_EMAIL_LAST_SEEN",
UP.PERSONAL_EMAIL_LAST_SEEN_VALIDATION_STATUS AS "PERSONAL_EMAIL_LAST_SEEN_VALIDATION_STATUS",
UP.PERSONAL_EMAIL_LAST_SEEN AS "PERSONAL_EMAIL_LAST_SEEN",
UP.COMPANY_LAST_UPDATED AS "COMPANY_LAST_UPDATED",
UP.JOB_TITLE_LAST_UPDATED AS "JOB_TITLE_LAST_UPDATED",
UP.LAST_UPDATED AS "LAST_UPDATED",
UP.SHA256_PERSONAL_EMAIL AS "SHA256_PERSONAL_EMAIL",
-- Info from RESOLVED_TROVO_FEED:
RTF.SHA256 AS "SHA256",
RTF.PARTNERUID AS "PARTNERUID",
RTF.PIXEL_ID AS "PIXEL_ID",
RTF.CREATED_AT AS "RESOLVED_TROVO_FEED_CREATED_AT",
-- Info from VISITS:
V.PATH AS "PATH",
V.TITLE AS "TITLE",
V.URL AS "URL",
V.CREATED_AT AS "VISIT_CREATED_AT"
FROM STATISTICS.PUBLIC.RESOLVED_TROVO_FEED AS RTF
INNER JOIN AUDIENCELAB_INTERNAL_PROD.PUBLIC.UNIVERSAL_PERSON AS UP
ON RTF.EMAIL_ADDRESS_1 = UP.PERSONAL_EMAIL OR RTF.SHA256 = UP.SHA256_PERSONAL_EMAIL
INNER JOIN STATISTICS.PUBLIC.VISITS AS V
ON V.COOKIE_SYNC_ID = RTF.PARTNERUID;









// Optimized query:
CREATE OR REPLACE TRANSIENT TABLE STATISTICS.PUBLIC.RESOLVED_TROVO_FEED_FULL AS
SELECT
    UP.FIRST_NAME AS "FIRST_NAME",
    UP.LAST_NAME AS "LAST_NAME",
    UP.BUSINESS_EMAIL AS "BUSINESS_EMAIL",
    UP.PROGRAMMATIC_BUSINESS_EMAILS AS "PROGRAMMATIC_BUSINESS_EMAILS",
    UP.MOBILE_PHONE AS "MOBILE_PHONE",
    UP.DIRECT_NUMBER AS "DIRECT_NUMBER",
    UP.PERSONAL_PHONE AS "PERSONAL_PHONE",
    UP.LINKEDIN_URL AS "LINKEDIN_URL",
    UP.PERSONAL_ADDRESS AS "PERSONAL_ADDRESS",
    UP.PERSONAL_ADDRESS_2 AS "PERSONAL_ADDRESS_2",
    UP.PERSONAL_CITY AS "PERSONAL_CITY",
    UP.PERSONAL_STATE AS "PERSONAL_STATE",
    UP.PERSONAL_ZIP AS "PERSONAL_ZIP",
    UP.PERSONAL_ZIP4 AS "PERSONAL_ZIP4",
    UP.PERSONAL_EMAIL AS "PERSONAL_EMAIL",
    UP.ADDITIONAL_PERSONAL_EMAILS AS "ADDITIONAL_PERSONAL_EMAILS",
    UP.GENDER AS "GENDER",
    UP.AGE_RANGE AS "AGE_RANGE",
    UP.MARRIED AS "MARRIED",
    UP.CHILDREN AS "CHILDREN",
    UP.INCOME_RANGE AS "INCOME_RANGE",
    UP.NET_WORTH AS "NET_WORTH",
    UP.HOMEOWNER AS "HOMEOWNER",
    UP.JOB_TITLE AS "JOB_TITLE",
    UP.SENIORITY_LEVEL AS "SENIORITY_LEVEL",
    UP.DEPARTMENT AS "DEPARTMENT",
    UP.PROFESSIONAL_ADDRESS AS "PROFESSIONAL_ADDRESS",
    UP.PROFESSIONAL_ADDRESS2 AS "PROFESSIONAL_ADDRESS2",
    UP.PROFESSIONAL_CITY AS "PROFESSIONAL_CITY",
    UP.PROFESSIONAL_STATE AS "PROFESSIONAL_STATE",
    UP.PROFESSIONAL_ZIP AS "PROFESSIONAL_ZIP",
    UP.PROFESSIONAL_ZIP4 AS "PROFESSIONAL_ZIP4",
    UP.COMPANY_NAME AS "COMPANY_NAME",
    UP.COMPANY_DOMAIN AS "COMPANY_DOMAIN",
    UP.COMPANY_PHONE AS "COMPANY_PHONE",
    UP.COMPANY_SIC AS "COMPANY_SIC",
    UP.COMPANY_ADDRESS AS "COMPANY_ADDRESS",
    UP.COMPANY_CITY AS "COMPANY_CITY",
    UP.COMPANY_STATE AS "COMPANY_STATE",
    UP.COMPANY_ZIP AS "COMPANY_ZIP",
    UP.COMPANY_LINKEDIN_URL AS "COMPANY_LINKEDIN_URL",
    UP.COMPANY_REVENUE AS "COMPANY_REVENUE",
    UP.COMPANY_EMPLOYEE_COUNT AS "COMPANY_EMPLOYEE_COUNT",
    UP.PRIMARY_INDUSTRY AS "PRIMARY_INDUSTRY",
    UP.BUSINESS_EMAIL_VALIDATION_STATUS AS "BUSINESS_EMAIL_VALIDATION_STATUS",
    UP.BUSINES_EMAIL_LAST_SEEN AS "BUSINES_EMAIL_LAST_SEEN",
    UP.PERSONAL_EMAIL_LAST_SEEN_VALIDATION_STATUS AS "PERSONAL_EMAIL_LAST_SEEN_VALIDATION_STATUS",
    UP.PERSONAL_EMAIL_LAST_SEEN AS "PERSONAL_EMAIL_LAST_SEEN",
    UP.COMPANY_LAST_UPDATED AS "COMPANY_LAST_UPDATED",
    UP.JOB_TITLE_LAST_UPDATED AS "JOB_TITLE_LAST_UPDATED",
    UP.LAST_UPDATED AS "LAST_UPDATED",
    UP.SHA256_PERSONAL_EMAIL AS "SHA256_PERSONAL_EMAIL",
    RTF.SHA256 AS "SHA256",
    RTF.PARTNERUID AS "PARTNERUID",
    RTF.PIXEL_ID AS "PIXEL_ID",
    RTF.CREATED_AT AS "RESOLVED_TROVO_FEED_CREATED_AT",
    V.PATH AS "PATH",
    V.TITLE AS "TITLE",
    V.URL AS "URL",
    V.CREATED_AT AS "VISIT_CREATED_AT"
FROM
    STATISTICS.PUBLIC.RESOLVED_TROVO_FEED AS RTF
INNER JOIN
    AUDIENCELAB_INTERNAL_PROD.PUBLIC.UNIVERSAL_PERSON AS UP
ON
    RTF.EMAIL_ADDRESS_1 = UP.PERSONAL_EMAIL
INNER JOIN
    STATISTICS.PUBLIC.VISITS AS V
ON
    V.COOKIE_SYNC_ID = RTF.PARTNERUID

UNION

SELECT
    UP.FIRST_NAME AS "FIRST_NAME",
    UP.LAST_NAME AS "LAST_NAME",
    UP.BUSINESS_EMAIL AS "BUSINESS_EMAIL",
    UP.PROGRAMMATIC_BUSINESS_EMAILS AS "PROGRAMMATIC_BUSINESS_EMAILS",
    UP.MOBILE_PHONE AS "MOBILE_PHONE",
    UP.DIRECT_NUMBER AS "DIRECT_NUMBER",
    UP.PERSONAL_PHONE AS "PERSONAL_PHONE",
    UP.LINKEDIN_URL AS "LINKEDIN_URL",
    UP.PERSONAL_ADDRESS AS "PERSONAL_ADDRESS",
    UP.PERSONAL_ADDRESS_2 AS "PERSONAL_ADDRESS_2",
    UP.PERSONAL_CITY AS "PERSONAL_CITY",
    UP.PERSONAL_STATE AS "PERSONAL_STATE",
    UP.PERSONAL_ZIP AS "PERSONAL_ZIP",
    UP.PERSONAL_ZIP4 AS "PERSONAL_ZIP4",
    UP.PERSONAL_EMAIL AS "PERSONAL_EMAIL",
    UP.ADDITIONAL_PERSONAL_EMAILS AS "ADDITIONAL_PERSONAL_EMAILS",
    UP.GENDER AS "GENDER",
    UP.AGE_RANGE AS "AGE_RANGE",
    UP.MARRIED AS "MARRIED",
    UP.CHILDREN AS "CHILDREN",
    UP.INCOME_RANGE AS "INCOME_RANGE",
    UP.NET_WORTH AS "NET_WORTH",
    UP.HOMEOWNER AS "HOMEOWNER",
    UP.JOB_TITLE AS "JOB_TITLE",
    UP.SENIORITY_LEVEL AS "SENIORITY_LEVEL",
    UP.DEPARTMENT AS "DEPARTMENT",
    UP.PROFESSIONAL_ADDRESS AS "PROFESSIONAL_ADDRESS",
    UP.PROFESSIONAL_ADDRESS2 AS "PROFESSIONAL_ADDRESS2",
    UP.PROFESSIONAL_CITY AS "PROFESSIONAL_CITY",
    UP.PROFESSIONAL_STATE AS "PROFESSIONAL_STATE",
    UP.PROFESSIONAL_ZIP AS "PROFESSIONAL_ZIP",
    UP.PROFESSIONAL_ZIP4 AS "PROFESSIONAL_ZIP4",
    UP.COMPANY_NAME AS "COMPANY_NAME",
    UP.COMPANY_DOMAIN AS "COMPANY_DOMAIN",
    UP.COMPANY_PHONE AS "COMPANY_PHONE",
    UP.COMPANY_SIC AS "COMPANY_SIC",
    UP.COMPANY_ADDRESS AS "COMPANY_ADDRESS",
    UP.COMPANY_CITY AS "COMPANY_CITY",
    UP.COMPANY_STATE AS "COMPANY_STATE",
    UP.COMPANY_ZIP AS "COMPANY_ZIP",
    UP.COMPANY_LINKEDIN_URL AS "COMPANY_LINKEDIN_URL",
    UP.COMPANY_REVENUE AS "COMPANY_REVENUE",
    UP.COMPANY_EMPLOYEE_COUNT AS "COMPANY_EMPLOYEE_COUNT",
    UP.PRIMARY_INDUSTRY AS "PRIMARY_INDUSTRY",
    UP.BUSINESS_EMAIL_VALIDATION_STATUS AS "BUSINESS_EMAIL_VALIDATION_STATUS",
    UP.BUSINES_EMAIL_LAST_SEEN AS "BUSINES_EMAIL_LAST_SEEN",
    UP.PERSONAL_EMAIL_LAST_SEEN_VALIDATION_STATUS AS "PERSONAL_EMAIL_LAST_SEEN_VALIDATION_STATUS",
    UP.PERSONAL_EMAIL_LAST_SEEN AS "PERSONAL_EMAIL_LAST_SEEN",
    UP.COMPANY_LAST_UPDATED AS "COMPANY_LAST_UPDATED",
    UP.JOB_TITLE_LAST_UPDATED AS "JOB_TITLE_LAST_UPDATED",
    UP.LAST_UPDATED AS "LAST_UPDATED",
    UP.SHA256_PERSONAL_EMAIL AS "SHA256_PERSONAL_EMAIL",
    RTF.SHA256 AS "SHA256",
    RTF.PARTNERUID AS "PARTNERUID",
    RTF.PIXEL_ID AS "PIXEL_ID",
    RTF.CREATED_AT AS "RESOLVED_TROVO_FEED_CREATED_AT",
    V.PATH AS "PATH",
    V.TITLE AS "TITLE",
    V.URL AS "URL",
    V.CREATED_AT AS "VISIT_CREATED_AT"
FROM
    STATISTICS.PUBLIC.RESOLVED_TROVO_FEED AS RTF
INNER JOIN
    AUDIENCELAB_INTERNAL_PROD.PUBLIC.UNIVERSAL_PERSON AS UP
ON
    RTF.SHA256 = UP.SHA256_PERSONAL_EMAIL
INNER JOIN
    STATISTICS.PUBLIC.VISITS AS V
ON
    V.COOKIE_SYNC_ID = RTF.PARTNERUID;








SELECT COUNT(*) FROM STATISTICS.PUBLIC.RESOLVED_TROVO_FEED_FULL;


SELECT * FROM STATISTICS.PUBLIC.RESOLVED_TROVO_FEED_FULL LIMIT 10;


11.176.395;





SELECT * FROM TROVO.PUBLIC.BIG_IP_TO_UPID
WHERE IP='69.63.184.6';

