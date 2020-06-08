-- get server info every 1 minute
select stream measured_at,num_stream_graphs_open,num_stream_graphs_closed,num_stream_operators,net_memory_bytes,max_memory_bytes
from stream(sys_boot.mgmt.getServerInfoForever(600));
