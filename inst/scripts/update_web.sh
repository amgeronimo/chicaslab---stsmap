#!/bin/sh

if [ ! -d stsmap ] ; then
    echo No stsmap directory here in $PWD
fi

(cd stsmap; git pull)

if [ ! -d stsmodel ] ; then
    echo No stsmodel directory here in $PWD
fi

(cd stsmodel; git pull)

## run the daily update script in this docker container
#docker run -v $PWD/:/app/Covid -i -t stsmodel ./stsmap/inst/scripts/update_model.sh

