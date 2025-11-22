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
  region          = var.region
  name            = "k8s-master-${var.region}"
  image_id        = local.ubuntu_image.id
  flavor_id       = local.selected_flavor.id
  disk_size       = var.disk_size
  security_groups = [var.security_group_id]
  volumes         = var.volume_ids
  network_id      = var.network_id
}

# Worker Nodes
resource "arvan_abrak" "k8s_worker" {
  count           = var.worker_count
  region          = var.region
  name            = "k8s-worker-${count.index}-${var.region}"
  image_id        = local.ubuntu_image.id
  flavor_id       = local.selected_flavor.id
  disk_size       = var.disk_size
  security_groups = [var.security_group_id]
  network_id      = var.network_id
}

output "master_ip" {
  value = arvan_abrak.k8s_master.access_ipv4
}

output "worker_ips" {
  value = arvan_abrak.k8s_worker[*].access_ipv4
}