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
}

module "resource_group" {
  source              = "./modules/resource_groups"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.dev_environment
}

resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku_name

  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  public_network_access_enabled = var.key_vault_public_network_access_enabled

  tags = merge(
    var.tags,
    {
      purpose = "application-secrets"
    }
  )
}

data "azurerm_client_config" "current" {}