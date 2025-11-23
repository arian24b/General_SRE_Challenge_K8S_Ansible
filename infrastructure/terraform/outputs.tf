output "security_group_id" {
  description = "ID of the security group"
  value       = module.security.security_group_id
}

output "network_id" {
  description = "ID of the private network"
  value       = module.networking.network_id
}

output "master_ip" {
  description = "ID of the master node"
  value       = module.compute.master_ip
}

output "worker_ips" {
  description = "IDs of the worker nodes"
  value       = module.compute.worker_ips
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