rm -r build
rm ../gamessum-mapreduce-1.0-SNAPSHOT.jar
rm -r ../$1
hdfs dfs -rm -r $1
./gradlew build
cp build/libs/gamessum-mapreduce-1.0-SNAPSHOT.jar ../
cd ..
mkdir $1
hadoop jar gamessum-mapreduce-1.0-SNAPSHOT.jar Fielding.csv $1 1> >(tee $1/stdout.txt) 2> >(tee $1/stderr.txt )
hdfs dfs -cat $1/part-* > $1/1_output_mr.txt
cd gamessum-mapreduce