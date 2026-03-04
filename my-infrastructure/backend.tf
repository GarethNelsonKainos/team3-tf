terraform {
  backend "azurerm" {
    resource_group_name  = "team3-tf-rg"
    storage_account_name = "team3tfstorage"
    container_name       = "tfstate"
    key                  = "team3/terraform.tfstate"
  }
}
