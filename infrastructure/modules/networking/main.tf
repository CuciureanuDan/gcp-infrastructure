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

    source_ranges = ["10.0.0.0/24"] #  ["172.16.0.0/12", "192.168.0.0/16"]

}

resource "google_compute_firewall" "allow_wireguard" {
    name = "${var.vpc_name}-allow-wireguard"
    network = google_compute_network.vpc.name
    description = "Allow Wireguard port to a specific tag"

    target_tags = ["wg-server"]

    allow {
        protocol = "udp"
        ports = ["51820"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
    name = "${var.vpc_name}-allow-http"
    network = google_compute_network.vpc.name
    description = "Allow port for web service"

    allow {
        protocol = "tcp"
        ports = ["8080"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_jenkins_agent" {
    name = "${var.vpc_name}-allow-jenkins-agent"
    network = google_compute_network.vpc.name
    description = "Allow port Jenkins node container"

    allow {
        protocol = "tcp"
        ports = ["4444"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_monitoring_ui" {
    name = "${var.vpc_name}-monitoring-ui"
    network = google_compute_network.vpc.name
    description = "Allow acces to monitoring ui only from a specific adress"
    direction = "INGRESS"
    target_tags = ["monitoring"]
    source_ranges = [var.admin_ip]
    allow {
        protocol = "tcp"
        ports = ["3000", "9090"]
    }

}

resource "google_compute_firewall" "allow_metrics" {
    name = "${var.vpc_name}-allow-scrape"
    network = google_compute_network.vpc.name
    description = "Allow ports for node exporter, cAdvisor, and Blackbox exporter"
    direction = "INGRESS"
    target_tags = ["monitored"]
    source_tags = ["monitoring"]
    allow {
        protocol = "tcp"
        ports = ["9100", "18080", "9115"]
    }
}