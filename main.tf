module "vm_password" {
  source          = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/password?ref=main"
  password_length = 20
}

# Resource Group Module
module "resource_group" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/resource-group?ref=main"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network Module with Subnets
module "vnet" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/vnet?ref=main"

  name                = var.vnet_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags                = var.tags
}

# Network Security Group Module
module "nsg" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/nsg?ref=main"

  name                = var.nsg_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  inbound_rules       = var.nsg_inbound_rules
  tags                = var.tags
}

# Associate NSG with APIM Subnet
resource "azurerm_subnet_network_security_group_association" "apim_subnet_nsg" {
  subnet_id                 = module.vnet.subnet_ids["apim-subnet"]
  network_security_group_id = module.nsg.id
}

# Associate NSG with VM Subnet
resource "azurerm_subnet_network_security_group_association" "vm_subnet_nsg" {
  subnet_id                 = module.vnet.subnet_ids["vm-subnet"]
  network_security_group_id = module.nsg.id
}

# API Management Module
module "apim" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/apim?ref=main"

  name                 = var.apim_name
  location             = module.resource_group.location
  resource_group_name  = module.resource_group.name
  publisher_name       = var.apim_publisher_name
  publisher_email      = var.apim_publisher_email
  sku_name             = var.apim_sku_name
  virtual_network_type = var.apim_virtual_network_type
  virtual_network_configuration = {
    subnet_id = module.vnet.subnet_ids["apim-subnet"]
  }
  tags = var.tags

  depends_on = [
    azurerm_subnet_network_security_group_association.apim_subnet_nsg
  ]
}

# APIM API - Swagger Petstore (Inline resource as it's project-specific)
resource "azurerm_api_management_api" "swagger_petstore" {
  name                = var.apim_api_name
  resource_group_name = module.resource_group.name
  api_management_name = module.apim.name
  revision            = "1"
  display_name        = var.apim_api_display_name
  path                = var.apim_api_path
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = var.apim_api_swagger_url
  }
}

# Private DNS Zone Module
module "dns_zone" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/dns-zone?ref=main"

  name                = var.dns_zone_name
  resource_group_name = module.resource_group.name
  virtual_network_id  = module.vnet.id
  dns_records = [
    {
      name    = var.apim_name
      type    = "A"
      ttl     = 300
      records = module.apim.private_ip_addresses
    },
    {
      name    = "${var.apim_name}.developer"
      type    = "A"
      ttl     = 300
      records = module.apim.private_ip_addresses
    }
  ]
  tags = var.tags

  depends_on = [module.apim]
}

# Public IP Module for VM
module "public_ip" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/public-ip?ref=main"

  name                = var.vm_public_ip_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  tags                = var.tags
}

# Network Interface Module for VM
module "nic" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/nic?ref=main"

  name                 = var.nic_name
  location             = module.resource_group.location
  resource_group_name  = module.resource_group.name
  subnet_id            = module.vnet.subnet_ids["vm-subnet"]
  public_ip_address_id = module.public_ip.id
  nsg_id               = module.nsg.id
  tags                 = var.tags

  depends_on = [
    azurerm_subnet_network_security_group_association.vm_subnet_nsg
  ]
}

# Windows Virtual Machine Module
module "vm" {
  source = "git::https://github.com/mmuyideen/terraform-modules-and-pipelines.git//modules/azure/vm?ref=main"

  name                   = var.vm_name
  location               = module.resource_group.location
  resource_group_name    = module.resource_group.name
  size                   = var.vm_size
  admin_username         = var.vm_admin_username
  admin_password         = module.vm_password.password
  os_type                = "windows"
  network_interface_ids  = [module.nic.id]
  source_image_reference = var.vm_source_image_reference
  tags                   = var.tags
}
