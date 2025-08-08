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
    description = "Allow SSH and ICMP"

    allow {
        protocol = "icmp"
    }

    allow {
      protocol = "tcp"
      ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"] 
}

resource "google_compute_firewall" "allow_docker_swarm" {
    name = "${var.vpc_name}-allow-docker-swarm"
    network = google_compute_network.vpc.name
    description = "Allow Docker Swarm communication"

    allow {
        protocol = "tcp"
        ports = ["2377", "7946"]
    }

    allow {
        protocol = "udp"
        ports = ["7946", "4789"]
    }

    # target_tags = []    # for future improvement   
    #
    source_ranges = ["10.0.0.0/24"] #  ["172.16.0.0/12", "192.168.0.0/16"]

}