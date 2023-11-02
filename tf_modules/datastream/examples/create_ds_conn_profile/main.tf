module "create_connection_profile_gcs" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011"
  display_name          = "ahmd-connec-gcs"
  location              = "us-east1"
  connection_profile_id = "ahmd-connec-gcs"
  labels = {
    key = "value"
  }
  gcs_profile = {
    bucket = google_storage_bucket.ahmed.name
  }
}

resource "google_storage_bucket" "ahmed" {
  project       = "elevated-column-400011"
  name          = "test_src_connection"
  location      = "us-east1"
  force_destroy = true
}
