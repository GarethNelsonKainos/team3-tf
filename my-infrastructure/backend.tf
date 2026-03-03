terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-team3"
    storage_account_name = "team3tfstate1fff4951"
    container_name       = "tfstate"
    key                  = "team3.tfstate"
  }
}
