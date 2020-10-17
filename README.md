# azure-deploy-ubuntu
Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
Traning project from Udacity's 'DevOps Engineer for Microsoft Azure'.
Repository consists of Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

IaaS:

1. Policy to require tags (deny policy type - if the conditions are not meet the resource will not be created)
2. Templete for Ubuntu (Packer)
3. Resource group
4. Load balancer
5. Virtual Network
6. Subnet with configurable count of virtual machines that will be build with Packer template

### Getting Started
1. Clone this repository
2. Create your infrastructure as code

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### Creating infrastructure as code

1. Create Policy that ensures all indexed resources in your subscription have tags and deny deployment if they do not.


2. Creating a Packer template
3. Creating a Terraform template
4. Deploying the infrastructure

### Output
**Your words here**

