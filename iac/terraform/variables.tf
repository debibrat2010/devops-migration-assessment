variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "c09dd6ef-0111-4bf0-a0d4-3600979a0c7d"
}

variable "resource_group_name" {
  type        = string
  description = "Single resource group for all assessment resources"
  default     = "rg-migration-assessement"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "southeastasia"
}

variable "environment" {
  type        = string
  description = "Environment label for resource naming (dev or prod)"
  default     = "dev"
}

variable "container_image" {
  type        = string
  description = "Container image for PetClinic App Service until pipeline pushes to ACR"
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "tags" {
  type = map(string)
  default = {
    project   = "devops-migration-assessment"
    managedBy = "terraform"
  }
}
