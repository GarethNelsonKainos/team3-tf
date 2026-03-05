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

output "frontend_url" {
  description = "Public URL of the frontend application"
  value       = "https://${azurerm_container_app.frontend.ingress[0].fqdn}"
}

output "backend_fqdn" {
  description = "Internal FQDN of the backend"
  value       = azurerm_container_app.backend.ingress[0].fqdn
}

output "postgres_fqdn" {
  description = "Internal FQDN of the postgres database"
  value       = azurerm_container_app.postgres.ingress[0].fqdn
}