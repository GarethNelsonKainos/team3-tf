data "azuread_group" "kv_users" {
  display_name     = var.entra_group_name
  security_enabled = true
}