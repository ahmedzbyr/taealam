module "create_ds_stream" {
  # Define the source module path
  source = "../../datastream_stream"

  # Specify the GCP project ID
  project = "elevated-column-400011"

  # Set a human-readable name for the Datastream stream
  display_name = "ahmed-ds-stream"

  # Unique identifier for the Datastream stream
  stream_id = "ahmed-ds-stream"

  # The location where the Datastream resource will be created
  location = "us-east1"

  # Labels are key/value pairs for tagging and organizing GCP resources
  labels = {
    key = "some_value"
  }

  # Backfill configuration to determine how historical data is handled
  backfill_none = false # If false, historical data is not excluded from the stream
  backfill_all = {
    # Specify any databases and tables to exclude from backfilling
    mysql_excluded_objects = {
      mysql_databases = [
        {
          # Name of the database to exclude from backfill
          database = "ahmed"
          mysql_tables = [
            {
              # Specific tables within the 'ahmed' database to exclude
              table = "atable"
              # Specify columns within 'atable' to exclude from backfill
              mysql_columns = [{ column = "amycol" }]
            },
            {
              # Another table within the 'ahmed' database to exclude
              table = "btable"
              # Specify columns within 'btable' to exclude from backfill
              mysql_columns = [{ column = "bmycol" }]
            }
          ]
        }
      ]
    }
  }

  # Desired state of the Datastream stream, e.g., "RUNNING" or "PAUSED"
  desired_state = "RUNNING"

  # Configuration for the source connection profile
  # Replace {project}, {location}, and {name} with appropriate values
  source_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  mysql_source_config       = {} # Placeholder for MySQL source-specific configuration

  # Configuration for the destination connection profile
  # Replace {project}, {location}, and {name} with appropriate values
  destination_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  bigquery_destination_config = {
    # Configuration for BigQuery as the destination
    single_target_dataset = {
      # ID of the BigQuery dataset to which the Datastream will write data
      dataset_id = "project-id:dataset-id"
    }
  }
}
