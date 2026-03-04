# Backend Configuration for Azure Storage
# Fill in these values with your Azure Storage Account details
# Usage: terraform init -backend-config="backend.hcl"

resource_group_name  = "team3-resource-group"
storage_account_name = "team3tfstate"
container_name       = "tfstate"
key                  = "terraform.tfstate"
