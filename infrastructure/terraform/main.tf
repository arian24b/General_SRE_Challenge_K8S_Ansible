terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.56.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "k8s_net" {
  name     = "k8s-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k8s_subnet" {
  network_id   = hcloud_network.k8s_net.id
  type         = "cloud"
  network_zone = var.location
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_ssh_key" "k8s_key" {
  name       = "k8s-ssh-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_firewall" "k8s_fw" {
  name = "k8s-firewall"

  # Ingress: SSH
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  # Ingress: Kubernetes API Server
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  # Ingress: Kubelet
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  apply_to {
    label_selector = "k8s-node=true"
  }
}

# Master Node
resource "hcloud_server" "k8s_master" {
  name        = "k8s-master-${var.location}"
  server_type = "CX23"
  image       = var.os_image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.k8s_key.id]
  labels      = { "k8s-node" = "true" }

  firewall_ids = [hcloud_firewall.k8s_fw.id]
}

# Worker Nodes
resource "hcloud_server" "k8s_worker" {
  count       = 2
  name        = "k8s-worker-${count.index}-${var.location}"
  server_type = "CX23"
  image       = var.os_image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.k8s_key.id]
  labels      = { "k8s-node" = "true" }
  firewall_ids = [hcloud_firewall.k8s_fw.id]
}

resource "hcloud_server_network" "k8s_master_net" {
  server_id  = hcloud_server.k8s_master.id
  network_id = hcloud_network.k8s_net.id
  ip         = "10.0.1.10"
}

resource "hcloud_server_network" "k8s_worker_net" {
  count      = 2
  server_id  = hcloud_server.k8s_worker[count.index].id
  network_id = hcloud_network.k8s_net.id
  ip         = "10.0.1.${11 + count.index}"
}