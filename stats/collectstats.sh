#!/bin/bash
#
# Collect stats from s-Server
#
# Assumes $SQLSTREAM_HOME/bin is in the path

HERE=$(pwd -P)
starttime=$(date -u +%Y%m%d-%H%M)
LOG=/var/log/sqlstream

nohup sqllineClient --run=$HERE/tserver.sql 2>&1 >$LOG/telem.server.${starttime}.log &
nohup sqllineClient --run=$HERE/tgraph.sql 2>&1 >$LOG/telem.graph.${starttime}.log &
nohup sqllineClient --run=$HERE/tnode.sql 2>&1 >$LOG/telem.node.${starttime}.log &

nohup vmstat -wt -Sm 60 >$LOG/vmstats.${starttime}.log &


