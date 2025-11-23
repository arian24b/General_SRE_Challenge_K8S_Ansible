terraform {
  required_providers {
    arvan = {
      source  = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}

resource "arvan_volume" "etcd_volume" {
  region      = var.region
  name        = "k8s-etcd-volume-${var.region}"
  size        = var.etcd_volume_size
  description = "etcd data volume for Kubernetes master"
}

resource "arvan_volume" "registry_volume" {
  region      = var.region
  name        = "k8s-registry-volume-${var.region}"
  size        = var.registry_volume_size
  description = "Docker registry cache volume"
}

resource "arvan_volume" "logs_volume" {
  region      = var.region
  name        = "k8s-logs-volume-${var.region}"
  size        = var.logs_volume_size
  description = "Logs volume for Kubernetes cluster"
}

output "etcd_volume_id" {
  value = arvan_volume.etcd_volume.id
}

output "registry_volume_id" {
  value = arvan_volume.registry_volume.id
}

output "logs_volume_id" {
  value = arvan_volume.logs_volume.id
}