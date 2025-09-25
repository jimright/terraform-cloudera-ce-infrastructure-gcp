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

# File: tf_cluster_gcp/modules/hosts/outputs.tf

output "instances" {
  value       = google_compute_instance.pvc_base
  description = "A list of the provisioned GCP compute instance objects. If quantity was 0, this list contains one instance."
}

output "instance_details" {
  description = "A list of detailed information for each created instance."
  value = [
    for inst in google_compute_instance.pvc_base : {
      id                  = inst.id
      name                = inst.name
      zone                = inst.zone
      machine_type        = inst.machine_type
      network_interfaces  = inst.network_interface
      self_link           = inst.self_link
      primary_internal_ip = length(inst.network_interface) > 0 ? inst.network_interface[0].network_ip : null
      primary_external_ip = length(inst.network_interface) > 0 && length(inst.network_interface[0].access_config) > 0 ? inst.network_interface[0].access_config[0].nat_ip : null
    }
  ]
}

output "storage_volumes" {
  value       = local.attached_volumes_by_instance
  description = "Map of additional storage volumes, keyed by instance ID. Each value is a list of volume details attached to that instance."
}
