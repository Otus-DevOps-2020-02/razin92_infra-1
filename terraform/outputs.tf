output "app_external_ip_1" {
  value = google_compute_instance.app[0].network_interface[0].access_config[0].nat_ip
}

output "app_external_ip_2" {
  value = google_compute_instance.app[1].network_interface[0].access_config[0].nat_ip
}

output "lb_external_ip" {
  value = google_compute_global_forwarding_rule.app-rule.ip_address
}
