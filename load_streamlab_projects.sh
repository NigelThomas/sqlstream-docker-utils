#!/bin/bash
#
# This is a version of fetch_and_load_project that will fetch a StreamLab project or multi-project 
# from a git repository and install to s-Server - still in the form of StreamLab projects

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

# run pre-server script if present (things that need to happen before s-Server is up)
preServer

startsServer

startStreamLab

# run pre-startup script if present (things that need s-Server to be up, and need to happen before the remainder of startup)
preStartup

# the startup script orchestrates loading and running the project

# loads all slab files into StreamLab, and starts underlying pumps
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

echo Loading StreamLab projects from `pwd` using $LOAD_SLAB_FILES

for f in ${LOAD_SLAB_FILES}
do
    echo loading slab files $f from `pwd`

    if [ -e $f ]
    then
        echo
        echo posting $f to StreamLab

        # TODO check if project already exists in repository, fail if so

        # convert the SLAB file into a submission
        python /home/sqlstream/sqlstream-docker-utils/slabLoader.py $f

        # call the API
        curl -v -H "Content-Type: application/json" -d@/tmp/slab.json http://localhost:5585/_project_import/user

        # TODO check response

        rm /tmp/slab.json
        echo

    else
        echo No such project export file $f
    fi
done

time PROJECT_NAME=GIT_PROJECT_NAME PATH=$PATH startup.sh
echo "========= Ready ======="

tail -F /var/log/sqlstream/Trace.log.0

