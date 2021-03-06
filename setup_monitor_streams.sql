-- setup_monitor_streams.sql
--
-- create some native streams that can be used as base for collecting monitoring data
-- these provide a view or stream that is visible to StreamLan, so we can add on analytics, log collection etc.

create or replace schema "SQLstream_Monitor";
set schema '"SQLstream_Monitor"';

-- expose the ALL_TRACE view

create or replace view TRACE_ALL
as
select stream * from SYS_BOOT.MGMT.ALL_TRACE
;

-- expose telemetry - every 15 seconds

create or replace STREAM TELEMETRY_SERVER
("MEASURED_AT" TIMESTAMP
,"IS_RUNNING" BOOLEAN
,"IS_LICENSED" BOOLEAN
,"LICENSE_KIND" VARCHAR(32)
,"LICENSE_VERSION" VARCHAR(32)
,"IS_THROTTLED" BOOLEAN
,"NUM_SESSIONS" INTEGER
,"NUM_STATEMENTS" INTEGER
,"STARTED_AT" TIMESTAMP
,"THROTTLED_AT" TIMESTAMP
,"THROTTLE_LEVEL" DOUBLE
,"NUM_EXEC_THREADS" INTEGER
,"NUM_STREAM_GRAPHS_OPEN" INTEGER
,"NUM_STREAM_GRAPHS_CLOSED" INTEGER
,"NUM_STREAM_OPERATORS" INTEGER
,"NUM_STREAM_GRAPHS_OPEN_EVER" INTEGER
,"NUM_STREAM_GRAPHS_CLOSED_EVER" INTEGER
,"NET_MEMORY_BYTES" BIGINT
,"MAX_MEMORY_BYTES" BIGINT
,"USAGE_AT" TIMESTAMP
,"USAGE_SINCE" TIMESTAMP
,"USAGE_REPORTED_AT" TIMESTAMP
,"NET_INPUT_BYTES" BIGINT
,"NET_OUTPUT_BYTES" BIGINT
,"NET_INPUT_BYTES_TODAY" BIGINT
);

CREATE OR REPLACE PUMP TELEMETRY_SERVER_PUMP STOPPED 
as
INSERT INTO TELEMETRY_SERVER
SELECT STREAM * from STREAM(sys_boot.mgmt.getServerInfoForever(15));

create or replace STREAM TELEMETRY_STREAM_GRAPH
("MEASURED_AT" TIMESTAMP
,"GRAPH_ID" INTEGER
,"STATEMENT_ID" INTEGER
,"SESSION_ID" INTEGER
,"SOURCE_SQL" VARCHAR(2048)
,"SCHED_STATE" CHAR(1)
,"CLOSE_MODE" CHAR(6)
,"IS_GLOBAL_NEXUS" BOOLEAN
,"IS_AUTO_CLOSE" BOOLEAN
,"NUM_NODES" INTEGER
,"NUM_LIVE_NODES" INTEGER
,"NUM_DATA_BUFFERS" INTEGER
,"TOTAL_EXECUTION_TIME" DOUBLE
,"TOTAL_OPENING_TIME" DOUBLE
,"TOTAL_CLOSING_TIME" DOUBLE
,"NET_INPUT_BYTES" BIGINT
,"NET_INPUT_ROWS" BIGINT
,"NET_INPUT_RATE" DOUBLE
,"NET_INPUT_ROW_RATE" DOUBLE
,"NET_OUTPUT_BYTES" BIGINT
,"NET_OUTPUT_ROWS" BIGINT
,"NET_OUTPUT_RATE" DOUBLE
,"NET_OUTPUT_ROW_RATE" DOUBLE
,"NET_MEMORY_BYTES" BIGINT
,"MAX_MEMORY_BYTES" BIGINT
,"WHEN_OPENED" TIMESTAMP
,"WHEN_STARTED" TIMESTAMP
,"WHEN_FINISHED" TIMESTAMP
,"WHEN_CLOSED" TIMESTAMP
);

CREATE OR REPLACE PUMP TELEMETRY_STREAM_GRAPH_PUMP STOPPED
as 
INSERT INTO TELEMETRY_STREAM_GRAPH
SELECT STREAM * from STREAM(sys_boot.mgmt.getStreamGraphInfoForever(0, 15));

create or replace stream TELEMETRY_STREAM_OPERATOR
("MEASURED_AT" TIMESTAMP
,"NODE_ID" VARCHAR(8)
,"GRAPH_ID" INTEGER
,"SOURCE_SQL" VARCHAR(1024)
,"QUERY_PLAN" VARCHAR(1024)
,"NAME_IN_QUERY_PLAN" VARCHAR(64)
,"NUM_INPUTS" INTEGER
,"INPUT_NODES" VARCHAR(64)
,"NUM_OUTPUTS" INTEGER
,"OUTPUT_NODES" VARCHAR(64)
,"SCHED_STATE" CHAR(2)
,"LAST_EXEC_RESULT" CHAR(3)
,"NUM_BUSY_NEIGHBORS" INTEGER
,"INPUT_ROWTIME_CLOCK" TIMESTAMP
,"OUTPUT_ROWTIME_CLOCK" TIMESTAMP
,"EXECUTION_COUNT" BIGINT
,"STARTED_AT" TIMESTAMP
,"LATEST_AT" TIMESTAMP
,"NET_EXECUTION_TIME" DOUBLE
,"NET_SCHEDULE_TIME" DOUBLE
,"NET_INPUT_BYTES" BIGINT
,"NET_INPUT_ROWS" BIGINT
,"NET_INPUT_RATE" DOUBLE
,"NET_INPUT_ROW_RATE" DOUBLE
,"NET_OUTPUT_BYTES" BIGINT
,"NET_OUTPUT_ROWS" BIGINT
,"NET_OUTPUT_RATE" DOUBLE
,"NET_OUTPUT_ROW_RATE" DOUBLE
,"NET_MEMORY_BYTES" BIGINT
,"MAX_MEMORY_BYTES" BIGINT
);

CREATE OR REPLACE PUMP TELEMETRY_STREAM_OPERATOR_PUMP STOPPED
as 
INSERT INTO TELEMETRY_STREAM_OPERATOR
SELECT STREAM * from STREAM(sys_boot.mgmt.getStreamOperatorInfoForever(0, 15));


