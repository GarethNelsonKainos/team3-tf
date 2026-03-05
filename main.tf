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

resource "azurerm_key_vault_access_policy" "kv_group_reader" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.key_vault_reader_group_object_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_user_assigned_identity" "main" {
  name                = var.managed_identity_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_container_app_environment" "frontend" {
  name                = "frontend-environment"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_app" "frontend" {
  name                         = "frontend"
  container_app_environment_id = azurerm_container_app_environment.frontend.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.main.id
  }

  template {
    container {
      name   = "frontend"
      image  = var.frontend_image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "azurerm_container_app_environment" "backend" {
  name                = "backend-environment"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_app" "backend" {
  name                         = "backend"
  container_app_environment_id = azurerm_container_app_environment.backend.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.main.id
  }

  template {
    container {
      name   = "backend"
      image  = var.backend_image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}

resource "azurerm_container_registry" "main" {
  name                = var.container_registry_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  sku                 = var.container_registry_sku
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}