output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "The Azure region of the resource group."
  value       = azurerm_resource_group.rg.location
}

output "environment" {
  description = "The environment tag applied to the resource group."
  value       = azurerm_resource_group.rg.tags.environment
}
