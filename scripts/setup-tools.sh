#!/bin/bash
set -e

mkdir -p /root/tools

gcloud storage cp gs://dataproc-tpcds-bench/lib/tools/* /opt/tools/

chmod -R 755 /opt/tools