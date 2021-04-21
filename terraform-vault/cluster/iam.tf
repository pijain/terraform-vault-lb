locals {
  service_account_member = "serviceAccount:${var.vault_service_account_email}"
}

# Give project-level IAM permissions to the service account.
resource "google_project_iam_member" "project-iam" {
  for_each = toset(var.service_account_project_iam_roles)
  project  = var.project_id
  role     = each.value
  member   = local.service_account_member
}

# Give bucket-level permissions to the service account. ***delete this iam role if SA already have storgae.object admin roles
resource "google_storage_bucket_iam_member" "vault" {
  for_each = toset(var.service_account_storage_bucket_iam_roles)
  bucket   = google_storage_bucket.vault.name
  role     = each.key
  member   = local.service_account_member
}

resource "google_storage_bucket_iam_member" "tls-bucket-iam" {
  bucket = google_storage_bucket.vault.name
  role   = "roles/storage.objectViewer"
  member = local.service_account_member
}
