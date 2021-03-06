resource "google_compute_firewall" "default-lb-fw" {
  count         = var.enabled ? 1 : 0
  name          = var.name
  network       = var.network
  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.target_tags

  allow {
    ports    = sort(var.ports)
    protocol = var.protocol
  }

  depends_on = [var.and_depends_on]
}

resource "google_compute_forwarding_rule" "default" {
  count                 = var.enabled ? 1 : 0
  target                = google_compute_target_pool.default[count.index].self_link
  name                  = var.name
  load_balancing_scheme = "EXTERNAL"
  network_tier          = "STANDARD"
  region                = "us-east1"
  port_range            = join("-", sort(var.ports))
}

resource "google_compute_health_check" "default" {
  count               = var.enabled ? 1 : 0
  name                = var.name
  check_interval_sec  = 1
  timeout_sec         = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5

  tcp_health_check {
    port = "4646"
  }
}

resource "google_compute_target_pool" "default" {
  count            = var.enabled ? 1 : 0
  name             = var.name
  region           = var.region
  session_affinity = "CLIENT_IP"
  instances        = var.instances
}