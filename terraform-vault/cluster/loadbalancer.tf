# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

#creating forward rule
resource "google_compute_global_forwarding_rule" "default" {
  name       = "vault-lb-frontend"
  project    = var.project_id
  ip_address = var.ip_address
  port_range = var.lb_port
  target     = google_compute_target_https_proxy.default.self_link
}

#creating proxy for forwarding rule
resource "google_compute_target_https_proxy" "default" {
  name             = "vault-target-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

#creating certs to attach to the loadbalancer
resource "google_compute_ssl_certificate" "default" {
  name        = "vault-certs"
  project     = var.project_id
  private_key = file("${path.module}/ssl-certs/${var.vault_tls_key}")
  certificate = file("${path.module}/ssl-certs/${var.vault_tls_cert}")
}

#create the url map to map paths to backends
resource "google_compute_url_map" "default" {
  name        = "vault-url-map"
  project     = var.project_id
  
  host_rule {
    hosts         = [var.domain_name]
    path_matcher = "all"
  }

  path_matcher {
    name            = "all"
    default_service = google_compute_backend_service.default.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.default.self_link
    }
  }

  default_service = google_compute_backend_service.default.self_link
}

#creating the backend service configurations for the instance group
resource "google_compute_backend_service" "default" {
  name             = "vault-backend"
  project          = var.project_id
  protocol         = "HTTPS"   
  port_name        = "https"   
  timeout_sec      = 10
  session_affinity = "NONE"

  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
  }

  health_checks = [google_compute_https_health_check.default.id]
}

#configure health check for the api backend
resource "google_compute_https_health_check" "default" {
  name         = "vts-health-https"
  project      = var.project_id
  request_path = var.request_path

  timeout_sec        = 5
  check_interval_sec = 5
  port               = var.lb_port

  lifecycle {
    create_before_destroy = true
  }
}
