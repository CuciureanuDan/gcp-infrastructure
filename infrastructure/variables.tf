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