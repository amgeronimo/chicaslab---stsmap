#!/bin/sh

R --vanilla <<EOF
library(devtools)
load_all("./stsmap")
model_and_map(modeldir="./stsmodel/",outputdir="./stsmap/inst/days/", useDate=TRUE)
EOF

