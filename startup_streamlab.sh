#!/bin/bash
#
# startup_streamlab.sh
#
# loads all slab files into StreamLab, and starts underlying pumps
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

. serviceFunctions.sh
. streamlabFunctions.sh

echo Loading StreamLab projects from `pwd`

# This test project depends on a local Postgres server
service postgresql start

# start s-Server to load the schema
startsServer

# what is in the cwd
ls -l

# load all slab files
importSlabFiles

prestartupcript=$(which pre-startup.sh)
if [ -n "$prestartupscript" ]
then
    echo ...  call project specific startup pre-startup.sh : $prestartupscript
    $prestartupscript
fi

# in case there are manually created dashboards

echo ... point s-Dashboard to use the project dashboards directory
echo "SDASHBOARD_DIR=/home/sqlstream/${PROJECT_NAME}/dashboards" >> /etc/default/s-dashboardd
cat /etc/default/s-dashboardd | grep SDASHBOARD_DIR
# 

echo ... in case of multiple projects, generate a start script
generatePumpScripts

echo ... and start pumps
sqllineClient --run=startPumps.sql

echo start remaining required services
service webagentd start
service s-dashboardd start 

# now the caller ENTRYPOINT should tail the s-Server trace file forever – so this entrypoint never finishes
# and the trace file can be viewed using docker logs


