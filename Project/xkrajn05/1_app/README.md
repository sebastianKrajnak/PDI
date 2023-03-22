# MapReduce WordCount Example

The example runs a [WordCount example](https://github.com/apache/hadoop/blob/master/hadoop-mapreduce-project/hadoop-mapreduce-examples/src/main/java/org/apache/hadoop/examples/WordCount.java) in a Hadoop (DFS) cluster.

## Running in DFS Mini Cluster

In the case of DFS Mini cluster, all input files, and also the output directory should be in the local filesystem.
The input files are uploaded into a HDFS of the mini-cluster and results are downloaded back to the local filesystem.

~~~shell
./gradlew build
java -cp ./build/libs/wordcount-mapreduce-1.0-SNAPSHOT-all.jar dist_app_environment.wordcount_gamessumDriverMini <local_in> [<local_in>...] <local_out>
~~~

or

~~~shell
./gradlew run --args="<local_in> [<local_in>...] <local_out>"
~~~

## Running in Hadoop Cluster

~~~shell
./gradlew build
hadoop jar ./build/libs/wordcount-mapreduce-1.0-SNAPSHOT-all.jar <hdfs_in> [<hdfs_in>...] <hdfs_out>
~~~
