terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}

resource "arvan_network" "k8s_network" {
  name   = var.network_name
  cidr   = var.network_cidr
  region = var.region
}

output "network_id" {
  value = arvan_network.k8s_network.id
}