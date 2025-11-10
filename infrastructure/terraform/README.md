# Terraform Infrastructure for K8s on Hetzner

## Files
- `main.tf`: Terraform configuration
- `variables.tf`: Input variables
- `outputs.tf`: Output variables
- `terraform.tfvars.example`: Example variable values

## Setup
1. `cp terraform.tfvars.example terraform.tfvars`
2. `terraform init`
3. `terraform plan`
4. `terraform apply --auto-approve`

## Test
- SSH: `ssh root@$(terraform output -raw master_public_ip)`
- IPs: `terraform output`
- Destroy: `terraform destroy --auto-approve`