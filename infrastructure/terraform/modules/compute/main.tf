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
}

# Master Node
resource "arvan_abrak" "k8s_master" {
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region          = var.region
  name            = "k8s-master-${var.region}"
  image_id        = local.ubuntu_image.id
  flavor_id       = local.selected_flavor.id
  disk_size       = var.disk_size
  ssh_key_name    = var.ssh_key_name != "" ? var.ssh_key_name : null
  enable_ipv4     = true
  enable_ipv6     = true
  security_groups = [var.security_group_id]
  networks        = [{
    network_id = var.network_id
  }]
  volumes         = var.volume_ids
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
  region          = var.region
  name            = "k8s-worker-${count.index}-${var.region}"
  image_id        = local.ubuntu_image.id
  flavor_id       = local.selected_flavor.id
  disk_size       = var.disk_size
  ssh_key_name    = var.ssh_key_name != "" ? var.ssh_key_name : null
  enable_ipv4     = true
  enable_ipv6     = true
  security_groups = [var.security_group_id]
  networks        = [{
    network_id = var.network_id
  }]
}

output "master_ip" {
  value = arvan_abrak.k8s_master.id
  description = "ID of the master node (IP address available in ArvanCloud console)"
}

output "worker_ips" {
  value = arvan_abrak.k8s_worker[*].id
  description = "IDs of the worker nodes (IP addresses available in ArvanCloud console)"
}