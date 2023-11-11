# Resource definition for creating a Google BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  project       = var.project                  # The Google Cloud project ID
  dataset_id    = "datastream_example_dataset" # Unique ID for the BigQuery dataset
  friendly_name = "datastream_example_dataset" # A user-friendly name for the dataset
  description   = "This is a test description" # Description of the dataset's purpose or contents
  location      = "us-east1"                   # The geographic location where the dataset should reside

  # Default expiration time for tables within this dataset (milliseconds)
  default_table_expiration_ms = 3600000 # 1 hour (3600000 milliseconds)

  # Labels for the dataset, useful for categorization or organization within GCP
  labels = {
    type = "datastream" # Example label indicating the dataset's intended for datastream
  }

  # If set to true, this ensures that all contents within the dataset will be deleted upon the dataset's destruction
  delete_contents_on_destroy = true # Use with caution to prevent accidental data loss
}
