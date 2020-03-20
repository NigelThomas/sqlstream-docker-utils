#!/bin/bash
#
# streamlabFunctions.sh
#
# Functions useful for using StreamLab projects in development and production servers
#
# - importSlabFiles - use the Rose API to load all slab files in the current directory





# importSlabFiles Import slab files into the local StreamLab / Rose server

function importSlabFiles() {

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
}

