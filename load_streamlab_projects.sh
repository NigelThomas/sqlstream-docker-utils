#!/bin/bash
#
# This is a version of fetch_and_load_project that will fetch a StreamLab project or multi-project 
# from a git repository and install to s-Server - still in the form of StreamLab projects

cd /home/sqlstream

# the environment variables define which project gets loaded
git clone ${GIT_ACCOUNT}/${GIT_PROJECT_NAME}.git

cd ${GIT_PROJECT_NAME}

# the startup script orchestrates loading and running the project
time PROJECT_NAME=GIT_PROJECT_NAME startup_streamlab.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0

