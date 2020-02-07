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

getGitProject

cd ${GIT_PROJECT_NAME}

copyLicense

linkJndiDirectory

# run pre-server script if present (things that need to happen before s-Server is up)
preServer

startsServer

startStreamLab

# run pre-startup script if present (things that need s-Server to be up, and need to happen before the remainder of startup)
preStartup

# the startup script orchestrates loading and running the project
time PROJECT_NAME=GIT_PROJECT_NAME startup_streamlab.sh
time PROJECT_NAME=GIT_PROJECT_NAME startup.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0

