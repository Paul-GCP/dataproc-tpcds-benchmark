// Terraform configuration to create a Google Cloud Dataproc cluster
// with Lightning Engine enabled. Adjust variables as needed before applying.

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

variable "staging_bucket" {
  description = "GCS bucket for Dataproc staging. If empty, Dataproc will auto-create one."
  type        = string
  default     = ""
}

resource "google_dataproc_cluster" "cluster" {
  name   = var.cluster_name
  region = var.region

  cluster_config {
    staging_bucket = var.staging_bucket != "" ? var.staging_bucket : null

    // Enable Lightning Engine at cluster creation
    engine = "LIGHTNING"

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

output "cluster_name" {
  value = google_dataproc_cluster.cluster.name
}
