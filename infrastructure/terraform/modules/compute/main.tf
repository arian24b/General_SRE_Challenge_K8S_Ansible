terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}

# Data sources
data "arvan_images" "ubuntu" {
  region     = var.region
  image_type = "distributions"
}

data "arvan_plans" "plans" {
  region = var.region
}

# Find the image
locals {
  ubuntu_image = [for img in data.arvan_images.ubuntu.distributions : img if img.name == var.os_image][0]
}

# Find the flavor
locals {
  selected_flavor = [for plan in data.arvan_plans.plans.plans : plan if plan.name == var.flavor][0]
  
  # Cloud-init script to inject SSH public key
  cloud_init_script = var.ssh_public_key != "" ? templatefile("${path.module}/cloud-init.yaml.tftpl", {
    ssh_public_key = var.ssh_public_key
  }) : null
}

# Master Node
resource "arvan_abrak" "k8s_master" {
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region       = var.region
  name         = "k8s-master-${var.region}"
  image_id     = local.ubuntu_image.id
  flavor_id    = local.selected_flavor.id
  disk_size    = var.disk_size
  ssh_key_name = var.ssh_key_name != "" ? var.ssh_key_name : null
  init_script  = local.cloud_init_script
  enable_ipv4  = true
  enable_ipv6  = true
  security_groups = []
  networks = [{
    network_id = var.network_id
  }]
  volumes = var.volume_ids
}

# Worker Nodes
resource "arvan_abrak" "k8s_worker" {
  count = var.worker_count
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region       = var.region
  name         = "k8s-worker-${count.index}-${var.region}"
  image_id     = local.ubuntu_image.id
  flavor_id    = local.selected_flavor.id
  disk_size    = var.disk_size
  ssh_key_name = var.ssh_key_name != "" ? var.ssh_key_name : null
  init_script  = local.cloud_init_script
  enable_ipv4  = true
  enable_ipv6  = true
  security_groups = []
  networks = [{
    network_id = var.network_id
  }]
}

# Data source to get all abraks with their public IPs after creation
data "arvan_abraks" "all" {
  region = var.region
  depends_on = [
    arvan_abrak.k8s_master,
    arvan_abrak.k8s_worker
  ]
}

# Local values to extract public IPs from the data source
locals {
  # Find master instance by ID and extract public IP
  master_instance = [for inst in data.arvan_abraks.all.instances : inst if inst.id == arvan_abrak.k8s_master.id][0]
  master_public_ip = try(
    [for network_name, addresses in local.master_instance.addresses : 
      [for addr in addresses : addr.address if addr.is_public == true][0]
    ][0],
    arvan_abrak.k8s_master.networks[0].ip  # Fallback to private IP if no public found
  )
  
  # Find worker instances by ID and extract public IPs
  worker_instances = [
    for worker in arvan_abrak.k8s_worker : 
      [for inst in data.arvan_abraks.all.instances : inst if inst.id == worker.id][0]
  ]
  worker_public_ips = [
    for inst in local.worker_instances :
      try(
        [for network_name, addresses in inst.addresses : 
          [for addr in addresses : addr.address if addr.is_public == true][0]
        ][0],
        inst.addresses[keys(inst.addresses)[0]][0].address  # Fallback
      )
  ]
}

output "master_private_ip" {
  value       = arvan_abrak.k8s_master.networks[0].ip
  description = "Private IP address of the master node"
}

output "master_public_ip" {
  value       = local.master_public_ip
  description = "Public IP address of the master node"
}

output "worker_private_ips" {
  value       = [for worker in arvan_abrak.k8s_worker : worker.networks[0].ip]
  description = "Private IP addresses of the worker nodes"
}

output "worker_public_ips" {
  value       = local.worker_public_ips
  description = "Public IP addresses of the worker nodes"
}

output "master_id" {
  value       = arvan_abrak.k8s_master.id
  description = "ID of the master node"
}

output "worker_ids" {
  value       = [for worker in arvan_abrak.k8s_worker : worker.id]
  description = "IDs of the worker nodes"
}
