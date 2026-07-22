# dataproc-tpcds-benchmark
Dataproc TPC-DS benchmark to compare lighting engine and default configuration.

### Step 1: Create Dataproc cluster
Use terraform to create Dataproc cluster.

```
cp terraform.tfvars.template
```

Fill up your variables such as project-id or subnetnetwork name.

```
terraform plan
terraform apply
```

### Step 2: Run benchmark

Login into Dataproc master node and submit Spark jobs.

1. Submit data generation job using command in /spark_jobs/datagen.sh file. Change the executor resources according to your Dataproc cluster configuration.

2. Submit benchmark jobs using command in /spark_jobs/benchmark-lighting-engine.sh and /spark_jobs/benchmark-default-runtime.sh to compare running period accoss 100+ queries.


## Step 3: Compare results

Get results in GCS bucket, /tmp/metrics-test-results/ folder, and compare results between Dataproc lighting engine, default runtime or other platform.

### Clean Up
```
terraform destroy
```