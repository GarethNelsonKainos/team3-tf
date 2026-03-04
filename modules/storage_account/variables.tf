variable "name" {
    description = "The name of the storage account to create."
    type        = string
    }

variable "resource_group_name" {
    description = "The name of the resource group to create."
    type        = string
    }

variable "location" {
    description = "The Azure region where the resource group will be created."
    type        = string
    }

variable "account_tier" {
    description = "The account tier for the storage account."
    type        = string
    }

variable "account_replication_type" {
    description = "The replication type for the storage account."
    type        = string
    }