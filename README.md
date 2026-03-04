# team3-tf
Team 3 deployment terraform Feb/March 2026

## Terraform backend recovery (Azure)

This project uses an Azure Storage backend for Terraform state. The backend storage account must be separate from resources managed by this same Terraform configuration.

Backend config is in `backend.tf` and uses:
- Resource Group: `tom_azure_rg`
- Storage Account: `kainostomtfstate`
- Container: `tfstate`
- Key: `terraform.tfstate`

If backend access fails (`Error retrieving keys ... 404`), recreate backend infra:

```bash
az login

az group create \
	--name tom_azure_rg \
	--location "uksouth"

az storage account create \
	--name kainostomtfstate \
	--resource-group tom_azure_rg \
	--location "uksouth" \
	--sku Standard_LRS \
	--kind StorageV2

az storage container create \
	--name tfstate \
	--account-name kainostomtfstate \
	--auth-mode login
```

Then reinitialize Terraform against the backend:

```bash
terraform init -reconfigure
terraform plan -var-file="dev.tfvars"
```
