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
    
    while true
    do
        echo ... wait until port 5570 responds
        nc -z localhost 5570
        sleep 2
    done

    #echo WAIT-S-SERVER
    # wait until server is ready
    while ! isServerReady
    do
        echo "...waiting for s-server"
        sleep 2
    done

    echo ...sleep for 2 minutes to allow HDFS initialization
    sleep 120

}

function startsServer() {
    # speed up startup for unlicensed server
    touch $SQLSTREAM_HOME/catalog/entitlementId.txt

    # place license file in SQLSTREAM_HOME if present
    for f in *.lic
    do
        if [ -e $f ]
        then
            cp $f $SQLSTREAM_HOME
        fi
    done

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

# Run a pre-startup script if present
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

