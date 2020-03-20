#!/bin/bash
#
# Call this script from your pre-startup.sh script if you want monitoring to be included

H=/home/sqlstream/sqlstream-docker-utils

# create the SQLstream_Monitor schema with its useful components

sqllineClient --run=$H/setup_monitor_streams.sql

# include the monitor.slab file in the current directory

ln -s $H/monitor.slab


