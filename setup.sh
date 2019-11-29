# setup.sh
# Assume PATH is set so we don't need to refer to absolute paths
# Assume cwd contains the project

SLAB_PROJECT=$1

echo ... Setting up project $SLAB_PROJECT in directory `pwd`

echo ... extract the SQL scripts needed from ${SLAB_PROJECT}.slab

for script in main start stop
do
    echo ... ... extracting ${SLAB_PROJECT}.${script}.sql
    cat ${SLAB_PROJECT}.slab | jq -r ".projectModel.${script}Script" | sed -e 's/^!/-- /' > ${SLAB_PROJECT}.${script}.sql
done

echo ... adjusting ${SLAB_PROJECT}.main.sql
# workaround because schema may not be created at start
# also remove DROP commands

grep "CREATE OR REPLACE SCHEMA" ${SLAB_PROJECT}.main.sql | uniq > /tmp/${SLAB_PROJECT}.main.sql
grep -v DROP ${SLAB_PROJECT}.main.sql >> /tmp/${SLAB_PROJECT}.main.sql
mv /tmp/${SLAB_PROJECT}.main.sql  ./${SLAB_PROJECT}.main.sql


sqllineClient --run=${SLAB_PROJECT}.main.sql

echo ... extracting StreamLab dashboards if any
mkdir -p ./dashboards 2>/dev/null

cat ${SLAB_PROJECT}.slab | jq -cr '.dashboards | keys[] as $k | "\($k)\n\(.[$k])"' | while read -r key
do
    fname=$(cat ${SLAB_PROJECT}.slab | jq --raw-output ".dashboards | .[$key].coll + \"-\" + .[$key].dash")
    read -r item
    printf '%s\n' "$item" | jq -r --indent 4 '.dashModel' > "./dashboards/$fname.json"
    echo ... ... dashboard $fname extracted
done

