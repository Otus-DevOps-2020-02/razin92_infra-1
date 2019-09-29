resource "google_compute_instance_group" "app-cluster" {
  name = "app-cluster"
  description = "Reddit-app instance group"
  project = var.project
  instances = "${google_compute_instance.app.*.self_link}"

  named_port {
    name = "app-http"
    port = "9292"
  }

  zone = var.zone
}

resource "google_compute_health_check" "app-healthcheck" {
  name = "app-healthcheck"
  check_interval_sec = 1
  timeout_sec = 1
  tcp_health_check {
    port = "9292"
  }
}

resource "google_compute_backend_service" "app-backend" {
  name = "app-backend"
  protocol = "HTTP"
  port_name = "app-http"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.app-cluster.self_link}"
  }

  health_checks = ["${google_compute_health_check.app-healthcheck.self_link}"]
}

resource "google_compute_url_map" "app-map" {
  name = "app-map"
  description = "Reddit-app LB"

  default_service = "${google_compute_backend_service.app-backend.self_link}"

  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_service.app-backend.self_link}"
  }
}

resource "google_compute_global_forwarding_rule" "app-rule"{
  name       = "app-rule"
  target     = "${google_compute_target_http_proxy.app-proxy.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "app-proxy" {
  name        = "app-proxy"
  url_map     = "${google_compute_url_map.app-map.self_link}"
}
