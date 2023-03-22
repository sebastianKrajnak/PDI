#!/bin/sh

./build.sh

# input and output directories are in HDFS, not in a local filesystem (use hdfs dfs -put/-get to upload and download them)
# DataStreamer exception java.lang.InterruptedException is not an error
# for the output, see: jmena-currencystats.spark_output/as-dataframe
# Scala version in the application build and in the Spark must be identical, otherwise, there will be "main" java.lang.NoSuchMethodError: scala.Predef$.refArrayOps([Ljava/lang/Object;)[Ljava/lang/Object;
exec spark-submit build/libs/*-SNAPSHOT.jar eurofxref-sdmx.csv spark_output 1> >(tee 2_log_cluster.txt) 2> >(tee 2_log_clustererr.txt)
