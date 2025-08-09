resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.subnet_link
    access_config {} # assign external IP
  }

  metadata = {
    # not recommended because everyone can change the ssh-key
    ssh-keys = var.pubkey
  }
}

resource "google_compute_disk" "data_disk" {
  name = "${var.name}-disk"
  type = "pd-standard"
  zone = var.zone
  size = 10
}

resource "google_compute_attached_disk" "attach_data" {
  instance = google_compute_instance.vm.name
  disk     = google_compute_disk.data_disk.name
  zone     = var.zone
}
