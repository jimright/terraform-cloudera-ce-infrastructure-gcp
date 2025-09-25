# Copyright 2025 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ------- Required Variables -------

variable "prefix" {
  type        = string
  description = "Deployment prefix used for naming all cloud-provider assets created by this module."
}

variable "region" {
  type        = string
  description = "The GCP region where resources will be deployed."
}

variable "vpc_name" {
  type        = string
  description = "The name of the GCP VPC network into which subnets and other network resources will be deployed."
}

variable "vpc_exists" {
  type        = bool
  description = "Use existing GCP VPC network."
}

variable "base_cidr_block" {
  type        = string
  description = "The base CIDR block (e.g., '10.50.0.0/16') from which default public and private subnet CIDRs will be derived. This variable is required if 'public_subnets' or 'private_subnets' are not explicitly provided."
  default     = "10.10.0.0/16"
  # Optional: Add a validation to ensure it's a valid CIDR format.
  validation {
    condition     = can(cidrhost(var.base_cidr_block, 0))
    error_message = "The 'base_cidr_block' must be a valid CIDR format (e.g., '10.0.0.0/16')."
  }
}

# variable "asset_tags" {
#   type        = map(string)
#   default     = {}
#   description = "Map of labels applied to all cloud-provider assets created by this module. These are GCP resource labels."
# }
# ------- Network Resources Configuration Variables -------

variable "public_subnets" {
  type = list(object({
    name   = string
    cidr   = string
    labels = map(string) # Renamed from 'tags' to 'labels' for clarity and consistency with GCP resource labels
  }))

  description = "A list of objects defining public subnets. Each object requires 'name', 'cidr', and 'labels' (a map of strings). If this list is empty, a single default public subnet will be created using 'base_cidr_block'."
  default     = []
}

variable "private_subnets" {
  type = list(object({
    name   = string
    cidr   = string
    labels = map(string) # Renamed from 'tags' to 'labels' for clarity and consistency with GCP resource labels
  }))

  description = "A list of objects defining private subnets. Each object requires 'name', 'cidr', and 'labels' (a map of strings). If this list is empty, a single default private subnet will be created using 'base_cidr_block'."
  default     = []
}
