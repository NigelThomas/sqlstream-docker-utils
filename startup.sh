#!/bin/bash
#
# startup.sh
#
# extracts SQL and dashboards from one or more slab files and installs into s-Server
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

HERE=$(cd `dirname $0`; pwd -P)
. serviceFunctions.sh

echo Loading StreamLab projects from `pwd`

# This test project depends on a local Postgres server
service postgresql start

# start s-Server to load the schema
startsServer

# what is in the cwd
ls -l

# unpack project and create the project schemas
for slab in *.slab
do
    echo ... ... unpacking $slab
    setup.sh $(basename $slab .slab)
done

echo ...  execute project specific startup
$SQLSTREAM_HOME/demo/data/buses/start.sh

echo ... point s-Dashboard to use the project dashboards directory
cat /etc/default/s-dashboardd | sed -e "s:SDASHBOARD_DIR.*:SDASHBOARD_DIR=$HERE/dashboards:" > /tmp/s-dashboardd
mv /tmp/s-dashboardd /etc/default/s-dashboardd
cat /tmp/s-dashboardd | grep SDASHBOARD_DIR
# 

echo ... in case of multiple projects, generate a start script
generatePumpScripts

echo ... and start pumps
sqllineClient --run=startPumps.sql

# start remaining required services
service webagentd start
service s-dashboardd start 

# now the caller ENTRYPOINT should tail the s-Server trace file forever – so this entrypoint never finishes
# and the trace file can be viewed using docker logs


