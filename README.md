# sqlstream-docker-utils

This repository includes utility scripts that can be used to create and run Docker images for SQLstream and StreamLab projects.

These scripts are used in the images created by the Dockerfiles in the https://github.com/NigelThomas/streamlab-git.git repository.

# Development time

In development we use an image that includes StreamLab (and Rose, and WebAgent). We import the currently saved project export files (as StreamLab projects).

As well as importing the projects into StreamLab, we also extract the project DDL and load that into s-Server. StreamLab will do that when you open a project - but if you are installing
multiple projects we have to be sure that all projects are installed in case the first project opened depends on data coming from one of the others. We also start all the pumps. In effect we start
the project in the development environment right after we have loaded the StreamLab projects.

When a user opens one of the StreamLab projects, StreamLab will re-start the pumps for that project.



# Production time

When projects are loaded into production we use lightweight images that don't include StreamLab. The image runs `fetch_and_start_project.sh` which then calls (and times) `startup.sh`. 
SQL is extracted from StreamLab project export files and installed into s-Server. Finally we generate a script to start all the project pumps.


# Event points

At certain points in the startup processing, the generic scripts can call project-specific scripts. This scripts are found by setting the PATH and using `which`, so the scripts 
must be executable.

Current supported event points:

* pre-startup.sh - if found, the script will be executed. Use this to pre-load external tables (if needed) or kick off a local process or service




