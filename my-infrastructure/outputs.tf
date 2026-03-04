output "resource_group_name" {
  description = "The name of the Azure resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the Azure resource group"
  value       = module.resource_group.resource_group_id
}

output "resource_group_location" {
  description = "The location of the Azure resource group"
  value       = module.resource_group.resource_group_location
}

# Storage Account Outputs
output "storage_account_name" {
  description = "The name of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  description = "The ID of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.id
}

output "storage_container_name" {
  description = "The name of the storage container for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}
