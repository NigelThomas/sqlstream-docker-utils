#!/bin/bash
#
# This is a version of fetch_and_start_project that will fetch a StreamLab project or multi-project 
# from a git repository and install to s-Server

cd /home/sqlstream

# the environment variables define which project gets loaded
git clone --depth 1 ${GIT_ACCOUNT}/${GIT_PROJECT_NAME}.git

. serviceFunctions.sh

startsServer

# run prestartup script if present
preStartup

cd ${GIT_PROJECT_NAME}
# the startup script orchestrates loading and running the project
time PROJECT_NAME=GIT_PROJECT_NAME startup.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0



