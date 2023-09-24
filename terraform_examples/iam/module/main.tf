resource "google_storage_bucket" "create_new_bucket" {
  name          = var.bucket_name
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
}


