module "create_connection_profile_fwdsshgcs" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-fwdsshgcs"  # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-fwdsshgcs"  # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  gcs_profile = {
    bucket    = google_storage_bucket.fwdsshgcs.name # Bucket name without the "gs://" prefix (Required)
    root_path = "/"                                  # Root path inside the GCS bucket (Optional, defaults to "/")
  }

  forward_ssh_connectivity = {
    hostname = "127.0.0.1" # (Required) Hostname for the SSH tunnel.
    username = "fwdsshgcs" # (Required) Username for the SSH tunnel.
    port     = "22"        # Port for the SSH tunnel, default value is 22.
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    forward_ssh_connectivity = {
      password = "secret"
      # private_key = "pem_file_here"
    }
  }
}

resource "google_storage_bucket" "fwdsshgcs" {
  project       = "elevated-column-400011"
  name          = "test_src_connection"
  location      = "us-east1"
  force_destroy = true
}
