module "create_connection_profile_oracle" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-oracle"     # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-oracle"     # Unique identifier for the connection profile

  labels = {
    key = "value"
  }


  oracle_profile = {
    username         = "ahmed"     # (Required) Hostname for the Oracle connection.
    hostname         = "127.0.0.1" # (Optional) Port for the Oracle connection, default value is 1521.
    port             = "1521"      # (Required) Username for the Oracle connection.
    database_service = "default"   # (Required) Database for the Oracle connection.
    connection_attributes = {      # (Optional) map (key: string, value: string) Connection string attributes
      key = "some_value"
    }
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    oracle_profile = {
      password = "secret" # Password for Oracle profile (Required if using oracle_profile)
    }
  }
}
