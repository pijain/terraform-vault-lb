data "google_compute_network" "vpc" {
  name = "main"
}

data "google_compute_subnetwork" "public-subnet" {
  name   = "public"
  region = "us-east1"
}

data "google_compute_subnetwork" "private-subnet" {
  name   = "private"
  region = "us-east1"
}


resource "google_compute_firewall" "allow-bastion" {
  name    = "test-fw-allow-bastion"
  network = data.google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = [ "0.0.0.0/0" ]
  target_tags = ["ssh"]
  }