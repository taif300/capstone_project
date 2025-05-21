
resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_application_gateway" "appgw" {
  name                = "chatbot-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

 

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "frontend-port"
    port = 8501 
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

backend_address_pool {
  name = "backend-pool"

}

probe {
  name                     = "health-probe"
  protocol                 = "Http"
  path                     = "/"
  interval                 = 30
  timeout                  = 30
  unhealthy_threshold      = 3
  port                     = 8501
  host                     = "127.0.0.1"
}

backend_http_settings {
  name                  = "http-settings"
  cookie_based_affinity = "Disabled"
  port                  = 8501
  protocol              = "Http"
  request_timeout       = 20
  probe_name            = "health-probe"
}


  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 130
  }
}
