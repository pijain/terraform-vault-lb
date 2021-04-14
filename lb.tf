

resource "google_compute_global_address" "test_add" {
  name = "test-address"
}

resource "google_compute_global_forwarding_rule" "forward_rule" {
  name       = "app-port-80"
  # If you have static IP you can use directly here
  ip_address = "${google_compute_global_address.test_add.address}"
  port_range = "80"
  target     = "${google_compute_target_http_proxy.test_proxy.self_link}"
}

resource "google_compute_target_http_proxy" "test_proxy" {
  name    = "test-proxy"
  url_map = "${google_compute_url_map.url_map.self_link}"
}

/*Add below code if you are using SSL certificate with Load balancer frontend service
resource "google_compute_target_https_proxy" "default" {
  name             = "test-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

resource "google_compute_ssl_certificate" "default" {
  name        = "my-certificate"
  private_key = file("path/to/private.key")
  certificate = file("path/to/certificate.crt")
}*/

resource "google_compute_url_map" "url_map" {
  name        = "url-map"
  default_service = "${google_compute_backend_service.test_backend.self_link}"
}

resource "google_compute_backend_service" "test_backend" {
  name             = "test-backend"
  protocol         = "HTTP"   # Change protocol to HTTPS if you are using SSL certificate on the application running on instance
  port_name        = "http"   # Change port to https if you are using SSL certificate on the application running on instance
  timeout_sec      = 10
  session_affinity = "NONE"

  backend {
    group = google_compute_instance_group.webservers.id
  }

  health_checks = [google_compute_http_health_check.test.id]
}


resource "google_compute_http_health_check" "test" {
  name         = "test"
  #request_path = "/health_check"

  timeout_sec        = 5
  check_interval_sec = 5
  port               = 80  # Change the port on which Vault service is runnning

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "lb-firewall" {
  ## firewall rules enabling the load balancer health checks
  name    = "lb-firewall"
  network = "main"

  description = "allow Google health checks and network load balancers access"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web", "allow-health-check"]
}

