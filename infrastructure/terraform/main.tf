terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
      version = "0.8.1"
    }
  }

  backend "s3" {
    bucket = "sre-challenge-terraform"
    key    = "k8s-cluster/terraform.tfstate"
    region = "main"

    endpoints = {
      s3 = "https://s3.ir-thr-at1.arvanstorage.ir"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "arvan" {
  api_key = var.arvan_api_key
}

# Use default network
data "arvan_iaas_options" "default_options" {
  region = var.region
}

# Use default security group
data "arvan_iaas_security_group" "default_sg" {
  region = var.region
  name   = "arDefault"
}

# Comment out custom networking and security modules since we're using defaults
# module "networking" {
#   source       = "./modules/networking"
#   region       = var.region
#   network_name = var.network_name
#   network_cidr = var.network_cidr
# }

# module "security" {
#   source = "./modules/security"
#   region = var.region
# }

# For now, comment out storage to avoid permission issues
# module "storage" {
#   source             = "./modules/storage"
#   region             = var.region
#   etcd_volume_size   = var.etcd_volume_size
#   registry_volume_size = var.registry_volume_size
#   logs_volume_size   = var.logs_volume_size
# }

module "compute" {
  source           = "./modules/compute"
  region           = var.region
  os_image         = var.os_image
  flavor           = var.flavor
  disk_size        = var.disk_size
  worker_count     = var.worker_count
  security_group_id = data.arvan_iaas_security_group.default_sg.id
  # volume_ids       = [module.storage.etcd_volume_id, module.storage.registry_volume_id, module.storage.logs_volume_id]
  volume_ids       = []  # No volumes for now
  network_id       = data.arvan_iaas_options.default_options.network_id
}