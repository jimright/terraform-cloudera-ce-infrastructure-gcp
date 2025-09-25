<!-- BEGIN_TF_DOCS -->
# Terraform Module for Hosts on GCP

The `hosts` module contains resource files to provision and manage GCP compute instances with flexible configuration options for compute resources, storage volumes, and networking. This module is designed for Cloudera on premise infrastructure deployments on GCP IaaS.

## Key Features

* **Flexible Instance Deployment**: Create single instances or multiple numbered instances with customizable naming patterns
* **Multi-Zone Distribution**: Automatically distribute instances across multiple GCP zones for high availability
* **Public and Private IP Management**: Support for ephemeral public IPs, static external IP addresses, or private-only configurations
* **Custom Storage Volumes**: Attach additional persistent disks with configurable size, type, and mount points
* **SSH Key Management**: Automated SSH public key injection for secure instance access
* **Network Tag Support**: Apply network tags for firewall rule targeting and security group management

## Usage

The [examples](./examples) directory has example of using this module:

* `ex01-minimal_inputs` demonstrates how this module can be used to create a number of hosts.

The sample `terraform.tfvars.sample` describes the required inputs for the example.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_attached_disk.inventory](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |
| [google_compute_disk.inventory](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.pvc_base](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Instance base name. If 'quantity' is 0, this is the exact name of the single instance. If 'quantity' > 0, name will be <name>-NN. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID where instances will be created. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The contents of the SSH public key to be added to the instance metadata for SSH access. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet self-links or names to assign instances to. Instances will be distributed across these subnets. Must not be empty if instances are created. | `list(string)` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | GCP zone (e.g., us-central1-a) where instances will be created. | `list(string)` | n/a | yes |
| <a name="input_external_ip_address"></a> [external\_ip\_address](#input\_external\_ip\_address) | Optional: A pre-allocated static external IP address to assign to the instance. If provided, 'public\_ip' should typically be false as this takes precedence. | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | Self-link the image (e.g., 'debian-cloud', 'centos-cloud', or your custom project). | `any` | `null` | no |
| <a name="input_image_os_user"></a> [image\_os\_user](#input\_image\_os\_user) | GCP image default user. (e.g., 'cloud-user' for rhel-8) | `string` | `"cloud-user"` | no |
| <a name="input_instance_labels"></a> [instance\_labels](#input\_instance\_labels) | Map of labels (key-value pairs) to apply to the compute instances. | `map(string)` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | GCP machine type (e.g., e2-medium, n1-standard-1). | `string` | `"e2-micro"` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | List of network tags to attach to instances (for firewall rules). | `list(string)` | `[]` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Assign an ephemeral public IP address to the instance's network interface. Set to false if 'external\_ip\_address' is provided. | `bool` | `false` | no |
| <a name="input_quantity"></a> [quantity](#input\_quantity) | Number of instances. If 0 (default), one instance will be created with the exact 'name'. If > 0, 'quantity' instances will be created with numbered names. | `number` | `0` | no |
| <a name="input_root_volume"></a> [root\_volume](#input\_root\_volume) | Root volume configuration for the boot disk. | <pre>object({<br/>    delete_on_termination = optional(bool, true)<br/>    volume_size           = optional(number, 20)<br/>    volume_type           = optional(string, "pd-standard")<br/>  })</pre> | `{}` | no |
| <a name="input_startup_script"></a> [startup\_script](#input\_startup\_script) | Optional startup script (content, not path) to run on instance creation. | `string` | `"#!/bin/bash\nyum makecache >> /var/log/startup_script.log 2>&1\n"` | no |
| <a name="input_subnetwork_project_id"></a> [subnetwork\_project\_id](#input\_subnetwork\_project\_id) | The project ID of the subnetwork. Defaults to var.project\_id if not set (for non-Shared VPC scenarios). | `string` | `""` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | List of additional persistent volumes to create and attach to each instance. | <pre>list(object({<br/>    name_suffix = string<br/>    device_name = string # e.g. "sdb", "sdc" (will be /dev/sdb, /dev/sdc on instance)<br/>    mount       = string<br/>    volume_size = optional(number, 100)<br/>    volume_type = optional(string, "pd-standard")<br/>    labels      = optional(map(string), {})<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_details"></a> [instance\_details](#output\_instance\_details) | A list of detailed information for each created instance. |
| <a name="output_instances"></a> [instances](#output\_instances) | A list of the provisioned GCP compute instance objects. If quantity was 0, this list contains one instance. |
| <a name="output_storage_volumes"></a> [storage\_volumes](#output\_storage\_volumes) | Map of additional storage volumes, keyed by instance ID. Each value is a list of volume details attached to that instance. |
<!-- END_TF_DOCS -->