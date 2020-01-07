#!/bin/bash
#
# This is a version of fetch_and_load_project that will fetch a StreamLab project or multi-project 
# from a git repository and install to s-Server - still in the form of StreamLab projects

cd /home/sqlstream

echo PATH=$PATH
echo sourcing $(which serviceFunctions.sh)

. serviceFunctions.sh

echo PATH=$PATH
echo sourcing $(which streamlabFunctions.sh)

. streamlabFunctions.sh

# the environment variables define which project gets loaded
git clone ${GIT_ACCOUNT}/${GIT_PROJECT_NAME}.git
chown -R sqlstream:sqlstream ${GIT_PROJECT_NAME}
find ${GIT_PROJECT_NAME} -type f -name "*.keytab" -exec echo setting permissions on {} \; -exec chmod +600 {} \;

cd ${GIT_PROJECT_NAME}

# move any license file(s) into s-Server directory
find . -name "*.lic" -type f -exec echo copying {} to s-Server \; -exec cp {} $SQLSTREAM_HOME \;

startsServer
startStreamLab

# run prestartup script if present
preStartup

# the startup script orchestrates loading and running the project
time PROJECT_NAME=GIT_PROJECT_NAME startup_streamlab.sh
time PROJECT_NAME=GIT_PROJECT_NAME startup.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0

