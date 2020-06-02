#!/bin/bash
#
# This is a version of fetch_and_start_project that will fetch a StreamLab project or multi-project 
# from a git repository and install to s-Server

cd /home/sqlstream

echo PATH=$PATH
echo sourcing $(which serviceFunctions.sh)

. serviceFunctions.sh

if [ -d ${GIT_PROJECT_NAME} ]
then
    # if the project has been mounted, use that
    echo ${GIT_PROJECT_NAME} already mounted
else
    getGitProject
fi

cd ${GIT_PROJECT_NAME}

copyLicense

linkJndiDirectory

# run pre-server script if present
preServer

startsServer

# run pre-startup script if present
preStartup

# the startup script orchestrates loading and running the project
time PROJECT_NAME=GIT_PROJECT_NAME PATH=$PATH startup.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0



