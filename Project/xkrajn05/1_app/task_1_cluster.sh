#!/bin/sh

./build.sh

# input and output directories are in HDFS, not in a local filesystem (use hdfs dfs -put/-get to upload and download them)
exec hadoop jar build/libs/*-SNAPSHOT.jar cetnost-jmena-dnar-2016/jmena.txt jmena-wordcount.mr_output
