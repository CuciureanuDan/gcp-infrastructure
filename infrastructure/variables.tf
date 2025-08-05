variable "project" { }

variable "region" {
    default = "us-central1"
}

variable "zone" {
    default = "us-central1-c"
}

variable "machine_type" {
    default = "e2-micro"
}

variable "image" {
    default = "debian-cloud/debian-11"
}

variable "pubkey" {
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3G9dhXQ4ArZ61QHlIDUjePplyGsTDogoeQjaQ9T7PO dancu"
}