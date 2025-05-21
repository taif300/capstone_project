variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "East US"
}

variable "vm_name" {
  type        = string
  description = "Virtual machine name"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for authentication"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "db_admin_username" {
  type        = string
  description = "Username for PostgreSQL admin"
}

variable "db_admin_password" {
  type        = string
  description = "Password for PostgreSQL admin"
  sensitive   = true
}


#for main.tf



variable "vm_admin_username" {
  type = string
}

variable "vmss_private_ips" {
  description = "List of private IPs of VMSS instances"
  type        = list(string)
  default     = []
}

variable "tenant_id" {
  description = "The tenant ID for the Azure subscription"
  type        = string
}

variable "openai_api_key" {
  description = "openai_api_key"
  type        = string
}




