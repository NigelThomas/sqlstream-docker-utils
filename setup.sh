# setup.sh
# Assume PATH is set so we don't need to refer to absolute paths
# Assume cwd contains the project

SLAB_PROJECT=$1

echo ... Setting up project $SLAB_PROJECT in directory `pwd`

echo ... extract the SQL scripts needed from ${SLAB_PROJECT}.slab

# generate the scripts
python /home/sqlstream/sqlstream-docker-utils/slabExtractScript.py ${SLAB_PROJECT} main start stop

# TODO IS THIS STILL NEEDED
echo ... adjusting ${SLAB_PROJECT}.main.sql
# workaround because schema may not be created at start
# also remove DROP commands

grep "CREATE OR REPLACE SCHEMA" ${SLAB_PROJECT}.main.sql | uniq > /tmp/${SLAB_PROJECT}.main.sql
grep -v DROP ${SLAB_PROJECT}.main.sql >> /tmp/${SLAB_PROJECT}.main.sql
mv /tmp/${SLAB_PROJECT}.main.sql  ./${SLAB_PROJECT}.main.sql


sqllineClient --run=${SLAB_PROJECT}.main.sql

python /home/sqlstream/sqlstream-docker-utils/slabExtractDashboards.py ${SLAB_PROJECT}

