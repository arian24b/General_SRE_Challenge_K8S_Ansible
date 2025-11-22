resource "arvan_network" "k8s_network" {
  name   = var.network_name
  cidr   = var.network_cidr
  region = var.region
}

output "network_id" {
  value = arvan_network.k8s_network.id
}