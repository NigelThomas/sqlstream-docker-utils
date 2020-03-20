#!/bin/bash
#
# startup_streamlab.sh
#
# loads all slab files into StreamLab, and starts underlying pumps
# assume PATH is set to ensure we can find subsidiary scripts
# assume cwd is set to the project directory

echo startup_streamlab.sh PATH=$PATH

. serviceFunctions.sh
. streamlabFunctions.sh

echo Loading StreamLab projects from `pwd`

# what is in the cwd
ls -l

# load all slab files
echo call importSlabFiles
importSlabFiles


