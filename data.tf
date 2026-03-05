data "azurerm_key_vault_secret" "database_url" {
  name         = "DATABASE-URL"
  key_vault_id = azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "jwt_secret" {
  name         = "JWT-SECRET"
  key_vault_id = azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "postgres_password" {
  name         = "POSTGRES-PASSWORD"
  key_vault_id = azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "aws_access_key_id" {
  name         = "AWS-ACCESS-KEY-ID"
  key_vault_id = azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "aws_secret_access_key" {
  name         = "AWS-SECRET-ACCESS-KEY"
  key_vault_id = azurerm_key_vault.main.id
}