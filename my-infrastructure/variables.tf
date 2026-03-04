variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "team3"
}

variable "rg_name" {
  description = "Name of the Azure Resource Group (auto-generated if not set)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "uksouth"
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
