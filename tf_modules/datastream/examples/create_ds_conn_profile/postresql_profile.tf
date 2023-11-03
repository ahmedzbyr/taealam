module "create_connection_profile_postgresql" {
  source                = "../../datastream_connection_profile"
  project               = "my-project-id"          # Project where the connection profile will be created
  display_name          = "ahmd-connec-postgresql" # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-postgresql" # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  postgresql_profile = {
    hostname = "127.0.0.1" # (Required) Hostname for the PostgreSQL connection.
    port     = "1521"      # (Optional) Port for the PostgreSQL connection, default value is 5432.
    database = "default"   # (Required) Username for the PostgreSQL connection.
    username = "ahmed"     # (Required) Database for the PostgreSQL connection.
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    postgresql_profile = {
      password = "secret" # Password for PostgreSQL profile (Required if using postgresql_profile)
    }
  }
}
