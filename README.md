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


### Clean Up
```
terraform destroy
```