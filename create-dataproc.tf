// Terraform configuration to create a Google Cloud Dataproc cluster
// with Lightning Engine enabled, along with a GCS Bucket for staging/assets.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# ------------------------------------------------------------------------------
# 1. define variables
# ------------------------------------------------------------------------------

variable "project" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "Dataproc region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Compute zone (optional, auto zone placement used if empty)"
  type        = string
  default     = "us-central1-a"
}

variable "subnetwork" {
  description = "GCP subnetwork name"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the Dataproc cluster"
  type        = string
  default     = "dataproc-benchmark-cluster"
}

variable "image_version" {
  description = "Dataproc image version (Lightning requires 2.3.3 or later)"
  type        = string
  default     = "2.3.3-debian12"
}

variable "master_count" {
  type    = number
  default = 1
}

variable "worker_count" {
  type    = number
  default = 2
}

variable "master_machine_type" {
  type    = string
  default = "n4-standard-8"
}

variable "worker_machine_type" {
  type    = string
  default = "n4-standard-8"
}

variable "native_runtime" {
  description = "Set to 'native' to enable Native Query Execution (NQE) cluster-wide, or 'default' otherwise."
  type        = string
  default     = "default"
}

variable "bucket_name" {
  description = "Name of the GCS bucket to create. Leave empty to auto-generate based on project ID."
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# 2. Create a GCS bucket for Dataproc staging/assets
# ------------------------------------------------------------------------------

resource "google_storage_bucket" "assets_bucket" {
  name                        = var.bucket_name != "" ? var.bucket_name : "${var.project}-dataproc-assets"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# ------------------------------------------------------------------------------
# 3. Upload local lib/ files to the GCS bucket
# ------------------------------------------------------------------------------

resource "google_storage_bucket_object" "lib_files" {
  for_each = fileset("${path.module}/lib", "**")

  name   = "lib/${each.value}"
  bucket = google_storage_bucket.assets_bucket.name
  source = "${path.module}/lib/${each.value}"

  detect_md5hash = filemd5("${path.module}/lib/${each.value}")
}

resource "google_storage_bucket_object" "setup_script" {
  name   = "scripts/setup-tools.sh"
  bucket = google_storage_bucket.assets_bucket.name
  source = "${path.module}/scripts/setup-tools.sh"

  detect_md5hash = filemd5("${path.module}/scripts/setup-tools.sh")
}

# ------------------------------------------------------------------------------
# 4. Create a Dataproc cluster with Lightning Engine enabled
# ------------------------------------------------------------------------------

resource "google_dataproc_cluster" "cluster" {
  name   = var.cluster_name
  region = var.region

  depends_on = [
    google_storage_bucket_object.lib_files
  ]

  cluster_config {
    staging_bucket = google_storage_bucket.assets_bucket.name

    // Enable Lightning Engine at cluster creation
    engine = "LIGHTNING"
    // Enable HTTP port access for the cluster
    endpoint_config {
      enable_http_port_access = true
    }

    initialization_action {
      script      = "gs://${google_storage_bucket.assets_bucket.name}/${google_storage_bucket_object.setup_script.output_name}"
      timeout_sec = 300
    }

    gce_cluster_config {
      zone = var.zone != "" ? var.zone : null
      subnetwork = var.subnetwork != "" ? var.subnetwork : null
      internal_ip_only = true
    }

    master_config {
      num_instances = var.master_count
      machine_type  = var.master_machine_type
    }

    worker_config {
      num_instances = var.worker_count
      machine_type  = var.worker_machine_type
    }

    software_config {
      image_version = var.image_version

      // Cluster-level properties. To enable Native Query Execution by default
      // set `native_runtime = "native"` when invoking Terraform.
      override_properties = {
        "spark:spark.dataproc.lightningEngine.runtime" = var.native_runtime
      }
    }
  }
}

# ------------------------------------------------------------------------------
# 5. Outputs
# ------------------------------------------------------------------------------

output "cluster_name" {
  value = google_dataproc_cluster.cluster.name
}

output "bucket_name" {
  value       = google_storage_bucket.assets_bucket.name
  description = "The name of the created GCS bucket"
}