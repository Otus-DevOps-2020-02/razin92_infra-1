resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = var.network_name
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
