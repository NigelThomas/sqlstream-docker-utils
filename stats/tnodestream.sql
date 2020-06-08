select stream measured_at,node_id,graph_id,sched_state,trim(last_exec_result) as last_exec_result
     ,input_rowtime_clock,net_input_bytes, net_input_rows
     , net_input_rows - first_value(net_input_rows) OVER "2rows" as increment_input_rows
     ,output_rowtime_clock,net_output_bytes, net_output_rows
     , net_output_rows - first_value(net_output_rows) OVER "2rows" as increment_output_rows
     ,execution_count,net_execution_time,name_in_query_plan as stream_name
from stream(sys_boot.mgmt.getStreamOperatorInfoForever(0,600)) s
window "2rows" as (partition by name_in_query_plan rows 1 preceding)
where name_in_query_plan like '[LOCAL%'
;
