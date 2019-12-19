#!/bin/bash
#
# Sets the environment for using s-Server

. /etc/sqlstream/environment
export SQLSTREAM_HOME
export JAVA_HOME
export PATH=$PATH:$SQLSTREAM_HOME/bin:$JAVA_HOME/bin

