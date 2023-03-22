package dist_app_environment.currencystats_spark

import java.io.File

import org.apache.commons.io.FileUtils
import org.apache.spark.launcher.SparkLauncher
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._


object CurrencyStats {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: currencystats <hdfs_in> [<hdfs_in>...] <hdfs_out>\n"
        + "hdfs_* args should start with hdfs:// for an HDFS filesystem or file:// for a local filesystem")
      System.exit(2)
    }
    // environment variable of Spark master node defaults to local[*] if the the master URL is absent
    if (System.getProperty(SparkLauncher.SPARK_MASTER) == null) {
      System.setProperty(SparkLauncher.SPARK_MASTER, "local[*]")
    }
    // create a Spark session for the job with respect to the environment variable above
    val spark = SparkSession.builder.appName(CurrencyStats.getClass.getSimpleName).getOrCreate()

    // load dataframe with data from csv file
    val df = spark.read.format("csv")
      .option("header", "true") // uses the first line as names of columns
      .option("inferSchema", "true") // infers the input schema automatically from data (one extra pass over the data)
      .option("delimiter", ",")
      .load(args.dropRight(1): _*)
    df.printSchema()

    // Task 1 find max, min and avg values of each currency for the whole time period ----------------------------------------------
    // drop TIME_PERIOD column as groupBy would not work otherwise and it's not needed for this task
    val noTime = df.drop("TIME_PERIOD")
    
    val result = df.groupBy("CURRENCY").agg(min("OBS_VALUE"),max("OBS_VALUE"),avg("OBS_VALUE"))
    result.show()

    // dump results
    var outputPathDf = args.last + "/maxMinAvgAll-df"
    result.write.format("csv").option("header", "true").save(outputPathDf) 

    // Task 4 currencies with larges and lowest values ----------------------------------------------------------------------------
    // use limit instead of take, limit creates a new Dataframe, take creates an array of rows!!!!!
    val maxRow = result.orderBy(desc("max(OBS_VALUE)")).limit(1)
    val minRow = result.orderBy(asc("min(OBS_VALUE)")).limit(1)

    // I know it can be exported in a prettier way but honestly trying to do that wasted me so much time pointlessly, this will do

    val maxMinDf = maxRow.union(minRow)
    maxMinDf.show()
    
    outputPathDf = args.last + "/maxMin-df"
    maxMinDf.write.format("csv").option("header", "true").save(outputPathDf) 
  }
}
