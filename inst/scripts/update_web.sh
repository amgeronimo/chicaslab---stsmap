#!/bin/sh

if [ ! -d stsmap ] ; then
    echo No stsmap directory here in $PWD
    exit -1
fi

if [ ! -d stsmodel ] ; then
    echo No stsmodel directory here in $PWD
    exit -1
fi

(cd stsmap; git pull)
(cd stsmodel; git pull)

## run the daily update script in this docker container
docker run -v $PWD/:/app/ -i -t stsmodel ./stsmap/inst/scripts/update_model.sh

# now see if ./stsmap/ has new files, push if it has.
#...

cd stsmap

git status --porcelain | grep "^??"
status=$?
if [ $status = 1 ] ; then
    echo no change
else
    git add inst/
    git commit -a -m 'new data'
    git push
fi

