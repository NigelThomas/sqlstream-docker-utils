# Common functions used to start s-Server

# set environment
. /etc/sqlstream/environment
PATH=$PATH:$SQLSTREAM_HOME/bin

function isServerReady() {
    if serverReady
    then
        return 0
    else
        return 1
    fi
}

function waitForsServer() {
    
#    while true
#    do
#        echo ... wait until port 5570 responds
#        nc -z localhost 5570
#        sleep 2
#    done

    # wait until server is ready
    while ! isServerReady
    do
        echo "...waiting for s-server"
        sleep 2
    done

    : ${SQLSTREAM_SLEEP_SECS:=0}

    if [ ${SQLSTREAM_SLEEP_SECS} -gt 0 ]
    then
        echo ...sleep for $SQLSTREAM_SLEEP_SECS to allow HDFS initialization
        sleep $SQLSTREAM_SLEEP_SECS
    fi

}

function startsServer() {
    # speed up startup for unlicensed server
    touch $SQLSTREAM_HOME/catalog/entitlementId.txt

    if [ -n "$SQLSTREAM_HEAP_MEMORY" ]
    then
        # modify the default heap memory settings
        echo "... increase heap memory to $SQLSTREAM_HEAP_MEMORY"
        sed -i -e "s/2048m/$SQLSTREAM_HEAP_MEMORY/" $SQLSTREAM_HOME/bin/defineAspenRuntime.sh
    fi

    echo starting s-Server
    service s-serverd start
    waitForsServer

}


startStreamLab() {
    service webagentd start
    service streamlabd start
    echo ... StreamLab started
}

# Run a pre-server script if present
# This is executed BEFORE s-Server is started

preServer() {
    preservercript=$(which pre-startup.sh)
    if [ -n "$preserverscript" ]
    then
        echo ...  call project specific startup pre-startup.sh : $preserverscript
        $preserverscript
    elif [ -e pre-server.sh ]
    then
        echo ... call pre-server.sh from `pwd`
        ./pre-server.sh
    else
        echo ... there is no pre-server.sh script in `pwd`
    fi
}

# Run a pre-startup script if present
# This is executed AFTER s-Server is started, but before generic startup.sh

preStartup() {
    prestartupcript=$(which pre-startup.sh)
    if [ -n "$prestartupscript" ]
    then
        echo ...  call project specific startup pre-startup.sh : $prestartupscript
        $prestartupscript
    elif [ -e pre-startup.sh ]
    then
        echo ... call pre-startup.sh from `pwd`
        ./pre-startup.sh
    else
        echo ... there is no pre-startup.sh script in `pwd`
    fi
}

function generatePumpScripts() {

    if isServerReady
    then
        # Create start/stop scripts for pumps in the catalog

        rm -f st*Pumps.sql

        echo
        echo "... generating startPumps.sql and stopPumps.sql"

        # extract all schemas that have pumps, to generate a pump start/stop script ALTER PUMP "a".*,"b".*,"c".* START
        # find the right version of listPumps.sql and .awk using which

        sqllineClient --silent  --showHeader=false --run=$(which listPumps.sql) 2>/dev/null | awk -v action=START -f $(which listPumps.awk) > startPumps.sql
        cat startPumps.sql | sed -e 's/START/STOP/g' > stopPumps.sql

    else
        echo WARNING: s-Server is not running, cannot generate scripts
    fi
}

function copyLicense() {
    # move any license file(s) into s-Server directory
    find . -name "*.lic" -type f -exec cp -v {} $SQLSTREAM_HOME \;
}

function linkJndiDirectory () {
    # is there a jndi directory mounted?
    JNDI_DIR=

    if [ -d /home/sqlstream/jndi ]
    then
        # user-specific jndi directory mounted
        JNDI_DIR=/home/sqlstream/jndi
    elif [ -d ./jndi ]
    then
        # use the project's presupplied jndi directory
        JNDI_DIR=`pwd`/jndi
    fi

    if [ -n "$JNDI_DIR" ]
    then
        echo "... linking jndi property files if any"
        cd $SQLSTREAM_HOME/plugin/jndi
        find $JNDI_DIR -type f -name *.properties -exec ln -v -s {} . \;
        cd -
    fi
}



function getGitProject()
{
    # the environment variables define which version of which project gets loaded

    if [ -d ${GIT_PROJECT_NAME} ]
    then
        echo "Project ${GIT_PROJECT_NAME} already present"
    elif [ -z "$GIT_PROJECT_HASH" -o "$GIT_PROJECT_HASH" = "HEAD" ]
    then
        echo ... getting latest for $GIT_PROJECT_NAME
        git clone --depth 1 ${GIT_ACCOUNT}/${GIT_PROJECT_NAME}.git
    else
        echo ... getting tag / hash $GIT_PROJECT_HASH for $GIT_PROJECT_NAME

        # TODO is there a way to do this in one step without getting full history?
        git clone ${GIT_ACCOUNT}/${GIT_PROJECT_NAME}.git
        cd ${GIT_PROJECT_NAME}
        git checkout $GIT_PROJECT_HASH
        cd -
    fi

    #echo ... chown -R sqlstream:sqlstream ${GIT_PROJECT_NAME}
    #chown -R sqlstream:sqlstream ${GIT_PROJECT_NAME}
    su sqlstream  -m -c "find /home/sqlstream/${GIT_PROJECT_NAME} -type f -name '*.keytab' -exec chmod -v 0600 {} \;"
}

