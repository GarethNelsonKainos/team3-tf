variable "rg_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-team3-tf"
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Deployment environment (dev/test/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod"
  }
}
