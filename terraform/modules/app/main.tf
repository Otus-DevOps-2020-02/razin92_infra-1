resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params { image = var.app_disk_image }
  }
  network_interface {
    network = var.network_name
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}


resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}


resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
