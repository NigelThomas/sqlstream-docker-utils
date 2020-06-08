select stream measured_at,node_id,graph_id,sched_state,trim(last_exec_result) as last_exec_result
     ,input_rowtime_clock,net_input_bytes, net_input_rows
     ,output_rowtime_clock,net_output_bytes, net_output_rows
     ,execution_count,net_execution_time
from stream(sys_boot.mgmt.getStreamOperatorInfoForever(0,600));
