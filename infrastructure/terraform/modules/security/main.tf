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

  rules = [
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 22
      port_to   = 22
    },
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 6443
      port_to   = 6443
    },
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 2379
      port_to   = 2380
    },
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 10250
      port_to   = 10250
    },
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 10251
      port_to   = 10251
    },
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 10252
      port_to   = 10252
    },
    {
      direction = "ingress"
      protocol  = "tcp"
      port_from = 30000
      port_to   = 32767
    },
    {
      direction = "egress"
      protocol  = "tcp"
      port_from = 1
      port_to   = 65535
      ip        = "0.0.0.0/0"
    }
  ]
}

output "security_group_id" {
  value = arvan_security_group.k8s_sg.id
}