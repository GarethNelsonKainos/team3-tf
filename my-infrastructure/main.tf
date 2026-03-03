provider "azurerm" {
  features {}
}

module "resource_group" {
  source   = "./modules/resource-group"
  name     = var.rg_name
  location = var.location
  tags = {
    environment = var.environment
    project     = "team3-tf"
  }
}
