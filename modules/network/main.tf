# Copyright 2025 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: The 'provider "google"' block is removed from here as per best practice.
# It's recommended to configure the provider in the root module that calls this
# module, allowing for consistent provider configuration across your
# entire Terraform deployment.

# ------- VPC -------
resource "google_compute_network" "pvc_base" {
  count                   = var.vpc_exists ? 0 : 1
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "Custom VPC for ${var.vpc_name}"
}

# --- Existing VPC ---
data "google_compute_network" "existing_pvc_base" {
  count = var.vpc_exists ? 1 : 0 # Look up if vpc_exists is true

  name = var.vpc_name
}

# Locals: define public and private subnet lists.
# If the respective input variable is empty, a default subnet configuration
# will be generated using the 'base_cidr_block'.
locals {

  pvc_base_vpc = var.vpc_exists ? data.google_compute_network.existing_pvc_base[0] : google_compute_network.pvc_base[0]

  public_subnets = length(var.public_subnets) > 0 ? var.public_subnets : [
    {
      name   = "${var.prefix}-public-subnet-01"
      cidr   = cidrsubnet(var.base_cidr_block, 8, 0) # Uses the provided base_cidr_block
      labels = {}                                    # Using 'labels' for consistency with GCP resource labels
    }
  ]

  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : [
    {
      name   = "${var.prefix}-private-subnet-01"
      cidr   = cidrsubnet(var.base_cidr_block, 8, 1) # Uses the provided base_cidr_block
      labels = {}                                    # Using 'labels' for consistency with GCP resource labels
    }
  ]

}

# Define public subnet(s)
resource "google_compute_subnetwork" "pvc_base_public" {
  # Iterate over the 'public_subnets' local variable to create multiple subnets.
  # The 'for_each' meta-argument allows for dynamic creation of resources.
  for_each = { for idx, subnet in local.public_subnets : idx => subnet }

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = local.pvc_base_vpc.self_link
  # Public subnets typically do not need private Google access.
  private_ip_google_access = false

  # Merge common asset labels (var.asset_tags), specific subnet labels (each.value.labels),
  # and a standard 'Name' label for consistent metadata application.
  # labels = merge(var.asset_tags, each.value.labels, { Name = each.value.name }) # Unsupported argument
}

# Define private subnet(s)
resource "google_compute_subnetwork" "pvc_base_private" {
  # Iterate over the 'private_subnets' local variable to create multiple subnets.
  for_each = { for idx, subnet in local.private_subnets : idx => subnet }

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = local.pvc_base_vpc.self_link
  # Private subnets often need private Google access for accessing Google services
  # without traversing the public internet.
  private_ip_google_access = true

  # Merge common asset labels, specific subnet labels, and a standard 'Name' label.
  # labels = merge(var.asset_tags, each.value.labels, { Name = each.value.name }) # Unsupported argument
}

# Cloud Router for NAT
resource "google_compute_router" "pvc_base" {
  name    = "${var.prefix}-pvc-base-router" # Name derived from the deployment prefix
  network = local.pvc_base_vpc.self_link
  region  = var.region

  # Apply common asset tags as labels to the router.
  # labels = var.asset_tags # Unsupported argument
}

# Cloud NAT for private subnet outbound internet access
resource "google_compute_router_nat" "pvc_base" {
  name                               = "${var.prefix}-pvc-base-nat"        # Name derived from the deployment prefix
  router                             = google_compute_router.pvc_base.name # References the created router name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"           # Automatically allocates public IP addresses for NAT
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS" # Specifies that NAT applies to listed subnets

  # Use a dynamic block to iterate over the created private subnets
  # and correctly reference their 'self_link' for the NAT configuration.
  dynamic "subnetwork" {
    for_each = google_compute_subnetwork.pvc_base_private
    content {
      # The 'name' attribute for subnetwork in router_nat expects the self_link or ID
      name                    = subnetwork.value.self_link
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # NAT all IP ranges within these subnets
    }
  }

  # Apply common asset tags as labels to the NAT gateway.
  # labels = var.asset_tags # Unsupported argument
}

# Firewall rule for ACME TLS challenge (HTTP 80)
# This rule is specifically designed to allow inbound HTTP traffic from any IP address (0.0.0.0/0)
# to instances that are tagged with a specific target tag. This target tag
# should be applied to your load balancers or ingress controllers that need to
# respond to ACME HTTP-01 challenges (e.g., for Let's Encrypt certificates).
resource "google_compute_firewall" "acme_tls" {
  name    = "${var.prefix}-pvc-base-acme-tls" # Name derived from the deployment prefix
  network = local.pvc_base_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"] # Allow HTTP traffic on port 80
  }

  source_ranges = ["0.0.0.0/0"] # Allow from any IP address (internet)
  # IMPORTANT: This rule is restricted to specific instances using 'target_tags'.
  # Ensure you apply a tag like "${var.prefix}-acme-challenge-handler" to VMs/LBs
  # that are intended to handle these challenges.
  target_tags = ["${var.prefix}-acme-challenge-handler"]

  description = "Allow ACME http-01 challenge to designated nodes (e.g., LBs, ingress controllers)."

  # Apply common asset tags as labels to the firewall rule.
  # labels = var.asset_tags # Unsupported argument
}
