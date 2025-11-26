variable "arvan_api_key" {
  description = "ArvanCloud API Key (format: apikey <36-character-key>)"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "ArvanCloud region (eu-west1-a)"
  type        = string
  default     = "eu-west1-a"
}

variable "os_image" {
  description = "OS image name (from available distributions)"
  type        = string
  default     = "22.04" # Available: 24.04, 22.04, 20.04, etc.
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair in ArvanCloud"
  type        = string
  default     = ""
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 2
}

variable "flavor" {
  description = "Instance flavor name (from available plans)"
  type        = string
  default     = "eco-small1" # Available: eco-small1, g5-small1, etc.
}

variable "disk_size" {
  description = "Root disk size (GB) for instances"
  type        = number
  default     = 25
}

variable "etcd_volume_size" {
  description = "Size (GB) for etcd volume"
  type        = number
  default     = 50
}

variable "registry_volume_size" {
  description = "Size (GB) for registry volume"
  type        = number
  default     = 100
}

variable "logs_volume_size" {
  description = "Size (GB) for logs volume"
  type        = number
  default     = 50
}

variable "network_name" {
  description = "Name of the private network"
  type        = string
  default     = "k8s-network"
}

variable "network_cidr" {
  description = "CIDR block for the network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "master_public_ip" {
  description = "Public IP address of the master node"
  type        = string
  default     = "194.5.206.210"
}

variable "worker_public_ips" {
  description = "Public IP addresses of the worker nodes"
  type        = list(string)
  default     = ["194.5.206.23", "194.5.206.212"]
}