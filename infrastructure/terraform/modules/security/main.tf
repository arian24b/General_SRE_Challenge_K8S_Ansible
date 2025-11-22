terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }
}

resource "arvan_security_group" "k8s_sg" {
  name        = "k8s-security-group"
  description = "Security group for Kubernetes cluster"
  region      = var.region
}

resource "arvan_security_group_rule" "ssh" {
  security_group_id = arvan_security_group.k8s_sg.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  cidr_block        = "0.0.0.0/0"
}

resource "arvan_security_group_rule" "kube_api" {
  security_group_id = arvan_security_group.k8s_sg.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  cidr_block        = "0.0.0.0/0"
}

# Add more rules as needed

output "security_group_id" {
  value = arvan_security_group.k8s_sg.id
}