module "create_ds_stream" {
  source       = "../../datastream_stream"
  project      = "elevated-column-400011"
  display_name = "ahmed-ds-stream"
  stream_id    = "ahmed-ds-stream"
  location     = "us-east1"
  labels = {
    key = "some_value"
  }
  backfill_none = false
  backfill_all = {
    mysql_excluded_objects = {
      mysql_databases = [
        {
          database = "ahmed"
          mysql_tables = [
            {
              table         = "atable"
              mysql_columns = [{ column = "amycol" }]
            },
            {
              table         = "btable"
              mysql_columns = [{ column = "bmycol" }]
            }
          ]
        }
      ]
    }
  }
  source_connection_profile      = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  destination_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"

  gcs_destination_config = {
    # path             = ""
    #avro_file_format = {}
    json_file_format = {}
  }

  # bigquery_destination_config = {
  #   single_target_dataset = {
  #     dataset_id = "some:some"
  #   }
  #   source_hierarchy_datasets = {
  #     dataset_template = {
  #       location = "us-east1"
  #     }
  #   }
  # }

  # mysql_source_config = {
  # }

  postgresql_source_config = {
    replication_slot = 10
    publication      = 10
  }

  # oracle_source_config = {}

}
