resource "google_compute_network" "vpc" {
    name = var.vpc_name
    routing_mode = "REGIONAL"
    auto_create_subnetworks = false  
}

resource "google_compute_subnetwork" "public-subnet" {
    name = var.subnet_name
    ip_cidr_range = var.subnet_cidr
    region = var.region
    network = google_compute_network.vpc.self_link
    stack_type = "IPV4_ONLY"
}

resource "google_compute_firewall" "allow_ssh" {
    name = "${var.vpc_name}-allow-ssh"
    network = google_compute_network.vpc.name
    description = "Create firewall rules"

    allow {
        protocol = "icmp"
    }

    allow {
      protocol = "tcp"
      ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"] 
}