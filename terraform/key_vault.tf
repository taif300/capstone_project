
data "azurerm_client_config" "current" {}


resource "random_pet" "kv_random_name" {
  length    = 2
  separator = "-"
}


resource "azurerm_key_vault" "ltsafsecrets" {
  name                        = "mykey-${random_pet.kv_random_name.id}-kv" 
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 30
  purge_protection_enabled    = false
  enable_rbac_authorization = true
  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]


    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Recover",  
      "Purge" 
    ]

    storage_permissions = [
      "Get",
    ]
  }
}


resource "azurerm_key_vault_access_policy" "vmss_access" {
  key_vault_id = azurerm_key_vault.ltsafsecrets.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id

  secret_permissions = [
  "Get",
  "List"
]
  depends_on = [
    azurerm_linux_virtual_machine_scale_set.vmss,
    azurerm_key_vault.ltsafsecrets
  ]
}

resource "azurerm_key_vault_secret" "proj_secrets" {
  for_each = {
    "PROJ-AZURE-STORAGE-CONTAINER" = azurerm_storage_container.example.name
    "PROJ-AZURE-STORAGE-SAS-URL"   = "https://${azurerm_storage_account.example.name}.blob.core.windows.net/${azurerm_storage_container.example.name}?${data.azurerm_storage_account_blob_container_sas.example_sas.sas}"
    "PROJ-CHROMADB-HOST"           = azurerm_network_interface.chromanic.private_ip_address
    "PROJ-CHROMADB-PORT"           = "8000"
    "PROJ-DB-HOST"                 = azurerm_postgresql_flexible_server.chatbot_db.fqdn
    "PROJ-DB-NAME"                 = "project"
    "PROJ-DB-PASSWORD"             = var.db_admin_password
    "PROJ-DB-PORT"                 = "5432"
    "PROJ-DB-USER"                 = var.db_admin_username
    "PROJ-OPENAI-API-KEY"          = var.openai_api_key
  }

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.ltsafsecrets.id

  depends_on = [
    azurerm_key_vault_access_policy.vmss_access,
    azurerm_public_ip.chromadb_ip,
    azurerm_postgresql_flexible_server.chatbot_db,
    data.azurerm_storage_account_blob_container_sas.example_sas
  ]
      lifecycle {
    prevent_destroy = false 
  }
}



resource "azurerm_role_assignment" "vmss_kv_secrets_user" {
  scope                = azurerm_key_vault.ltsafsecrets.id
  role_definition_name = "Key Vault Secrets User"
  principal_id = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id

  depends_on = [
  azurerm_linux_virtual_machine_scale_set.vmss,
  azurerm_key_vault.ltsafsecrets
]
}




resource "azurerm_role_assignment" "user_kv_admin" {
  scope                = azurerm_key_vault.ltsafsecrets.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

