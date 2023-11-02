module "create_connection_profile_gcs" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-gcs"        # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-gcs"        # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  gcs_profile = {
    bucket    = google_storage_bucket.ahmed.name # Bucket name without the "gs://" prefix (Required)
    root_path = "/"                              # Root path inside the GCS bucket (Optional, defaults to "/")
  }

  #   postgresql_profile = {
  #     hostname = "127.0.0.1" # (Required) Hostname for the PostgreSQL connection.
  #     port     = "1521"      # (Optional) Port for the PostgreSQL connection, default value is 5432.
  #     database = "default"   # (Required) Username for the PostgreSQL connection.
  #     username = "ahmed"     # (Required) Database for the PostgreSQL connection.
  #   }

  #   forward_ssh_connectivity = {
  #     hostname = "127.0.0.1" # (Required) Hostname for the SSH tunnel.
  #     username = "ahmed"     # (Required) Username for the SSH tunnel.
  #     port     = "22"        # Port for the SSH tunnel, default value is 22.
  #   }

  #   mysql_profile = {
  #     hostname   = "127.0.0.1" # (Required) Hostname for the MySQL connection.
  #     port       = "3306"      # (Optional) Port for the MySQL connection, default value is 3306.
  #     username   = "ahmed"     # (Required) Username for the MySQL connection.
  #     ssl_config = {}          # SSL configuration for MySQL (empty to enable ssl_config, secrets passed from var.secret)
  #   }

  #   oracle_profile = {
  #     username         = "ahmed"     # (Required) Hostname for the Oracle connection.
  #     hostname         = "127.0.0.1" # (Optional) Port for the Oracle connection, default value is 1521.
  #     port             = "1521"      # (Required) Username for the Oracle connection.
  #     database_service = "default"   # (Required) Database for the Oracle connection.
  #     connection_attributes = {      # (Optional) map (key: string, value: string) Connection string attributes
  #       key = "some_value"
  #     }
  #   }

  #   secret = {
  #     oracle_profile = {
  #       password = "secret" # Password for Oracle profile (Required if using oracle_profile)
  #     }

  #     postgresql_profile = {
  #       password = "secret" # Password for PostgreSQL profile (Required if using postgresql_profile)
  #     }

  #     mysql_profile = {
  #       password           = "secret"        # Password for MySQL profile (Required if using mysql_profile)
  #       client_key         = "pem_file_here" # Client key for MySQL profile (Optional but required if ssl_config is required)
  #       ca_certificate     = "pem_file_here" # CA certificate for MySQL profile (Optional but required if ssl_config is required)
  #       client_certificate = "pem_file_here" # Client certificate for MySQL profile (Optional but required if ssl_config is required)
  #     }

  #     forward_ssh_connectivity = {
  #       password = "secret"
  #       # private_key = "pem_file_here"
  #     }
  #   }
}

resource "google_storage_bucket" "ahmed" {
  project       = "elevated-column-400011"
  name          = "test_src_connection"
  location      = "us-east1"
  force_destroy = true
}
