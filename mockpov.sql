CREATE OR REPLACE SCHEMA "StreamLab_Output_ingestionpov";

SET SCHEMA '"StreamLab_Output_ingestionpov"';

CREATE OR REPLACE STREAM "data_1_ns"
( "SQLSTREAM_PROV_KAFKA_TIMESTAMP" TIMESTAMP
);

CREATE OR REPLACE STREAM "data_out_1"
( "SQLSTREAM_PROV_KAFKA_TIMESTAMP" TIMESTAMP
);



