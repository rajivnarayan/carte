#!/bin/bash

wget https://github.com/gastonstat/arcdiagram/archive/refs/heads/master.zip -O arcdiagram.zip
wget https://github.com/jcheng5/crosstalk/archive/refs/heads/master.zip -O crosstalk.zip
wget https://github.com/jcheng5/d3scatter/archive/refs/heads/master.zip -O d3scatter.zip
#rstudio/blogdown, in CRAN

# cytolib dev version that compiles, Bioc version 2.10.1 breaks
CYTOLIB_SHA='24e6c07'
wget https://github.com/RGLab/cytolib/archive/${CYTOLIB_SHA}.zip -O cytolib-${CYTOLIB_SHA}.zip
# rename the SHA from root folder name (breaks R install)
zipnote cytolib-${CYTOLIB_SHA}.zip | awk '/@ cytolib-[0-9a-f]*/{print;sub("@ cytolib-[a-f0-9]*/","@=cytolib/",$0);print;print "@ (comment above this line)"}' > rename.txt
zipnote -w cytolib-${CYTOLIB_SHA}.zip < rename.txt

# cytolib dev version that compiles, Bioc version 2.10.1 breaks
#'14781e7' 2.9.0
FLOWCORE_SHA='1dee393'
wget https://github.com/RGLab/flowCore/archive/${FLOWCORE_SHA}.zip -O flowCore-${FLOWCORE_SHA}.zip &&
zipnote flowCore-${FLOWCORE_SHA}.zip | awk '/@ flowCore-[0-9a-f]*/{print;sub("@ flowCore-[a-f0-9]*/","@=flowCore/",$0);print;print "@ (comment above this line)"}' > rename.txt &&
zipnote -w flowCore-${FLOWCORE_SHA}.zip < rename.txt &&
rm rename.txt


wget https://github.com/RGLab/flowCore/archive/${FLOWCORE_SHA}.tar.gz -O flowCore-tmp.tar.gz &&
tar zxvf flowCore-tmp.tar.gz  --transform 's/^flowCore-[0-9a-f]*/flowCore/' &&
tar zcvf flowCore-${FLOWCORE_SHA}.tar.gz flowCore &&
rm flowCore-tmp.tar.gz &&
rm -rf flowCore
