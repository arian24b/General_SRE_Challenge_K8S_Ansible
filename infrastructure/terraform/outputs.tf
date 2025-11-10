output "master_public_ip" {
  description = "Public IP of master"
  value       = hcloud_server.k8s_master.ipv4_address
}

output "worker_public_ips" {
  description = "Public IPs of workers"
  value       = [for w in hcloud_server.k8s_worker : w.ipv4_address]
}

output "private_ips" {
  description = "Private IPs"
  value = {
    master = hcloud_server_network.k8s_master_net.ip
    workers = [for n in hcloud_server_network.k8s_worker_net : n.ip]
  }
}

output "ssh_key_id" {
  description = "SSH Key ID"
  value       = hcloud_ssh_key.k8s_key.id
}

output "network_id" {
  description = "Private Network ID"
  value       = hcloud_network.k8s_net.id
}