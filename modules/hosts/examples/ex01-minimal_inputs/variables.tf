# Copyright 2025 Cloudera, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ------- General and Provider Resources -------

variable "project_id" {
  type        = string
  description = "GCP project ID where all resources will be deployed."
}

variable "region" {
  type        = string
  description = "GCP region for deployment (e.g., us-central1)."
}

variable "prefix" {
  type        = string
  description = "Deployment prefix for naming all cloud-provider assets. Must be 4-10 characters."
  validation {
    condition     = length(var.prefix) >= 4 && length(var.prefix) <= 10
    error_message = "Valid length for prefix is between 4-10 characters."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block (primary)"
  default     = "10.10.0.0/16"
}

variable "asset_tags" {
  type        = map(string)
  default     = {}
  description = "Map of labels applied to all resources created by this cluster module where applicable."
}

variable "public_subnets_config" {
  type = list(object({
    name   = string
    cidr   = string
    labels = map(string)
  }))
  default     = []
  description = "Configuration for public subnets to be created by tf_network_gcp. If empty, tf_network_gcp might create defaults based on 'vpc_cidr'."
}

variable "private_subnets_config" {
  type = list(object({
    name   = string
    cidr   = string
    labels = map(string)
  }))
  default     = []
  description = "Configuration for private subnets to be created by tf_network_gcp. If empty, tf_network_gcp might create defaults based on 'vpc_cidr'."
}

# ------- Instance Configuration - Global Image Settings -------

variable "os_version" {
  description = "RHEL (or compatible) version (e.g., 8.10)"
  type        = string
  # GCP support major version only, this will ignore minor release
  default = "9"
}

variable "os_type" {
  type        = string
  description = "Type of OS (e.g., 'rhel', 'rocky')"
  default     = "rocky"
}

variable "os_user" {
  type        = string
  description = "Default SSH username for the chosen OS images (e.g., 'cloud-user' for RHEL, 'centos' for CentOS, 'debian' for Debian)."
  default     = "cloud-user" # Common for RHEL on GCP
}

variable "instance_type" {
  type        = string
  description = "GCP machine type (e.g., e2-medium, n1-standard-1)."
  default     = "e2-micro"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GB for master instances."
  default     = 250
}

variable "data_volumes" {
  type = list(object({
    name_suffix = string # e.g., "data1", "logs"
    device_name = string # e.g., "sdb", "sdc" (will be /dev/sdb, /dev/sdc on instance)
    mount       = string # Informational mount point
    volume_size = optional(number, 250)
    volume_type = optional(string, "pd-ssd") # Often SSD for masters
    labels      = optional(map(string), {})
  }))
  default     = []
  description = "Data volume configurations for each master instance. Each instance will get these volumes."
  # default     = [{
  #   name_suffix = "data1",
  #   device_name = "sdb",
  #   mount       = "/data1",
  #   volume_size = 250,
  #   volume_type = "pd-ssd"
  # }]  
}