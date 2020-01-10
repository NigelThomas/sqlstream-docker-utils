#!/bin/bash
#
# This is a version of fetch_and_start_project that will fetch a StreamLab project or multi-project 
# from a git repository and install to s-Server

cd /home/sqlstream

# the environment variables define which project gets loaded
git clone --depth 1 ${GIT_ACCOUNT}/${GIT_PROJECT_NAME}.git
echo ... chown -R sqlstream:sqlstream ${GIT_PROJECT_NAME}
chown -R sqlstream:sqlstream ${GIT_PROJECT_NAME}
su sqlstream  -m -c "find /home/sqlstream/${GIT_PROJECT_NAME} -type f -name '*.keytab' -exec chmod -v 0600 {} \;"


. serviceFunctions.sh

cd ${GIT_PROJECT_NAME}

# move any license file(s) into s-Server directory
find . -name "*.lic" -type f -exec cp -v {} $SQLSTREAM_HOME \;

startsServer

# workaround issue with HDFS / Kerberos
service s-serverd stop
startsServer

# run prestartup script if present
preStartup

# the startup script orchestrates loading and running the project
time PROJECT_NAME=GIT_PROJECT_NAME startup.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0



