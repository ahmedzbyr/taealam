module "create_connection_profile_bq" {
  source                = "../../datastream_connection_profile"
  project               = "my-project-id"  # Project where the connection profile will be created
  display_name          = "ahmd-connec-bq" # Display name for the connection profile
  location              = "us-east1"       # Location of the connection profile
  connection_profile_id = "ahmd-connec-bq" # Unique identifier for the connection profile

  labels = {
    key = "value"
  }
  bigquery_profile = {}
}

