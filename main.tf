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

  enable_rbac_authorization  = true
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  purge_protection_enabled   = var.key_vault_purge_protection_enabled

  tags = merge(
    var.tags,
    {
      purpose = "application-secrets"
    }
  )
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "kv_reader_assignment" {
  scope              = azurerm_key_vault.main.id
  role_definition_id = data.azurerm_role_definition.kv_secrets_reader.id
  principal_id       = data.azuread_group.kv_users.id
  depends_on         = [azurerm_key_vault.main]
resource "azurerm_key_vault_access_policy" "kv_group_reader" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.key_vault_reader_group_object_id

  secret_permissions = ["Get", "List"]
}