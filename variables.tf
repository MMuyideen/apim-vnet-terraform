variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "morex-resource-group"
}

variable "location" {
  description = "The Azure region for resources"
  type        = string
  default     = "UK South"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "morex-vnet"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "List of subnets to create in the virtual network"
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = [
    {
      name           = "apim-subnet"
      address_prefix = "10.0.1.0/24"
    },
    {
      name           = "vm-subnet"
      address_prefix = "10.0.2.0/24"
    }
  ]
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
  default     = "shared-nsg"
}

variable "nsg_inbound_rules" {
  description = "Inbound rules for the network security group"
  type = list(object({
    name                       = string
    priority                   = number
    destination_port_range     = string
    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
    access                     = optional(string, "Allow")
    protocol                   = optional(string, "Tcp")
  }))
  default = [
    {
      name                  = "allow-rdp"
      priority              = 100
      destination_port_range = "3389"
    },
    {
      name                       = "allow-apim-service-tag"
      priority                   = 200
      destination_port_range     = "3443"
      source_address_prefix      = "ApiManagement"
      destination_address_prefix = "VirtualNetwork"
    }
  ]
}

variable "apim_name" {
  description = "The name of the API Management instance"
  type        = string
  default     = "deen-apim-pes"
}

variable "apim_publisher_name" {
  description = "The name of the APIM publisher"
  type        = string
  default     = "morex-publisher"
}

variable "apim_publisher_email" {
  description = "The email of the APIM publisher"
  type        = string
  default     = "publisher@morex.com"
}

variable "apim_sku_name" {
  description = "The SKU of the APIM instance"
  type        = string
  default     = "Developer_1"
}

variable "apim_virtual_network_type" {
  description = "The virtual network type for APIM (None, External, or Internal)"
  type        = string
  default     = "Internal"
}

variable "apim_api_name" {
  description = "The name of the API to create in APIM"
  type        = string
  default     = "swagger-petstore-openapi-3-0"
}

variable "apim_api_display_name" {
  description = "The display name of the API"
  type        = string
  default     = "Swagger Petstore - OpenAPI 3.0"
}

variable "apim_api_path" {
  description = "The path for the API"
  type        = string
  default     = "petstore"
}

variable "apim_api_swagger_url" {
  description = "The URL to the Swagger/OpenAPI specification"
  type        = string
  default     = "https://petstore3.swagger.io/api/v3/openapi.json"
}

variable "dns_zone_name" {
  description = "The name of the private DNS zone"
  type        = string
  default     = "azure-api.net"
}

variable "vm_public_ip_name" {
  description = "The name of the public IP for the VM"
  type        = string
  default     = "vm-public-ip"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default     = "morex-vm"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B2ms"
}

variable "vm_admin_username" {
  description = "The admin username for the VM"
  type        = string
  default     = "adminuser"
}

variable "vm_source_image_reference" {
  description = "The source image reference for the VM"
  type = object({
    publisher = optional(string)
    offer     = optional(string)
    sku       = optional(string)
    version   = optional(string)
  })
  default = {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-pro"
    version   = "latest"
  }
}

variable "nic_name" {
  description = "The name of the network interface"
  type        = string
  default     = "vm-nic"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
