./clean.sh
./gradlew run --args="../eurofxref-sdmx.csv spark_out" 1> >(tee 2_log_local.txt) 2> >(tee 2_log_localerr.txt)