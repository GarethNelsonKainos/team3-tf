variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "team3-resource-group"

  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "UK South"

  validation {
    condition     = can(regex("^[a-zA-Z\\s]+$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "project_name" {
  description = "Project name for tagging and resource identification"
  type        = string
  default     = "team3"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account for Terraform state (must be globally unique, lowercase alphanumeric only)"
  type        = string
  default     = "team3tfstate"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "storage_container_name" {
  description = "Name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}
