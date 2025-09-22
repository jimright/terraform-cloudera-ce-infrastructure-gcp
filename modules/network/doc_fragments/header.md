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
