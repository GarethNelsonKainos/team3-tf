terraform {
  backend "azurerm" {
    resource_group_name  = "tom_azure_rg"
    storage_account_name = "kainostomtfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc = true
  }
}