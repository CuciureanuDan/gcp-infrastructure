resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.subnet_link
    access_config {}
  }

  metadata = {
    ssh-keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN44j2SOP4pms4V2x77sTFG9JRTIU8xewmlnCpuWycEO id_gcp"
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
