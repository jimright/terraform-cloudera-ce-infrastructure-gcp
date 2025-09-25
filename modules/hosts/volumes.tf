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

# File: tf_cluster_gcp/modules/hosts/volumes.tf

locals {

  volumes = flatten([
    for idx in range(0, var.quantity) :
    [
      for node_vol in coalesce(var.volumes, []) :
      {
        node_index = idx
        node       = google_compute_instance.pvc_base[idx]
        name       = var.quantity == 0 ? var.name : format("%s-%02d", var.name, idx + 1)
        zone       = google_compute_instance.pvc_base[idx].zone
        device     = node_vol.device_name
        mount      = node_vol.mount
        size       = node_vol.volume_size
        type       = node_vol.volume_type
        labels     = node_vol.labels
      }
    ]
  ])

}

resource "google_compute_disk" "inventory" {
  for_each = { for idx, volume in local.volumes : idx => volume }

  project = var.project_id
  name    = "${each.value.name}-${replace(each.value.mount, "/", "")}"
  type    = each.value.type
  size    = each.value.size
  zone    = each.value.node.zone
  labels = merge(
    each.value.labels,
    {
      # Sanitize labels in gcp, replace / for "mount"
      "name"   = replace(lower(each.value.name), "[^a-z0-9_-]", "_"),
      "mount"  = replace(lower(each.value.mount), "/", ""),
      "device" = replace(lower(each.value.device), "[^a-z0-9_-]", "_")
    }
  )
}

resource "google_compute_attached_disk" "inventory" {
  for_each = { for idx, volume in local.volumes : idx => volume }

  instance    = each.value.node.id
  disk        = google_compute_disk.inventory[each.key].id
  device_name = each.value.device
}

locals {

  # Details for all attached volumes
  attached_volumes = [
    for idx, volume in local.volumes :
    {
      "instance" = google_compute_instance.pvc_base[index(local.volumes, volume)].name
      "vol_name" = google_compute_disk.inventory[index(local.volumes, volume)].name
      "vol_id"   = google_compute_disk.inventory[index(local.volumes, volume)].id
      "device"   = "/dev/${volume.device}"
      "mount"    = volume.mount
    }
    if length(google_compute_disk.inventory) > 0
  ]

  # Attached volume details grouped by instance
  attached_volumes_by_instance = {
    for vol in local.attached_volumes :
    vol.instance =>
    {
      vol_name = vol.vol_name
      vol_id   = vol.vol_id
      device   = vol.device
      mount    = vol.mount
    }...
  }

}
