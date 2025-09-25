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

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_zones" "available" {
  region = var.region
}

locals {
  # Automatically fetches all zones in the selected region
  zones = data.google_compute_zones.available.names

  asset_tags = {
    for k, v in var.asset_tags :
    # Sanitize both key and value
    lower(replace(replace(replace(replace(k,
      " ", "-"),
      "@", "_"),
      ".", "_"),
      "[^a-z0-9_-]", "-")
    ) =>
    lower(replace(replace(replace(replace(v,
      " ", "-"),
      "@", "_"),
      ".", "_"),
      "[^a-z0-9_-]", "-")
    )
  }

  tag_cluster_node = "${var.prefix}-cluster-node" # General tag for all cluster instances

}

module "ex01_network" {
  source = "../../../network"

  region          = var.region
  vpc_name        = "${var.prefix}-pvc-base"
  vpc_exists      = false
  prefix          = var.prefix
  base_cidr_block = var.vpc_cidr

  public_subnets  = var.public_subnets_config
  private_subnets = var.private_subnets_config

}

module "ex01_nodes" {
  source = "../../"

  project_id      = var.project_id
  zones           = local.zones
  name            = "${var.prefix}-hosts"
  quantity        = 3
  instance_labels = merge(local.asset_tags, { "cloudera-role" = "host" })
  network_tags    = [local.tag_cluster_node]
  image           = google_compute_image.cluster_image
  image_os_user   = var.os_user
  ssh_public_key  = data.tls_public_key.selected.public_key_openssh
  subnet_ids      = [module.ex01_network.created_private_subnets[0].self_link]
  public_ip       = true
  instance_type   = var.instance_type
  root_volume     = { volume_size = var.root_volume_size }
  volumes         = var.data_volumes
}

# ------- SSH Keypair -------
# Generate a new private key if needed
resource "tls_private_key" "generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the generated private key to a file if needed
resource "local_sensitive_file" "pem_file" {
  filename             = "${var.prefix}-ssh-key.pem"
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.generated_private_key.private_key_pem
}

# Load the public key from the correct private key file
data "tls_public_key" "selected" {
  private_key_openssh = tls_private_key.generated_private_key.private_key_openssh
}

# ------- Image with MULTI_IP_SUBNET -------

locals {

  os_major_version = (
    var.os_version != null
    ? regex("^([0-9]+)", var.os_version)[0]
    : "9" # default major is rhel9 if not set
  )

  # os image mappings
  os_family_map = {
    rhel = {
      project       = "rhel-cloud"
      family_prefix = "rhel"
    }
    rocky = {
      project       = "rocky-linux-cloud"
      family_prefix = "rocky-linux"
    }
  }

  gcp_image_project = lookup(
    local.os_family_map,
    var.os_type,
    local.os_family_map["rhel"]
  )["project"]

  gcp_image_family = "${lookup(
    local.os_family_map,
    var.os_type,
    local.os_family_map["rhel"]
  )["family_prefix"]}-${local.os_major_version}"

}

# This data source gets the latest public RHEL/Rocky image to use as a source
data "google_compute_image" "source_image" {
  family  = local.gcp_image_family
  project = local.gcp_image_project
}

# This resource creates your custom image with MULTI_IP_SUBNET to enable /24 mask when
# Postgres reads "samenet" is set in pg_hba.conf
resource "google_compute_image" "cluster_image" {
  name         = "${var.prefix}-${local.gcp_image_family}"
  source_image = data.google_compute_image.source_image.self_link
  family       = local.gcp_image_family

  # Enable MULTI_IP_SUBNET feature
  dynamic "guest_os_features" {
    for_each = toset([
      "MULTI_IP_SUBNET",
      "GVNIC",
      "IDPF",
      "SEV_CAPABLE",
      "SEV_LIVE_MIGRATABLE",
      "SEV_LIVE_MIGRATABLE_V2",
      "SEV_SNP_CAPABLE",
      "TDX_CAPABLE",
      "UEFI_COMPATIBLE",
      "VIRTIO_SCSI_MULTIQUEUE"
    ])
    content {
      type = guest_os_features.value
    }
  }

  labels = merge(local.asset_tags, { "guest-os-features" = "multi-ip-subnet" })

  lifecycle {
    ignore_changes = [source_image]
  }
}