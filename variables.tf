variable "prefix" {
  default = "azure-deploy-ubuntu"
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  default = "North Europe"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "username" {
  description = "Username configurable"
}

variable "password" {
  description = "Password configurable"
}

variable "environment" {
  description = "Environment tag, e.g. prod, dev"
  default     = "dev"
}

variable "number_of_vms" {
  description = "The number of virtual machines"
  type        = number
  default     = 1
}