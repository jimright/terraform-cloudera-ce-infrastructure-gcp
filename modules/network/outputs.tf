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

# File: tf_cluster_gcp/modules/network/outputs.tf

output "vpc_self_link" {
  description = "Self-link of the VPC network fetched by the module."
  # This should reference the data source or resource that defines the VPC
  value = local.pvc_base_vpc.self_link
}

output "region" {
  value       = var.region
  description = "The GCP region used for deployment, as provided in the input variables."
}

output "vpc_name" {
  value       = var.vpc_name
  description = "The GCP VPC network name used for deployment, as provided in the input variables."
}

output "created_public_subnets" {
  description = "A map containing detailed attributes of the created public subnets, keyed by their internal iteration index."
  value = {
    for k, subnet in google_compute_subnetwork.pvc_base_public : k => {
      id            = subnet.id
      name          = subnet.name
      self_link     = subnet.self_link
      ip_cidr_range = subnet.ip_cidr_range
      region        = subnet.region
    }
  }
}

output "created_private_subnets" {
  description = "A map containing detailed attributes of the created private subnets, keyed by their internal iteration index."
  value = {
    for k, subnet in google_compute_subnetwork.pvc_base_private : k => {
      id                       = subnet.id
      name                     = subnet.name
      self_link                = subnet.self_link
      ip_cidr_range            = subnet.ip_cidr_range
      region                   = subnet.region
      private_ip_google_access = subnet.private_ip_google_access
    }
  }
}

output "vpc_private_cidr_block" {
  value = google_compute_subnetwork.pvc_base_private[0].ip_cidr_range
}

output "vpc_public_cidr_block" {
  value = google_compute_subnetwork.pvc_base_public[0].ip_cidr_range
}

output "router_name" {
  value       = google_compute_router.pvc_base.name
  description = "The name of the created Cloud Router resource."
}

output "nat_gateway_name" {
  value       = google_compute_router_nat.pvc_base.name
  description = "The name of the created Cloud NAT gateway resource."
}

output "firewall_acme_rule_name" {
  value       = google_compute_firewall.acme_tls.name
  description = "The name of the firewall rule configured for ACME Directory challenge communication."
}
