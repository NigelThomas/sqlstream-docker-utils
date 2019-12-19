# sqlstream-docker-utils

This repository includes utility scripts that can be used to create and run Docker images for SQLstream and StreamLab projects.

# Event points

At certain points in the startup processing, the generic scripts can call project-specific scripts. This scripts are found by setting the PATH and using `which`, so the scripts 
must be executable.

Current supported event points:

* pre-startup.sh - if found, the script will be executed. Use this to pre-load external tables (if needed) or kick off a local process or service




