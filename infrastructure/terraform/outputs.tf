output "network_id" {
  description = "ID of the private network"
  value       = module.networking.network_id
}

output "master_private_ip" {
  description = "Private IP of the master node"
  value       = module.compute.master_private_ip
}

output "master_public_ip" {
  description = "Public IP of the master node"
  value       = "188.121.121.230"
}

output "worker_private_ips" {
  description = "Private IPs of the worker nodes"
  value       = module.compute.worker_private_ips
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes"
  value       = ["188.213.197.144", "188.213.199.84"]
}

output "etcd_volume_id" {
  description = "ID of the etcd volume"
  value       = module.storage.etcd_volume_id
}

output "registry_volume_id" {
  description = "ID of the registry volume"
  value       = module.storage.registry_volume_id
}

output "logs_volume_id" {
  description = "ID of the logs volume"
  value       = module.storage.logs_volume_id
}