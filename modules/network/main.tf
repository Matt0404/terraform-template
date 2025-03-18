resource "google_compute_network" "this" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

output "network_name" {
  value = google_compute_network.this.name
}

resource "google_compute_subnetwork" "this" {
  name                     = "subnetwork"
  network                  = google_compute_network.this.id
  ip_cidr_range            = "10.0.1.0/24"
  region                   = "europe-west1"
}

###
#1
#nota: as postas 80, 443 permitem a entrada de http e https respetivamente
resource "google_compute_firewall" "default-allow-http" {
  name      = "default-allow-http-https"
  network   = google_compute_network.this.name
  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

#2
resource "google_compute_firewall" "default-allow-internal" {
  name      = "default-allow-internal"
  network   = google_compute_network.this.name
  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.1.0/24"]
}

#3
resource "google_compute_firewall" "default-allow-ssh" {
  name      = "default-allow-ssh"
  network   = google_compute_network.this.name
  priority  = 2000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

#4
resource "google_compute_firewall" "deny-all" {
  name      = "deny-all"
  network   = google_compute_network.this.name
  priority  = 65534
  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}