# stsmap repository

This repository contains the outputs from the `stsmodel` and is used to generate
web pages via the gitlab pages system.

It used to be an R package with code that generated the pages but now that code is 
in `stsmodel` and this repository is purely a set of output days in `./inst/days`, 
with a CI script that makes the gitlab pages site from the latest day.

