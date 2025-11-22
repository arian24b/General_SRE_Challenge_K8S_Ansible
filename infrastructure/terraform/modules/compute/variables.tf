variable "region" {
  description = "ArvanCloud region"
  type        = string
}

variable "os_image" {
  description = "OS image name"
  type        = string
  default     = "22.04"
}

variable "flavor" {
  description = "Instance flavor name"
  type        = string
  default     = "eco-small1"
}

variable "disk_size" {
  description = "Root disk size (GB)"
  type        = number
  default     = 25
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "volume_ids" {
  description = "List of volume IDs to attach to master"
  type        = list(string)
}

variable "network_id" {
  description = "Network ID"
  type        = string
}