terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.56.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "LabCommon"
    storage_account_name = "common012345"
    container_name       = "terraform"
    key                  = "lab11.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "common_service_plan" {
  name                = "commonserviceplan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Windows"
  sku_name            = "B3"
}

resource "azurerm_windows_function_app" "api" {
  name                = local.function_app_api_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  service_plan_id = azurerm_service_plan.common_service_plan.id

  storage_account_name       = azurerm_storage_account.technical_storage_account.name
  storage_account_access_key = azurerm_storage_account.technical_storage_account.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    AzureWebJobsStorage                   = azurerm_storage_account.technical_storage_account.primary_connection_string
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.api_app_insights.connection_string,
    FUNCTIONS_EXTENSION_VERSION           = "~4",
    FUNCTIONS_WORKER_RUNTIME              = "dotnet-isolated",
    SERVICE_BUS_CONNECTION_STRING         = azurerm_servicebus_namespace.main_service_bus.default_primary_connection_string
    WEBSITE_RUN_FROM_PACKAGE              = "1"
  }

  site_config {
    always_on = true
  }
}

resource "azurerm_windows_function_app" "downloader" {
  name                = local.function_app_downloader_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  service_plan_id = azurerm_service_plan.common_service_plan.id

  storage_account_name       = azurerm_storage_account.technical_storage_account.name
  storage_account_access_key = azurerm_storage_account.technical_storage_account.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    AzureWebJobsStorage                   = azurerm_storage_account.technical_storage_account.primary_connection_string
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.downloader_app_insights.connection_string
    FUNCTIONS_EXTENSION_VERSION           = "~4",
    FUNCTIONS_WORKER_RUNTIME              = "dotnet-isolated",
    WEBSITE_RUN_FROM_PACKAGE              = "1"
    ServiceBus                            = azurerm_servicebus_namespace.main_service_bus.default_primary_connection_string
    STORAGE_ACCOUNT_CONNECTION_STRING     = azurerm_storage_account.storage_account.primary_connection_string
  }

  site_config {
    always_on = true
  }
}

resource "azurerm_application_insights" "api_app_insights" {
  name                = "api-appinsights"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

resource "azurerm_application_insights" "downloader_app_insights" {
  name                = "downloader-appinsights"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}