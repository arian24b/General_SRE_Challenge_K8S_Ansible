terraform {
  required_providers {
    arvan = {
      source  = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}

resource "arvan_network" "k8s_network" {
  name           = var.network_name
  cidr           = var.network_cidr
  region         = var.region
  description    = "Kubernetes cluster network"
  enable_gateway = true
  enable_dhcp    = true
  dns_servers    = var.dns_servers
  dhcp_range     = var.dhcp_range
}

output "network_id" {
  value = arvan_network.k8s_network.network_id
}