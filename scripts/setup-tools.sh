#!/bin/bash
set -e

mkdir -p /opt/tools

gcloud storage cp gs://${google_storage_bucket}/lib/tools/* /opt/tools/

chmod -R 755 /opt/tools