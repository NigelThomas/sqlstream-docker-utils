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
        echo posting $f

        # TODO check if project already exists, fail if so

        (
             # We need to insert adjustments into the slab file just before the final }
             # these elements include their quotes
 
             title=$(cat $f | jq .projectModel.title)
             schema=$(cat $f | jq .projectModel.projectSchema)
             
             # and we have to wrap the whole thing with the outer elements here
         
             cat $f | sed -e 's/}$//' ; echo ", \"adjustments\": {\"newName\":\"$(basename $f .slab)\",\"newTitle\":$title,\"newSchema\":$schema, \"setProtect\": \"false\"}}" 
        ) > /tmp/$f.1

        # now stringify the slab file
        cat /tmp/$f.1 | jq '. | tostring' > /tmp/$f.2

        # and wrap it up for the call into a single line
        (echo '{"username": "user", "json":' ; cat /tmp/$f.2 ; echo '}' ) | sed -e 's/\n//'  > /tmp/$f.3 
        
        # call the API
        curl -H "Content-Type: application/json" -d@/tmp/$f.3 http://localhost:5585/_project_import/user

        # TODO check response

        rm /tmp/$f.{1,2,3}
        echo

    else
        echo No such project export file $f
    fi
done
}

