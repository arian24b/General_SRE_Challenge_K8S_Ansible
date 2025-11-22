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
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 22
      port_range_max = 22
      cidr_block     = "0.0.0.0/0"
      description    = "SSH access"
    },
    {
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 6443
      port_range_max = 6443
      cidr_block     = "0.0.0.0/0"
      description    = "Kubernetes API server"
    },
    {
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 2379
      port_range_max = 2380
      cidr_block     = "0.0.0.0/0"
      description    = "etcd server client API"
    },
    {
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 10250
      port_range_max = 10250
      cidr_block     = "0.0.0.0/0"
      description    = "Kubelet API"
    },
    {
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 10251
      port_range_max = 10251
      cidr_block     = "0.0.0.0/0"
      description    = "kube-scheduler"
    },
    {
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 10252
      port_range_max = 10252
      cidr_block     = "0.0.0.0/0"
      description    = "kube-controller-manager"
    },
    {
      direction      = "ingress"
      protocol       = "tcp"
      port_range_min = 30000
      port_range_max = 32767
      cidr_block     = "0.0.0.0/0"
      description    = "NodePort Services"
    },
    {
      direction      = "egress"
      protocol       = "tcp"
      port_range_min = 1
      port_range_max = 65535
      cidr_block     = "0.0.0.0/0"
      description    = "Allow all outbound traffic"
    }
  ]
}

output "security_group_id" {
  value = arvan_security_group.k8s_sg.id
}