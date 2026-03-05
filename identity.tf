resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "id-academy-${var.dev_environment}"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
}