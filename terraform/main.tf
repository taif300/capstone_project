
locals {
  source_image_id = "/subscriptions/ef99e72b-913d-4166-9cf7-6bf764bd3f5c/resourceGroups/imgae-vmRG/providers/Microsoft.Compute/galleries/myimages/images/chatbot-image/versions/1.0.0"
  }

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "custom-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = 2
  admin_username      = var.vm_admin_username
  disable_password_authentication = true

  source_image_id     = local.source_image_id

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("ssh-keys/terraform-azurevmss.pub")
  }

  identity {
    type = "SystemAssigned"
  }


  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
  name      = "internal"
  subnet_id = azurerm_subnet.main.id
  application_gateway_backend_address_pool_ids = [
    tolist(azurerm_application_gateway.appgw.backend_address_pool)[0].id
     ]
   }

  } 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(templatefile("${path.module}/vmss_script.sh", {
  key_vault_name = azurerm_key_vault.ltsafsecrets.name}))

  upgrade_mode = "Automatic"

    depends_on = [
  azurerm_key_vault.ltsafsecrets,
  azurerm_application_gateway.appgw
  ]
}


