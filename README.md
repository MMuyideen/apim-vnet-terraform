# Azure APIM in Internal VNet and Windows VM Terraform Deployment

This repository contains Terraform code to deploy a secure Azure environment with the following resources:

- **Resource Group**
- **Virtual Network (VNet)**
- **Subnets** for APIM, VM, and Private Endpoints (optional)
- **Network Security Group (NSG)** with rules for RDP and APIM management
- **API Management (APIM)** in internal VNet mode
- **Windows 11 Virtual Machine** with public IP for testing
- **Private DNS Zones** for APIM

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.0+
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- An Azure subscription

## Usage

1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd apim
   ```

2. **Configure your variables:**
   - Edit `terraform.tfvars` with your Azure subscription ID and a secure VM admin password.

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Validate the configuration:**
   ```bash
   terraform validate
   ```

5. **Plan the deployment:**
   ```bash
   terraform plan
   ```

6. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Outputs

- The public IP address of the Windows VM will be displayed after deployment.

## File Structure

- `main.tf` – Main resource definitions
- `variable.tf` – Input variables
- `terraform.tfvars` – Variable values (do not commit secrets)
- `providers.tf` – Provider configuration
- `backend.tf` – Remote state backend configuration
- `output.tf` – Output values

## Security Notes

- The VM admin password is stored as a sensitive variable. Do **not** commit secrets to version control.
- NSG rules are configured to allow RDP (3389) from any source. Restrict this in production.
- APIM is deployed in internal mode for secure, private access.

## Clean Up

To remove all resources created by this deployment:

```bash
terraform destroy
```

## References

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure API Management Documentation](https://docs.microsoft.com/en-us/azure/api-management/)
-