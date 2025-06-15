output "vm_public_ip" {
  description = "The public IP address of the VM"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}