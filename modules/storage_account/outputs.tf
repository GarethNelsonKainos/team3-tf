output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage_account.name
}

output "resource_group_name" {
  description = "The name of the resource group the storage account is in."
  value       = azurerm_storage_account.storage_account.resource_group_name
}

output "location" {
  description = "The Azure region where the storage account is located."
  value       = azurerm_storage_account.storage_account.location
}

output "account_tier" {
  description = "The account tier of the storage account."
  value       = azurerm_storage_account.storage_account.account_tier
}

output "account_replication_type" {
  description = "The replication type of the storage account."
  value       = azurerm_storage_account.storage_account.account_replication_type
}