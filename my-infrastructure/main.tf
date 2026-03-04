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

# Resource Group Module
module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project_name        = var.project_name
  tags                = var.tags
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(
    var.tags,
    {
      purpose = "terraform-state"
    }
  )
}

# Storage Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                  = var.storage_container_name
  storage_account_name    = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
