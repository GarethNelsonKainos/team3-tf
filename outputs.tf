output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "location" {
  value = module.resource_group.location
}

output "environment" {
  value = module.resource_group.environment
}

output "key_vault_id" {
  description = "The ID of the Azure Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "The name of the Azure Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault (needed for Container App secret references)"
  value       = azurerm_key_vault.main.vault_uri
}