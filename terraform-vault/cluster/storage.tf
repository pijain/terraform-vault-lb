resource "google_storage_bucket" "vault" {
  project       = var.project_id
  name          = "${var.project_id}-${var.vault_storage_bucket}"
  location      = "US"
  force_destroy = true
}