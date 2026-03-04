terraform {
  backend "azurerm" {
    resource_group_name  = "team3-rg"
    storage_account_name = "team3appsa"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc = true
  }
}