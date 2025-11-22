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