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

# File: tf_cluster_gcp/modules/hosts/variables.tf

# ------- Global Config -------
variable "project_id" {
  type        = string
  description = "GCP project ID where instances will be created."
}

variable "zones" {
  type        = list(string)
  description = "GCP zone (e.g., us-central1-a) where instances will be created."
}

variable "instance_labels" { # Renamed from 'tags'
  type        = map(string)  # Changed from map(any)
  default     = {}
  description = "Map of labels (key-value pairs) to apply to the compute instances."
}

variable "network_tags" {
  type        = list(string)
  default     = []
  description = "List of network tags to attach to instances (for firewall rules)."
}

# ------- Image Configuration -------
variable "image" {
  type        = any
  description = "Self-link the image (e.g., 'debian-cloud', 'centos-cloud', or your custom project)."
  default     = null
}

variable "image_os_user" {
  type        = string
  description = "GCP image default user. (e.g., 'cloud-user' for rhel-8)"
  default     = "cloud-user"
}

# ------- SSH Key -------
variable "ssh_public_key" {
  type        = string
  description = "The contents of the SSH public key to be added to the instance metadata for SSH access."
}

# ------- Instances -------
variable "name" {
  type        = string
  description = "Instance base name. If 'quantity' is 0, this is the exact name of the single instance. If 'quantity' > 0, name will be <name>-NN."
}

variable "quantity" {
  type        = number
  description = "Number of instances. If 0 (default), one instance will be created with the exact 'name'. If > 0, 'quantity' instances will be created with numbered names."
  default     = 0 # Defaulting to 0 means 1 instance will be created with the plain 'name'
  validation {
    condition     = var.quantity >= 0
    error_message = "Quantity must be a non-negative number."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet self-links or names to assign instances to. Instances will be distributed across these subnets. Must not be empty if instances are created."
}

variable "subnetwork_project_id" {
  type        = string
  description = "The project ID of the subnetwork. Defaults to var.project_id if not set (for non-Shared VPC scenarios)."
  default     = ""
}

variable "public_ip" {
  type        = bool
  description = "Assign an ephemeral public IP address to the instance's network interface. Set to false if 'external_ip_address' is provided."
  default     = false
}

variable "external_ip_address" { # NEW VARIABLE
  type        = string
  description = "Optional: A pre-allocated static external IP address to assign to the instance. If provided, 'public_ip' should typically be false as this takes precedence."
  default     = null
}

variable "instance_type" {
  type        = string
  description = "GCP machine type (e.g., e2-medium, n1-standard-1)."
  default     = "e2-micro"
}

variable "root_volume" {
  type = object({
    delete_on_termination = optional(bool, true)
    volume_size           = optional(number, 20)
    volume_type           = optional(string, "pd-standard")
  })
  description = "Root volume configuration for the boot disk."
  default     = {}
}

variable "startup_script" {
  type        = string
  description = "Optional startup script (content, not path) to run on instance creation."
  default     = <<-EOT
    #!/bin/bash
    yum makecache >> /var/log/startup_script.log 2>&1
  EOT
}

# ------- Additional Storage Volumes -------
variable "volumes" {
  type = list(object({
    name_suffix = string
    device_name = string # e.g. "sdb", "sdc" (will be /dev/sdb, /dev/sdc on instance)
    mount       = string
    volume_size = optional(number, 100)
    volume_type = optional(string, "pd-standard")
    labels      = optional(map(string), {})
  }))
  default     = []
  description = "List of additional persistent volumes to create and attach to each instance."
}
