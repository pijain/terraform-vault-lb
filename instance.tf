resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type  = "e2-medium"
  #zone         =   "${element(var.var_zones, count.index)}"
  zone          =   "us-east1-b"
  tags          = ["web"]
  boot_disk {
    initialize_params {
      image     =  "centos-7-v20180129"     
    }
  }

network_interface {
    subnetwork = data.google_compute_subnetwork.private-subnet.name
  }
}

resource "google_compute_instance_group" "webservers" {
  name        = "webservers"
  description = "web servers instance group"

  instances = [
    google_compute_instance.web.id
  ]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  zone = "us-east1-b"
}

resource "google_compute_instance" "jumpbox" {
  name         = "jumpbox"
  machine_type  = "e2-medium"
  #zone         =   "${element(var.var_zones, count.index)}"
  zone          =   "us-east1-b"
  tags          = ["jumpbox"]
  boot_disk {
    initialize_params {
      image     =  "centos-7-v20180129"     
    }
  }

network_interface {
    subnetwork = data.google_compute_subnetwork.public-subnet.name
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_firewall" "jumpbox" {
  ## firewall rules enabling the load balancer health checks
  name    = "jumpbox"
  network = "main"

  description = "allow Google health checks and network load balancers access"


  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jumpbox"]
}


resource "google_compute_firewall" "jumpbox-web" {
  ## firewall rules enabling the load balancer health checks
  name    = "jumpbox-web"
  network = "main"

  description = "allow Google health checks and network load balancers access"


  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [ "jumpbox" ]
  target_tags   = ["web"]
}