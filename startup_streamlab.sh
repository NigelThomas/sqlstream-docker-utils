#!/bin/bash
#
# startup_streamlab.sh
#
# loads all slab files into StreamLab, and starts underlying pumps
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

echo startup_streamlab.sh PATH=$PATH

. serviceFunctions.sh

startStreamLab

echo Loading StreamLab projects from `pwd`

# what is in the cwd
ls -l

# load all slab files

echo loading slab files $LOAD_SLAB_FILES from `pwd`

for f in ${LOAD_SLAB_FILES:=*.slab}
do
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

