variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
  default     = "team3-rg"
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

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (globally unique, 3-24 chars, alphanumeric and hyphens)"
  type        = string
  default     = "team3-key-vault"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key Vault name must be 3-24 characters and contain only letters, numbers, or hyphens."
  }
}

variable "key_vault_sku_name" {
  description = "Key Vault SKU (standard or premium)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], lower(var.key_vault_sku_name))
    error_message = "Key Vault SKU must be standard or premium."
  }
}

variable "key_vault_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted items (7-90)"
  type        = number
  default     = 7

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection on the Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_public_network_access_enabled" {
  description = "Allow public network access to the Key Vault"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}

variable "key_vault_access_group" {
  description = "Group with access to Key Vault"
  type = string
  default = "2026-Tech-Academy"
}