output "security_group_id" {
  description = "ID of the security group"
  value       = module.security.security_group_id
}

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
  value       = module.compute.master_public_ip
}

output "worker_private_ips" {
  description = "Private IPs of the worker nodes"
  value       = module.compute.worker_private_ips
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes"
  value       = module.compute.worker_public_ips
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