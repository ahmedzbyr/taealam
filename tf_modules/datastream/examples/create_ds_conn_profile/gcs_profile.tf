module "create_connection_profile_gcs" {
  source                = "../../datastream_connection_profile"
  project               = "my-project-id"   # Project where the connection profile will be created
  display_name          = "ahmd-connec-gcs" # Display name for the connection profile
  location              = "us-east1"        # Location of the connection profile
  connection_profile_id = "ahmd-connec-gcs" # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  gcs_profile = {
    bucket    = google_storage_bucket.gcs.name # Bucket name without the "gs://" prefix (Required)
    root_path = "/"                            # Root path inside the GCS bucket (Optional, defaults to "/")
  }
}

resource "google_storage_bucket" "gcs" {
  project       = "my-project-id"
  name          = "test_src_connection"
  location      = "us-east1"
  force_destroy = true
}
