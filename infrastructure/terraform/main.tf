terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }

  backend "s3" {
    bucket                      = "sre-challenge-terraform"
    key                         = "k8s-cluster/terraform.tfstate"
    region                      = "ir-thr-at1"
    endpoint                    = "https://s3.ir-tbz-sh1.arvanstorage.ir"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "arvan" {
  api_key = var.arvan_api_key
}

module "networking" {
  source       = "./modules/networking"
  region       = var.region
  network_name = var.network_name
  network_cidr = var.network_cidr
}

module "security" {
  source = "./modules/security"
  region = var.region
}

module "storage" {
  source             = "./modules/storage"
  region             = var.region
  etcd_volume_size   = var.etcd_volume_size
  registry_volume_size = var.registry_volume_size
  logs_volume_size   = var.logs_volume_size
}

module "compute" {
  source           = "./modules/compute"
  region           = var.region
  os_image         = var.os_image
  flavor           = var.flavor
  disk_size        = var.disk_size
  worker_count     = var.worker_count
  security_group_id = module.security.security_group_id
  volume_ids       = [module.storage.etcd_volume_id, module.storage.registry_volume_id, module.storage.logs_volume_id]
  network_id       = module.networking.network_id
}