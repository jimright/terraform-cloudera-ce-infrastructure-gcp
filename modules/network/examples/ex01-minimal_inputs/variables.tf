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

