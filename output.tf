output "vm_public_ip" {
  description = "The public IP address of the VM"
  value       = module.public_ip.ip_address
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management instance"
  value       = module.apim.gateway_url
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vnet.subnet_ids
}

output "nsg_id" {
  description = "The ID of the network security group"
  value       = module.nsg.id
}

output "apim_id" {
  description = "The ID of the API Management instance"
  value       = module.apim.id
}

output "apim_name" {
  description = "The name of the API Management instance"
  value       = module.apim.name
}

output "vm_id" {
  description = "The ID of the virtual machine"
  value       = module.vm.id
}

output "vm_admin_username" {
  description = "The admin username of the VM"
  value       = module.vm.admin_username
}

output "dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = module.dns_zone.id
}
