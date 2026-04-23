# Example Terraform variables - DO NOT commit sensitive values to git
# Copy this file to terraform.tfvars and fill in your values
# For CI/CD pipelines, use GitHub Secrets to inject TF_VAR_* environment variables

subscription_id = "9ef1d8ba-588d-4789-8ce1-556bc6927d01"

# IMPORTANT: The admin_password should NOT be committed to git
# Instead, set it via GitHub Secret: ADMIN_PASSWORD
# In GitHub Actions, use: export TF_VAR_admin_password=${{ secrets.ADMIN_PASSWORD }}
# admin_password = "Your-Secure-Password-Here"

resource_group_name = "morex-resource-group"
location            = "UK South"

vnet_name         = "morex-vnet"
vnet_address_space = ["10.0.0.0/16"]

subnets = [
  {
    name           = "apim-subnet"
    address_prefix = "10.0.1.0/24"
  },
  {
    name           = "vm-subnet"
    address_prefix = "10.0.2.0/24"
  }
]

nsg_name = "shared-nsg"

apim_name               = "deen-apim-pes"
apim_publisher_name     = "morex-publisher"
apim_publisher_email    = "publisher@morex.com"
apim_sku_name           = "Developer_1"
apim_virtual_network_type = "Internal"

apim_api_name         = "swagger-petstore-openapi-3-0"
apim_api_display_name = "Swagger Petstore - OpenAPI 3.0"
apim_api_path         = "petstore"
apim_api_swagger_url  = "https://petstore3.swagger.io/api/v3/openapi.json"

dns_zone_name = "azure-api.net"

vm_name              = "morex-vm"
vm_size              = "Standard_B2ms"
vm_admin_username    = "adminuser"
vm_public_ip_name    = "vm-public-ip"
nic_name             = "vm-nic"

# Tags to apply to all resources
tags = {
  Environment = "Dev"
  Project     = "APIM-Internal-VNet"
  ManagedBy   = "Terraform"
}
