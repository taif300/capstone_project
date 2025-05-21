resource "random_integer" "rand_db" {
  min = 10000
  max = 99999
}

resource "azurerm_postgresql_flexible_server" "chatbot_db" {
  name = "chatbot-postgres-db-${random_integer.rand_db.result}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  version                = "16"
  zone                   = "1"

  storage_mb             = 32768
  sku_name = "B_Standard_B1ms"
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false

  public_network_access_enabled = true



  tags = {
    Environment = "Dev"
  }

  depends_on = [azurerm_resource_group.rg]
}


resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name      = "AllowAll"
  server_id = azurerm_postgresql_flexible_server.chatbot_db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"

     depends_on = [
    azurerm_postgresql_flexible_server.chatbot_db
  ]
}

