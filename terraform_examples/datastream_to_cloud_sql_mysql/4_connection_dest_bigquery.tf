module "create_dest_connection_profile_bq" {
  source                = "git::https://github.com/ahmedzbyr/taealam.git//tf_modules/datastream/datastream_connection_profile"
  project               = var.project      # Project where the connection profile will be created
  display_name          = "ahmd-connec-bq" # Display name for the connection profile
  location              = var.region       # Location of the connection profile
  connection_profile_id = "ahmd-connec-bq" # Unique identifier for the connection profile

  labels = {
    type = "datastream"
  }
  bigquery_profile = {}
  depends_on       = [google_bigquery_dataset.dataset]
}
