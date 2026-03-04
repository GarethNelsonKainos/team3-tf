output "resource_group_name" {
  description = "The name of the Azure resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The ID of the Azure resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_location" {
  description = "The location of the Azure resource group"
  value       = azurerm_resource_group.rg.location
}
