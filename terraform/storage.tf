resource "azurerm_storage_account" "technical_storage_account" {
  name                     = local.technical_storage_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "api_technical_container" {
  name                  = "apitechcontainer"
  storage_account_id    = azurerm_storage_account.technical_storage_account.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "downloader_technical_container" {
  name                  = "downtechcontainer"
  storage_account_id    = azurerm_storage_account.technical_storage_account.id
  container_access_type = "private"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = local.data_storage_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "pictures" {
  name                  = "pictures"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}