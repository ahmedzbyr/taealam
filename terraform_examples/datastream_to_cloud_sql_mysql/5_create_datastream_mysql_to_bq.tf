
module "datastream_mysql_to_bq_dataset" {
  source  = "git::https://github.com/ahmedzbyr/taealam.git//tf_modules/datastream/datastream_stream"
  project = var.project # Project where the connection profile will be created

  # Set a human-readable name for the Datastream stream
  display_name = "ahmed-ds-stream"

  # Unique identifier for the Datastream stream
  stream_id = "ahmed-ds-stream"

  # The location where the Datastream resource will be created
  location = "us-east1"

  # Labels are key/value pairs for tagging and organizing GCP resources
  labels = {
    type = "datastream"
  }

  # Backfill configuration to determine how historical data is handled
  backfill_all = {}

  # Desired state of the Datastream stream, e.g., "RUNNING" or "PAUSED"
  desired_state = "RUNNING"

  # Configuration for the source connection profile
  source_connection_profile = module.create_src_connection_profile_mysql.this_connection_profile_id # "projects/{project}/locations/{location}/connectionProfiles/{name}"
  mysql_source_config = {
    include_objects = {
      mysql_databases = [{
        database = google_sql_database.datastream_src_database.name
      }]
    }
  } # Placeholder for MySQL source-specific configuration

  # Configuration for the destination connection profile
  destination_connection_profile = module.create_dest_connection_profile_bq.this_connection_profile_id # "projects/{project}/locations/{location}/connectionProfiles/{name}"
  bigquery_destination_config = {
    # Configuration for BigQuery as the destination
    single_target_dataset = {
      # ID of the BigQuery dataset to which the Datastream will write data
      dataset_id = google_bigquery_dataset.dataset.id
    }
  }
}
