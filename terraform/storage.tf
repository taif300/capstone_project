
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

resource "azurerm_storage_account" "example" {
  name                     = "chprostor${random_integer.rand.result}" 
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "example" {
  name                  = "chat-history"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "example_sas" {
  connection_string = azurerm_storage_account.example.primary_connection_string

  container_name = azurerm_storage_container.example.name
  start          = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timestamp())
  expiry         = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timeadd(timestamp(), "24h"))

  permissions {
    read   = true
    list   = true
    write  = true
    delete = true
    add    = true
    create = true
  }
}


