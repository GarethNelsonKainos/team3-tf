variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
  default     = "team3-rg"
}

variable "storage_account_name" {
  description = "The name of the storage account to create."
  type        = string
  default     = "team3appsa"
}

variable "location" {
  description = "The Azure region where the resource group will be created."
  type        = string
  default     = "UK South"
}

variable "dev_environment" {
  description = "The dev environment for which the infrastructure is being created."
  type        = string
  default     = "dev"
}

variable "prod_environment" {
  description = "The prod environment for which the infrastructure is being created."
  type        = string
  default     = "prod"
}

variable "account_tier" {
  description = "The account tier for the storage account."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type for the storage account."
  type        = string
  default     = "LRS"
}