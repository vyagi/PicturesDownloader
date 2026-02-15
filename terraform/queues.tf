resource "azurerm_servicebus_namespace" "main_service_bus" {
  name                = local.service_bus_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "requests" {
  name                                 = "requests"
  namespace_id                         = azurerm_servicebus_namespace.main_service_bus.id
  max_delivery_count                   = 10
  default_message_ttl                  = "PT1M"
  dead_lettering_on_message_expiration = true
}