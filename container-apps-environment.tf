resource "azurerm_container_app_environment" "container_app_environment" {
  name                = "cae-academy-${var.dev_environment}"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location

  tags = {
    environment = var.dev_environment
    managed_by  = "terraform"
  }
}