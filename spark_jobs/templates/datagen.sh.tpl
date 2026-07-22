nohup spark-submit\
    --master yarn\
    --deploy-mode cluster\
    --num-executors 2\
    --executor-cores 4\
    --executor-memory 18G\
    --driver-memory 16G\
    --driver-cores 2\
    --conf spark.dynamicAllocation.maxExecutors=50 \
    --conf spark.dynamicAllocation.enabled=true \
    --queue default\
    --class com.databricks.spark.sql.perf.TPCDSDataGen\
    --conf "spark.sql.warehouse.dir=gs://${google_storage_bucket}/data/tpcds/spark-warehouse" \
    --conf spark.locality.wait=0s\
    gs://${google_storage_bucket}/lib/spark-tpcds-datagen-2.12.jar\
    --path "gs://${google_storage_bucket}/data/tpcds/"\
    -s 1000\
    --skipDatagen false\
    --toolsDir /opt/tools > spark-job.log 2>&1 &