# Copyright 2025 Cloudera, Inc. (Assumed year from original main.tf)
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

# ------- SSH -------
locals {
  effective_instance_count = var.quantity == 0 ? 1 : var.quantity
  ssh_public_key           = trimspace(var.ssh_public_key)
}

resource "google_compute_instance" "pvc_base" {
  count   = local.effective_instance_count
  project = var.project_id
  # Instance Naming:
  # If var.quantity is 0 (meaning 1 instance is created via effective_instance_count), name is var.name.
  # Otherwise (var.quantity is 1 or more), name is formatted.
  name         = var.quantity == 0 ? var.name : format("%s-%02d", var.name, count.index + 1)
  machine_type = var.instance_type
  zone         = var.zones[count.index % length(var.zones)]

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = var.image.self_link
      size  = var.root_volume.volume_size
      type  = var.root_volume.volume_type
    }
    auto_delete = var.root_volume.delete_on_termination
  }

  network_interface {
    subnetwork         = var.subnet_ids[count.index % length(var.subnet_ids)]
    subnetwork_project = var.subnetwork_project_id != "" ? var.subnetwork_project_id : var.project_id

    dynamic "access_config" {
      # Create access config if public_ip is true OR if an external_ip_address is provided
      for_each = var.public_ip || var.external_ip_address != null ? [1] : []
      content {
        # If external_ip_address is provided, use it; otherwise, let GCP assign an ephemeral one
        nat_ip = var.external_ip_address != null ? var.external_ip_address : null
      }
    }
  }

  metadata = {
    ssh-keys = "${var.image_os_user}:${local.ssh_public_key}"
  }

  metadata_startup_script = var.startup_script

  labels = var.instance_labels

  allow_stopping_for_update = true
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}
