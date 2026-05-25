# Module E — Assessment platform (single resource group, Southeast Asia)
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "mig-${var.environment}-${random_id.suffix.hex}"
  # ACR: 5–50 alphanumeric only
  acr_name = "acrmig${var.environment}${random_id.suffix.hex}"
  # Key Vault: 3–24 chars, alphanumeric
  kv_name = "kvmig${var.environment}${random_id.suffix.hex}"
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.tags, { environment = var.environment })
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "${local.name_prefix}-appi"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_key_vault" "kv" {
  name                       = local.kv_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
  tags                       = var.tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "${local.name_prefix}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.tags
}

resource "azurerm_linux_web_app" "petclinic" {
  name                = "${local.name_prefix}-petclinic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on         = true
    health_check_path = "/actuator/health"

    # Placeholder image until pipeline pushes PetClinic to ACR
    application_stack {
      docker_image_name   = "azuredocs/containerapps-helloworld:latest"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appi.connection_string
    SPRING_PROFILES_ACTIVE                = "default"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name,
    ]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.petclinic.identity[0].principal_id
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.petclinic.identity[0].principal_id
}
