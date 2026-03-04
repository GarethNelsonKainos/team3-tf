terraform {
  backend "azurerm" {
    resource_group_name  = "team3-tfstate-rg"
    storage_account_name = "team3tfstate26796"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}