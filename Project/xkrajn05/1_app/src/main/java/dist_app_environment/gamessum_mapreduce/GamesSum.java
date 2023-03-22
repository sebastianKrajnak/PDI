package dist_app_environment.gamessum_mapreduce;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class GamesSum {

    /**
     * Create and initialize a new MapReduce job for this class.
     *
     * @param configuration Hadoop configuration
     * @return the job
     * @throws IOException error in getting an instance of the job
     */
    public static Job createJob(Configuration configuration) throws IOException {
        final Job job = Job.getInstance(configuration, GamesSum.class.getSimpleName());
        job.setJarByClass(GamesSum.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);
        return job;
    }

    /**
     * MapReduce Mapper
     */
    public static class TokenizerMapper extends Mapper<LongWritable, Text, Text, Text> { 

        public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
            // Skip header line
            if( key.get() == 0 && value.toString().contains("playerID") ){
                return;
            }
            // Convert each line of data to string for processing
            String line = value.toString();
            // Split up each element of the line by dashes and spaces (compound first names)
            String[] elements = line.split(",");
            // Only years ge 1995     
            if( Integer.parseInt(elements[1]) >= 1995 ){
                String games = elements[6] + ",1";
                String new_key = elements[0] + "," + elements[3];
                
                context.write( new Text(new_key), new Text(games) );
            }
            else{
                return;
            }
        }
    }

    /**
     * MapReduce Reducer
     */
    public static class IntSumReducer extends Reducer<Text, Text, Text, Text> {

        public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
            double sum = 0;
            double count = 0;

            for (Text val : values) {
                //Split up each value by commas
                if(val.toString() != ""){
                    String[] nums = val.toString().split(",");
                    sum += Integer.parseInt(nums[0]);
                    count += Integer.parseInt(nums[1]);
                }
            }

            //Output "avg_of_games_per_record,sum_of_games" of games iff avg is equal or greater than 10 games
            double avg = sum/count;
            if(avg >= 10){
                Text result = new Text("," + avg + "," + sum);
                context.write(key, result);
            }
            else{
                return;
            }
        }
    }

}
