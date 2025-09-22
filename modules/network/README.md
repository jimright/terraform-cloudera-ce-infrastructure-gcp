<!-- BEGIN_TF_DOCS -->
# Terraform Module for Hosts on GCP

The `network` module contains resource files for creating and managing GCP networking infrastructure required for Cloudera on premise deployments on GCP IaaS. This module simplifies the process of setting up secure, scalable network topologies with public and private subnets, NAT gateways, route tables, and security groups.

## Key Features

* **VPC Integration**: Works with existing VPCs or creates new ones to extend your current network architecture
* **Flexible Subnet Configuration**: Create custom public and private subnets across multiple availability zones with configurable CIDR blocks
* **Automatic NAT Gateway Setup**: Deploy Cloud NAT and routers to provide secure internet access for private subnet resources
* **Security Group Provisioning**: Create pre-configured firewall rules for intra-cluster communication and ACME TLS challenges
* **Naming Consistency**: Enforces consistent naming conventions with customizable prefixes for all network resources
* **Multi-Zone Support**: Deploy infrastructure across multiple GCP zones with built-in validation and private Google access

## Usage

The [examples](./examples) directory has example of using this module:

* `ex01-minimal_inputs` demonstrates how this module can be used to create a number of hosts.

The sample `terraform.tfvars.sample` describes the required inputs for the example.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.acme_tls](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.pvc_base](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.pvc_base](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.pvc_base](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.pvc_base_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.pvc_base_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_network.existing_pvc_base](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Deployment prefix used for naming all cloud-provider assets created by this module. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID where resources will be deployed. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region where resources will be deployed. | `string` | n/a | yes |
| <a name="input_vpc_exists"></a> [vpc\_exists](#input\_vpc\_exists) | Use existing GCP VPC network. | `bool` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the GCP VPC network into which subnets and other network resources will be deployed. | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Zones in GCP region where resources will be deployed. | `list(string)` | n/a | yes |
| <a name="input_asset_tags"></a> [asset\_tags](#input\_asset\_tags) | Map of labels applied to all cloud-provider assets created by this module. These are GCP resource labels. | `map(string)` | `{}` | no |
| <a name="input_base_cidr_block"></a> [base\_cidr\_block](#input\_base\_cidr\_block) | The base CIDR block (e.g., '10.50.0.0/16') from which default public and private subnet CIDRs will be derived. This variable is required if 'public\_subnets' or 'private\_subnets' are not explicitly provided. | `string` | `"10.10.0.0/16"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of objects defining private subnets. Each object requires 'name', 'cidr', and 'labels' (a map of strings). If this list is empty, a single default private subnet will be created using 'base\_cidr\_block'. | <pre>list(object({<br/>    name   = string<br/>    cidr   = string<br/>    labels = map(string) # Renamed from 'tags' to 'labels' for clarity and consistency with GCP resource labels<br/>  }))</pre> | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of objects defining public subnets. Each object requires 'name', 'cidr', and 'labels' (a map of strings). If this list is empty, a single default public subnet will be created using 'base\_cidr\_block'. | <pre>list(object({<br/>    name   = string<br/>    cidr   = string<br/>    labels = map(string) # Renamed from 'tags' to 'labels' for clarity and consistency with GCP resource labels<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_private_subnets"></a> [created\_private\_subnets](#output\_created\_private\_subnets) | A map containing detailed attributes of the created private subnets, keyed by their internal iteration index. |
| <a name="output_created_public_subnets"></a> [created\_public\_subnets](#output\_created\_public\_subnets) | A map containing detailed attributes of the created public subnets, keyed by their internal iteration index. |
| <a name="output_firewall_acme_rule_name"></a> [firewall\_acme\_rule\_name](#output\_firewall\_acme\_rule\_name) | The name of the firewall rule configured for ACME Directory challenge communication. |
| <a name="output_nat_gateway_name"></a> [nat\_gateway\_name](#output\_nat\_gateway\_name) | The name of the created Cloud NAT gateway resource. |
| <a name="output_region"></a> [region](#output\_region) | The GCP region used for deployment, as provided in the input variables. |
| <a name="output_router_name"></a> [router\_name](#output\_router\_name) | The name of the created Cloud Router resource. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The GCP VPC network name used for deployment, as provided in the input variables. |
| <a name="output_vpc_private_cidr_block"></a> [vpc\_private\_cidr\_block](#output\_vpc\_private\_cidr\_block) | n/a |
| <a name="output_vpc_public_cidr_block"></a> [vpc\_public\_cidr\_block](#output\_vpc\_public\_cidr\_block) | n/a |
| <a name="output_vpc_self_link"></a> [vpc\_self\_link](#output\_vpc\_self\_link) | Self-link of the VPC network fetched by the module. |
<!-- END_TF_DOCS -->