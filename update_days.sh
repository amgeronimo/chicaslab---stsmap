#!/bin/sh

## find the most recent data folder in ./inst/days/ and copy to public

## one of the joys of iso8601 is numeric sort order is by time:

lastday=`ls ./days/|sort -n|tail -n 1`

echo Latest day is $lastday : copying to public.

cp -r ./days/${lastday}/* ./public/


