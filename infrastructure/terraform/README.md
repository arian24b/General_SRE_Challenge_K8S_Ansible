# 🚀 Terraform Infrastructure for K8s on ArvanCloud

This Terraform configuration creates a complete Kubernetes cluster infrastructure on ArvanCloud with 3 servers (1 master + configurable workers) and 3 additional volumes for etcd, registry cache, and logs.

## 🏗️ Architecture

- **1 Master Node**: Control plane with etcd, registry, and logs volumes attached
- **Configurable Worker Nodes**: Application runtime nodes (default: 2)
- **3 Volumes**: etcd (configurable size), registry (configurable size), logs (configurable size)

## 📋 Prerequisites

1. **ArvanCloud Account** with API access
2. **Terraform** installed (v1.0+)
3. **ArvanCloud Terraform Provider**:
   ```bash
   git clone https://git.arvancloud.ir/arvancloud/iaas/terraform-provider
   cd terraform-provider
   make install
   ```

## 📁 Files Structure

- `main.tf`: Main Terraform configuration with servers and volumes
- `variables.tf`: Input variables with defaults
- `outputs.tf`: Output values (IPs, IDs, volume IDs)
- `terraform.tfvars.example`: Example configuration values

## 🚀 Quick Start

1. **Copy example configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit your configuration:**
   ```bash
   # Edit terraform.tfvars with your values
   nano terraform.tfvars
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Deploy infrastructure:**
   ```bash
   terraform apply --auto-approve
   ```

## ✅ Current Status

✅ **Configuration Validated**: `terraform validate` passes
✅ **Plan Generated**: `terraform plan` shows 6 resources to create
✅ **Ready for Deployment**: All resource names match ArvanCloud API

### Next Steps

1. **Deploy Infrastructure**:
   ```bash
   terraform apply
   ```

2. **Verify Resources** in ArvanCloud console

3. **Use Outputs** for Ansible configuration:
   - Master server ID: `terraform output master_id`
   - Worker server IDs: `terraform output worker_ids`
   - Volume IDs: `terraform output etcd_volume_id`, etc.

4. **Proceed to Ansible** cluster setup using the provisioned infrastructure

## 🔧 Configuration Options

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `arvan_api_key` | Your ArvanCloud API key | Required |
| `region` | ArvanCloud region | `ir-thr-c2` |
| `os_image` | OS image name | `22.04` |
| `worker_count` | Number of worker nodes | `2` |
| `flavor` | Instance type | `eco-small1` |
| `disk_size` | Root disk size (GB) | `25` |
| `etcd_volume_size` | etcd volume size (GB) | `50` |
| `registry_volume_size` | Registry volume size (GB) | `100` |
| `logs_volume_size` | Logs volume size (GB) | `50` |

### Example terraform.tfvars

```hcl
arvan_api_key        = "apikey your-36-char-api-key"
region               = "ir-thr-c2"
os_image             = "22.04"  # Available: 24.04, 22.04, 20.04, 12, 11, 10
worker_count         = 2
flavor               = "eco-small1"  # Available: eco-small1, g5-small1, eco-small2, etc.
disk_size            = 25
etcd_volume_size     = 50
registry_volume_size = 100
logs_volume_size     = 50
ssh_key_name         = "my-ssh-key"  # Optional: SSH key name in ArvanCloud
```

## 📊 Outputs

After deployment, Terraform will output:

- `master_ip`: ID of the master node (IP available in ArvanCloud console)
- `worker_ips`: List of worker node IDs (IPs available in ArvanCloud console)
- `etcd_volume_id`: ID of the etcd volume
- `registry_volume_id`: ID of the registry volume
- `logs_volume_id`: ID of the logs volume
- `master_status`: Status of the master node
- `worker_statuses`: Statuses of the worker nodes

## 🔍 Getting Server Information

To get detailed server information including IPs, use the ArvanCloud web console or API:

```bash
# Check server details via ArvanCloud API
curl -H "Authorization: Bearer YOUR_API_KEY" \
     "https://api.arvancloud.ir/iaas/v1/servers/$(terraform output -raw master_id)"
```

### Check All Outputs
```bash
terraform output
```

## 🧹 Cleanup

Destroy all infrastructure:
```bash
terraform destroy --auto-approve
```

## ⚠️ Important Notes

- **Volumes**: The 3 volumes are automatically attached to the master node during server creation
- **Security**: Uses default security group; customize as needed
- **Images**: Uses data sources to dynamically find the correct image IDs
- **Flavors**: Uses data sources to dynamically find the correct flavor IDs
- **Costs**: Monitor your ArvanCloud billing as instances and volumes incur charges
- **Regions**: Currently configured for `ir-thr-c2` region

## 🆘 Troubleshooting

### Common Issues

1. **API Key Format**: Must be `apikey <36-character-key>`
2. **Region Availability**: Check ArvanCloud regions
3. **Quota Limits**: Ensure you have sufficient quotas for instances and volumes

### Debug Commands

```bash
# Check Terraform state
terraform show

# Refresh state
terraform refresh

# Debug logs
TF_LOG=DEBUG terraform apply
```