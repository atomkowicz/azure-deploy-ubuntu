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
  default     = "someuser"
}

variable "password" {
  description = "Password configurable by the user"
  default     = "somepass1234"
}

variable "environment" {
  description = "Environment tag, e.g. prod, dev"
  default     = "dev"
}

variable "vms_count" {
  description = "The number of virtual machines"
  type        = number
  default     = 2
}