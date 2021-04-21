# ------------------------------------------------------------------------------
# CREATE THE INSTANCE GROUP WITH A INSTANCE TEMPLATE
# ------------------------------------------------------------------------------

locals {
    vault_tls_bucket  = google_storage_bucket.vault.name
    ip_address        = var.ip_address
}

# Enable required services on the project
resource "google_project_service" "service" {
  for_each = toset(var.project_services)
  project  = var.project_id

  service = each.key

  # Do not disable the service on destroy. This may be a shared project, and
  # we might not "own" the services we enable.
  disable_on_destroy = false
}


#instance template
resource "google_compute_instance_template" "default" {
  project     = var.project_id
  region      = var.region
  name_prefix = "vault-"

  machine_type = var.vault_machine_type

  tags = var.instance_tags
  labels = var.instance_labels

  network_interface {
    subnetwork         = var.subnet
    subnetwork_project = var.host_project_id
  }

  disk {
    source_image = var.instance_base_image
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
    mode         = "READ_WRITE"
    boot         = true
  }

  # metadata = {
  #   sshKeys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDI1937VIktLYhIPe1wjG4TnvAC/yNTH5u8ZDXc8uB8L32g+LbXjcNwck1bpW7GBh8gPWQtP+h+t9eKO/rNbKOkyMoeTkG23W2v8BNvyoZDTgrsc+OS9Gd1OacOJoFYSLtEn9IUbFY/AnPm/iGWG+J5B2lQEzKailUbk1/4Ee1pzm3JK/rAEkmV/ks374Z7fFwqx3krtam0xjEhF1mA60gJbadArf50z/Mq/nUQ10bu3qxSBnIdlrCSOMFSLkNRtb84IXxv4sZKJeqJ7fopZfIIPVGO/qvt5KrtwHK/oPda3QZC8VUfG1Lj40w6CueXdQHEJlJO+R1hTe1QdEGv0iZxYmdyAM4YhO6AiZTljI54cPCTuOnksBBVCCeCSfOqm4Yif1Y7UXsX0M10FO0/LzpeGZXbV+LcoV1bO3SCdAsRXvxxtExtfn150qNd4RQ4dhlew66Vqm891JKaPXg7DRGtCxlvoJqfNrFQSIhK4FK9uNZTuNbPAMlisQZlvJorDtEXBgP5aOARxyQjcq32jduYHthYuQ1p6z7ISwLZhcocxJU938sbjijfVBrDm4TUh6rUSKO22v3Y62LW6jVsla/uxTEQR3b3UsS2xTBDzuS7VuSKNheWuRBFSXDEFtk48fHGl8eV6k0xJjX2+uKp59U3N3TI6zZKiMWoB/+Np3DQUQ== rakeshreddy.gade@cvshealth.com"
  # }
  
  service_account {
    email  = var.vault_service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  //metadata_startup_script = "${file("${path.module}/templates/startup.sh")}"

  metadata = merge(
    var.vault_instance_metadata,
    {
      "google-compute-enable-virtio-rng" = "true"
      "startup-script"                   = data.template_file.vault-startup-script.rendered
    },
  )
  
  lifecycle {
    create_before_destroy = true
  }

}

#  instance group manager
resource "google_compute_region_instance_group_manager" "default" {
  project = var.project_id
  name   = "vault-instance-group"
  region = var.region
  distribution_policy_zones  = ["us-east1-b"]
  base_instance_name = var.instance_name
  wait_for_instances = false

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    min_ready_sec         = var.min_ready_sec
    max_unavailable_fixed = 1
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autoheal.id
    initial_delay_sec = var.hc_initial_delay_secs
  }

  named_port {
    name = "vault-http"
    port = var.vault_port
  }

  version {
    instance_template = google_compute_instance_template.default.self_link
  }
}

# Autoscaling policies for 
resource "google_compute_region_autoscaler" "default" {
  project = var.project_id
  name   = "vault-autoscale"
  region = var.region
  target = google_compute_region_instance_group_manager.default.self_link

  autoscaling_policy {
    min_replicas    = var.min_num_servers
    max_replicas    = var.max_num_servers
    cooldown_period = 300

    cpu_utilization {
      target = 0.8
    }
  }
}

# Auto-healing
resource "google_compute_health_check" "autoheal" {
  project = var.project_id
  name    = "vault-health-autoheal"

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 2

  http_health_check {
    port         = var.vault_port
    request_path = var.request_path
  }
}
