# azure-deploy-ubuntu
Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
Traning project from Udacity's 'DevOps Engineer for Microsoft Azure'.
Repository consists of Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

IaaS:

1. Policy to require tags (deny policy type - if the conditions are not meet the resource will not be created)
2. Templete for Ubuntu VM (Packer)
3. Resource group
4. Load balancer
5. Virtual Network
6. Subnet with configurable count of virtual machines that will be build with Packer template
7. Network security group
8. Public IP address

### Getting Started
1. Clone this repository
2. Create your infrastructure as code
3. Set environmental variables: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID

```
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
export ARM_SUBSCRIPTION_ID=your_subscription_id
```

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### Creating infrastructure as code

1. Create Policy definition and assignment that ensures all indexed resources in your subscription have tags and deny deployment if they do not.

```
az login
az policy definition create --name 'tagging-policy' --display-name 'Enforces a required tag and its value on resources' --description 'Ensures all indexed resources have tags and deny deployment if they do not' --mode Indexed --rules 'policy.json'

az policy assignment create --policy 'tagging-policy' --name 'tagging-policy'
```

2. create resource group

```
az group create --name azure-deploy-ubuntu-resource-group --location northeurope
```

3. Creating a Packer template

```
packer build server.json
az image list
az image delete -g ddd-resource-group -n myIMage
```

4. Creating a Terraform template
```
terraform init
terraform plan -out solution.plan
```
5. Deploying the infrastructure

```
terraform apply
terraform show
terraform destroy
```

