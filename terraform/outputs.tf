output "app_external_ip_1" {
  value = google_compute_instance.app[0].network_interface[0].access_config[0].nat_ip
}
