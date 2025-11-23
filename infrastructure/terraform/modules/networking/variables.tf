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

variable "region" {
  description = "ArvanCloud region"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for the network"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "dhcp_range" {
  description = "DHCP range for the network"
  type        = object({
    start = string
    end   = string
  })
  default = {
    start = "10.0.0.10"
    end   = "10.0.0.100"
  }
}