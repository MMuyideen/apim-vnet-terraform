# Resource Group
resource "azurerm_resource_group" "morex" {
  name     = "morex-resource-group"
  location = "Central US"
}

# Virtual Network
resource "azurerm_virtual_network" "morex_vnet" {
  name                = "morex-vnet"
  location            = azurerm_resource_group.morex.location
  resource_group_name = azurerm_resource_group.morex.name
  address_space       = ["10.0.0.0/16"]
}

# Shared Subnet for APIM and Virtual Machine
resource "azurerm_subnet" "apim-snet" {
  name                 = "apim-subnet"
  resource_group_name  = azurerm_resource_group.morex.name
  virtual_network_name = azurerm_virtual_network.morex_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_subnet" "vm-snet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.morex.name
  virtual_network_name = azurerm_virtual_network.morex_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}

# Subnet for Private Endpoint (note that APIM cannot have a private endpoint and be in a VNet at the same time)
# Uncomment the following block if you need a dedicated subnet for private endpoints
# resource "azurerm_subnet" "private_endpoint_subnet" {
#   name                 = "private-endpoint-subnet"
#   resource_group_name  = azurerm_resource_group.morex.name
#   virtual_network_name = azurerm_virtual_network.morex_vnet.name
#   address_prefixes     = ["10.0.3.0/24"]

#   delegation {
#     name = "Microsoft.Web/serverFarms"
#     service_delegation {
#       name = "Microsoft.Web/serverFarms"

#     }
#   }

# }

# Network Security Group
resource "azurerm_network_security_group" "shared_nsg" {
  name                = "shared-nsg"
  location            = azurerm_resource_group.morex.location
  resource_group_name = azurerm_resource_group.morex.name

  # Allow RDP
  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow APIM Management Endpoint (Required for APIM to in a VNet)
  security_rule {
    name                       = "allow-apim-service-tag"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }
}

# Associate NSG with Apim Subnet
resource "azurerm_subnet_network_security_group_association" "apim-subnet-nsg" {
  subnet_id                 = azurerm_subnet.apim-snet.id
  network_security_group_id = azurerm_network_security_group.shared_nsg.id
}

# Associate NSG with VM Subnet
resource "azurerm_subnet_network_security_group_association" "vm-subnet-nsg" {
  subnet_id                 = azurerm_subnet.vm-snet.id
  network_security_group_id = azurerm_network_security_group.shared_nsg.id
}

# API Management (APIM) in Internal VNet
resource "azurerm_api_management" "morex_apim" {
  name                = "deen-apim-pes"
  location            = azurerm_resource_group.morex.location
  resource_group_name = azurerm_resource_group.morex.name
  publisher_name      = "morex-publisher"
  publisher_email     = "publisher@morex.com"
  sku_name            = "Developer_1"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim-snet.id
  }
  virtual_network_type = "Internal"


  depends_on = [
    azurerm_subnet_network_security_group_association.apim-subnet-nsg,
    azurerm_network_security_group.shared_nsg
  ]
}

resource "azurerm_api_management_api" "api" {
  name                = "swagger-petstore-openapi-3-0"
  resource_group_name = azurerm_resource_group.morex.name
  api_management_name = azurerm_api_management.morex_apim.name
  revision            = "1"
  display_name        = "Swagger Petstore - OpenAPI 3.0"
  path                = "petstore"
  protocols           = ["https"]
  import {
    content_format = "swagger-link-json"
    content_value  = "https://petstore3.swagger.io/api/v3/openapi.json"
  }
}

# Private DNS Zone for APIM
resource "azurerm_private_dns_zone" "apim_dns_zone" {
  name                = "azure-api.net"
  resource_group_name = azurerm_resource_group.morex.name
  depends_on          = [azurerm_api_management.morex_apim]
}

# Virtual Network Link for DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "apim_dns_link" {
  name                  = "morex-apim-link"
  resource_group_name   = azurerm_resource_group.morex.name
  private_dns_zone_name = azurerm_private_dns_zone.apim_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.morex_vnet.id
}

# DNS Record for APIM Gateway
resource "azurerm_private_dns_a_record" "apim_gateway_record" {
  name                = azurerm_api_management.morex_apim.name
  zone_name           = azurerm_private_dns_zone.apim_dns_zone.name
  resource_group_name = azurerm_resource_group.morex.name
  ttl                 = 300
  records             = azurerm_api_management.morex_apim.private_ip_addresses
}

# DNS Record for APIM Developer Portal
resource "azurerm_private_dns_a_record" "apim_portal_record" {
  name                = azurerm_api_management.morex_apim.developer_portal_url
  zone_name           = azurerm_private_dns_zone.apim_dns_zone.name
  resource_group_name = azurerm_resource_group.morex.name
  ttl                 = 300
  records             = azurerm_api_management.morex_apim.private_ip_addresses
}

# Public IP for Virtual Machine
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.morex.location
  resource_group_name = azurerm_resource_group.morex.name
  allocation_method   = "Static"
}

# Network Interface for Virtual Machine
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.morex.location
  resource_group_name = azurerm_resource_group.morex.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Windows 11 Virtual Machine
resource "azurerm_windows_virtual_machine" "morex_vm" {
  name                = "morex-vm"
  location            = azurerm_resource_group.morex.location
  resource_group_name = azurerm_resource_group.morex.name
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-pro"
    version   = "latest"
  }

}







