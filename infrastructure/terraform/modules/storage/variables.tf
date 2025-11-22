variable "region" {
  description = "ArvanCloud region"
  type        = string
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