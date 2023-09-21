resource "google_bigquery_job" "job" {
  job_id     = "job_extraction_table_xyz"

  extract {
    destination_uris = ["gs://my-bq-export-bucket/extract"]
    
    source_table {
      project_id = "my-project"
      dataset_id = "my-dataset-id"
      table_id   = "my-table-in-dataset"
    }

    destination_format = "NEWLINE_DELIMITED_JSON"
    compression        = "GZIP"
  }
}

resource "google_bigquery_data_transfer_config" "query_config" {
  display_name           = "my-daily-export"
  location               = "us-central1"
  data_source_id         = "google_cloud_storage"
  schedule               = "first sunday of every month 00:00"
  destination_dataset_id = "projects/my-project-name/datasets/my-dataset"

  params = {
    destination_table_name_template = "my-table-name"
    
    data_path_template = "gs://my-bucket-export/bq-export/table-name/*.csv"
    write_disposition  = "APPEND"
    file_format        = "CSV"
    max_bad_records    = 1

    ignore_unknown_values = true
    field_delimiter       = ","
  }
}