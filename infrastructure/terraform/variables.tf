variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Hetzner location (fsn1)"
  type        = string
  default     = "fsn1"
}

variable "os_image" {
  description = "OS image for servers"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}