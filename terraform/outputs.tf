output "chromadb_vm_private_ip_address" {
  value = azurerm_network_interface.chromanic.private_ip_address
}

output "chromadb_vm_public_ip" {
  value = azurerm_public_ip.chromadb_ip.ip_address
}

output "key_vault_name" {
  value = azurerm_key_vault.ltsafsecrets.name
}

output "app_gateway_url" {
  value = "http://${azurerm_public_ip.appgw_public_ip.ip_address}:8501"
  description = "Public URL to access the Streamlit frontend via App Gateway"
}
