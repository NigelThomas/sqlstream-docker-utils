#!/bin/bash
#
# startup.sh
#
# extracts SQL and dashboards from one or more slab files and installs into s-Server
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

echo startup.sh PATH=$PATH
. serviceFunctions.sh

echo Loading StreamLab projects from `pwd`
# what is in the cwd
ls -l

# unpack project and create the project schemas
for slab in *.slab
do
    if [ -e $slab ]
    then
        echo ... unpacking $slab
        setup.sh $(basename $slab .slab)
    else
        echo no file $slab
        break
    fi
done

# 

echo ... in case of multiple projects, generate a start script
generatePumpScripts

echo ... and start pumps
sqllineClient --run=startPumps.sql

echo start remaining required services
if [ -e /etc/init.d/webagentd ]
then
  service webagentd start
else
  echo ... no webagentd to start
fi

if [ -e /etc/init.d/s-dashboardd ]
then
  echo ... point s-Dashboard to use the project dashboards directory
  echo "SDASHBOARD_DIR=/home/sqlstream/${PROJECT_NAME}/dashboards" >> /etc/default/s-dashboardd
  cat /etc/default/s-dashboardd | grep SDASHBOARD_DIR

  service s-dashboardd start 
else
  echo no s-dashboardd to start
fi

# now the caller ENTRYPOINT should tail the s-Server trace file forever – so this entrypoint never finishes
# and the trace file can be viewed using docker logs


