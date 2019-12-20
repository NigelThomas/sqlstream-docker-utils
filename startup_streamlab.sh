#!/bin/bash
#
# startup_streamlab.sh
#
# loads all slab files into StreamLab, and starts underlying pumps
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

. serviceFunctions.sh
. streamlabFunctions.sh

echo Loading StreamLab projects from `pwd`

# This test project depends on a local Postgres server
service postgresql start

# start s-Server to load the schema
startsServer

# what is in the cwd
ls -l

# load all slab files
importSlabFiles


