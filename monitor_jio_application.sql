-- Install ingestionpov application_specific monitoring in a separate schema
--

!set force on
ALTER PUMP "monitor_ingestionpov".* STOP;
DROP SCHEMA "monitor_ingestionpov";
!set force off

CREATE OR REPLACE SCHEMA "monitor_ingestionpov";



-- This is in wallclock timeframe
-- make a 15sec base aggregate tumbling window

CREATE OR REPLACE VIEW "monitor_data_in_15s_by_app"
AS
SELECT STREAM "application_name"
, COUNT(*) AS "COUNTER_15S"
, MAX(SQLSTREAM_PROV_KAFKA_TIMESTAMP) as MAX_KAFKA_TIMESTAMP_15S
, MIN(SQLSTREAM_PROV_KAFKA_TIMESTAMP) as MIN_KAFKA_TIMESTAMP_15S
FROM "StreamLab_Output_ingestionpov"."data_1_ns" s                      -- application schema.stream
GROUP BY STEP (s.ROWTIME BY INTERVAL '15' SECOND)
       , "application_name"
;

CREATE OR REPLACE VIEW "monitor_data_in_15s_overall"
AS
SELECT STREAM SUM("COUNTER_15S") AS "COUNTER_15S"
, MAX(SQLSTREAM_PROV_KAFKA_TIMESTAMP) as MAX_KAFKA_TIMESTAMP_15S
, MIN(SQLSTREAM_PROV_KAFKA_TIMESTAMP) as MIN_KAFKA_TIMESTAMP_15S
FROM "monitor_data_in_15s_by_app" s
GROUP BY s.ROWTIME 
;

-- from the low level aggregate, form high level aggregates
-- volumes of data are low by this point

CREATE OR REPLACE VIEW "monitor_data_in_rolling_by_app"
AS
SELECT STREAM "application_name"
    ,  COUNTER_15S
    ,  SUM(COUNTER_15S) OVER "5m" AS "COUNTER_5M"
    ,  SUM(COUNTER_15S) OVER "1h" AS "COUNTER_1H"
    ,  SUM(COUNTER_15S) OVER "1D" AS "COUNTER_1D"
FROM "monitor_data_in_15s_by_app"
WINDOW "5m" AS (PARTITION BY "application_name" RANGE INTERVAL '5' MINUTE PRECEDING)
     , "1H" AS (PARTITION BY "application_name" RANGE INTERVAL '1' HOUR PRECEDING)
     , "1D" AS (PARTITION BY "application_name" RANGE INTERVAL '1' DAY PRECEDING)
;

CREATE OR REPLACE VIEW "monitor_data_in_rolling_overall"
AS
SELECT STREAM COUNTER_15S
    ,  SUM(COUNTER_15S) OVER "5M" AS COUNTER_5M
    ,  SUM(COUNTER_15S) OVER "1H" AS COUNTER_1H
    ,  SUM(COUNTER_15S) OVER "1D" AS COUNTER_1D
FROM "monitor_data_in_15s_overall"
WINDOW "5M" AS (RANGE INTERVAL '5' MINUTE PRECEDING)
     , "1H" AS (RANGE INTERVAL '1' HOUR PRECEDING)
     , "1D" AS (RANGE INTERVAL '1' DAY PRECEDING)
;


----------------------------------------------
-- NOW FOR THE OUTPUT STREAM
-- make a 15sec base aggregate tumbling window
-- the rowtime is in the timeframe of SQLSTREAM_PROV_KAFKA_TIMESTAMP

CREATE OR REPLACE VIEW "monitor_data_out_15s_by_app"
AS
SELECT STREAM "application_name"
, COUNT(*) AS "COUNTER_15S"
FROM "StreamLab_Output_ingestionpov"."data_out_1" s             -- application schema.stream 
GROUP BY STEP (s.ROWTIME BY INTERVAL '15' SECOND)
       , "application_name"
;

CREATE OR REPLACE VIEW "monitor_data_out_15s_overall"
AS
SELECT STREAM SUM("COUNTER_15S") AS "COUNTER_15S"
FROM "monitor_data_out_15s_by_app" s
GROUP BY s.ROWTIME 
;

-- from the low level aggregate, form high level aggregates
-- volumes of data are low by this point

CREATE OR REPLACE VIEW "monitor_data_out_rolling_by_app"
AS
SELECT STREAM "application_name"
    ,  COUNTER_15S
    ,  SUM(COUNTER_15S) OVER "5m" AS "COUNTER_5M"
    ,  SUM(COUNTER_15S) OVER "1h" AS "COUNTER_1H"
    ,  SUM(COUNTER_15S) OVER "1D" AS "COUNTER_1D"
FROM "monitor_data_out_15s_by_app"
WINDOW "5m" AS (PARTITION BY "application_name" RANGE INTERVAL '5' MINUTE PRECEDING)
     , "1H" AS (PARTITION BY "application_name" RANGE INTERVAL '1' HOUR PRECEDING)
     , "1D" AS (PARTITION BY "application_name" RANGE INTERVAL '1' DAY PRECEDING)
;

CREATE OR REPLACE VIEW "monitor_data_out_rolling_overall"
AS
SELECT STREAM COUNTER_15S
    ,  SUM(COUNTER_15S) OVER "5M" AS COUNTER_5M
    ,  SUM(COUNTER_15S) OVER "1H" AS COUNTER_1H
    ,  SUM(COUNTER_15S) OVER "1D" AS COUNTER_1D
FROM "monitor_data_out_15s_overall"
WINDOW "5M" AS (RANGE INTERVAL '5' MINUTE PRECEDING)
     , "1H" AS (RANGE INTERVAL '1' HOUR PRECEDING)
     , "1D" AS (RANGE INTERVAL '1' DAY PRECEDING)
;

CREATE OR REPLACE FOREIGN STREAM "monitor_data_out_rolling_by_app_kafka"
( STREAM_NAME VARCHAR(128)
, EVENT_TIME TIMESTAMP
, "application_name" VARCHAR(32)
, COUNTER_15S BIGINT
, COUNTER_1H  BIGINT
, COUNTER_1D  BIGINT
)
SERVER KAFKA10_SERVER
OPTIONS
( "FORMATTER" 'JSON'
, "FORMATTER_INCLUDE_ROWTIME" 'false'
, "bootstrap.servers" 'localhost:9092'
, "TOPIC" 'monitor'
);

CREATE OR REPLACE PUMP "monitor_data_out_rolling_by_app_pump" STOPPED
AS
INSERT INTO "monitor_data_app_rolling_by_app_kafka"
SELECT STREAM 'data_out_by_app' AS STREAM_NAME
, s.ROWTIME AS EVENT_TIME
, *
FROM  "monitor_data_out_rolling_by_app"
;


CREATE OR REPLACE FOREIGN STREAM "monitor_data_out_rolling_overall_kafka"
( STREAM_NAME VARCHAR(128)
, EVENT_TIME TIMESTAMP
, "application_name" VARCHAR(32)
, COUNTER_15S BIGINT
, COUNTER_1H  BIGINT
, COUNTER_1D  BIGINT
)
SERVER KAFKA10_SERVER
OPTIONS 
( "FORMATTER" 'JSON'
, "FORMATTER_INCLUDE_ROWTIME" 'false'
, "bootstrap.servers" 'localhost:9092'
, "TOPIC" 'monitor'
);

CREATE OR REPLACE PUMP "monitor_data_out_rolling_overall_pump" STOPPED
AS
INSERT INTO "monitor_data_app_rolling_overall_kafka"
SELECT STREAM 'data_out_overall' AS STREAM_NAME
, s.ROWTIME AS EVENT_TIME
, '---ALL---' AS "application_name"
, *
FROM  "monitor_data_out_rolling_overall"
;

