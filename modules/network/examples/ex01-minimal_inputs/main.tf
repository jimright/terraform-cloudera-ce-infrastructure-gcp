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

}

module "ex01_hosts" {
  source = "../.."

  project_id      = var.project_id
  region          = var.region
  zones           = local.zones
  vpc_name        = "${var.prefix}-pvc-base"
  vpc_exists      = false
  prefix          = var.prefix
  base_cidr_block = var.vpc_cidr

  public_subnets  = var.public_subnets_config
  private_subnets = var.private_subnets_config

  asset_tags = local.asset_tags

}
