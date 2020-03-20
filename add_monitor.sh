#!/bin/bash
#
# Call this script from your pre-startup.sh script if you want monitoring to be included

# create the SQLstream_Monitor schema with its useful components

sqllineClient --run=/home/sqlstream-docker-utils/setup_monitor_streams.sql

# include the monitor.slab file in the current directory

ln -s /home/sqlstream-docker-utils/monitor.slab


