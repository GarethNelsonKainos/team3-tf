# My Infrastructure (Terraform)

This small Terraform project creates an Azure Resource Group.

Prerequisites
- Terraform installed
- Azure CLI logged in (`az login`)

Quick start
```bash
cd my-infrastructure
terraform init
terraform fmt
terraform validate
terraform plan
# when ready:
terraform apply
```

Notes
- Do not commit `terraform.tfstate` or `.terraform/` to source control.
- Use `terraform destroy` to remove created resources.
