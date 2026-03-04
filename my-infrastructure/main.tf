provider "azurerm" {
  features {}
}

locals {
  rg_name = var.rg_name != "" ? var.rg_name : "rg-${var.project}-${var.environment}"
}

module "resource_group" {
  source   = "./modules/resource-group"
  name     = local.rg_name
  location = var.location
  tags = {
    environment = var.environment
    project     = var.project
  }
}
