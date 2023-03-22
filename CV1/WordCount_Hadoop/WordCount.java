package dist_app_environment.wordcount_mapreduce;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.StringTokenizer;

public class WordCount {

    /**
     * Create and initialize a new MapReduce job for this class.
     *
     * @param configuration Hadoop configuration
     * @return the job
     * @throws IOException error in getting an instance of the job
     */
    public static Job createJob(Configuration configuration) throws IOException {
        final Job job = Job.getInstance(configuration, WordCount.class.getSimpleName());
        job.setJarByClass(WordCount.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        return job;
    }

    /**
     * MapReduce Mapper
     */
    public static class TokenizerMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
        // WordCount version
        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();

        public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
            // Convert each line of data to string for processing
            String line = value.toString();
            // Split up each element of the line by dashes and spaces (compound first names)
            String[] elements = line.split("[- ]");
            // output all individual names
            for (String name : elements) {
                word.set(name);
                context.write(word, one);
            }
        }
    }

    /**
     * MapReduce Reducer
     */
    public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

}
