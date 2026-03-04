terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

module "resource_group" {
  source              = "./modules/resource_groups"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.dev_environment
}

module "azurerm_storage_account" {
  source                   = "./modules/storage_account"
  name                     = var.storage_account_name
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}