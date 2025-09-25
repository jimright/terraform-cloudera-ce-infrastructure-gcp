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
