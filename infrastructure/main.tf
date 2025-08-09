terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
    cloudns = {
      source  = "Cloudns/cloudns"
      version = "~>1.0.0"
    }
  }
}

provider "google" {
  project = var.project 
  region  = var.region 
  zone    = var.zone 
}

module "network" {
  source = "./modules/networking"
  vpc_name = "cluster-vpc"
  subnet_name = "cluster-subnet"
  subnet_cidr = "10.0.0.0/24"
  region = var.region
}

module "vm_1" {
  source = "./modules/vm"
  name = "node-1"
  machine_type = var.machine_type
  zone = var.zone
  image = var.image
  pubkey = var.pubkey
  subnet_link = module.network.subnet_self_link
  tags = ["wg-server"]
}

module "vm_2" {
  source = "./modules/vm"
  name = "node-2"
  machine_type = var.machine_type
  zone = var.zone
  image = var.image
  pubkey = var.pubkey
  subnet_link = module.network.subnet_self_link
}

module "vm_3" {
  source = "./modules/vm"
  name = "node-3"
  machine_type = var.machine_type
  zone = var.zone
  image = var.image
  pubkey = var.pubkey
  subnet_link = module.network.subnet_self_link
}