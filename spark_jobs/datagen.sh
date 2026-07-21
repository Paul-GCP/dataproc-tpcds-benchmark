nohup spark-submit\
    --master yarn\
    --deploy-mode cluster\
    --files gs://dataproc-tpcds-bench/lib/hive-site.xml\
    --num-executors 2\
    --executor-cores 4\
    --executor-memory 24G\
    --driver-memory 16G\
    --driver-cores 2\
    --queue default\
    --class com.databricks.spark.sql.perf.TPCDSDataGen\
    --conf spark.locality.wait=0s\
    gs://dataproc-tpcds-bench/lib/spark-tpcds-datagen-2.12.jar\
    --path "gs://dataproc-tpcds-bench/data/tpcds/"\
    -s 1\
    --skipDatagen false\
    --toolsDir /opt/tools > spark-job.log 2>&1 &