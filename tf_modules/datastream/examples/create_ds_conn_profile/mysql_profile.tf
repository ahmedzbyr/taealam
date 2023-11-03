module "create_connection_profile_mysql" {
  source                = "../../datastream_connection_profile"
  project               = "my-project-id"     # Project where the connection profile will be created
  display_name          = "ahmd-connec-mysql" # Display name for the connection profile
  location              = "us-east1"          # Location of the connection profile
  connection_profile_id = "ahmd-connec-mysql" # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  mysql_profile = {
    hostname   = "127.0.0.1" # (Required) Hostname for the MySQL connection.
    port       = "3306"      # (Optional) Port for the MySQL connection, default value is 3306.
    username   = "ahmed"     # (Required) Username for the MySQL connection.
    ssl_config = {}          # SSL configuration for MySQL (empty to enable ssl_config, secrets passed from var.secret)
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    mysql_profile = {
      password           = "secret"        # Password for MySQL profile (Required if using mysql_profile)
      client_key         = "pem_file_here" # Client key for MySQL profile (Optional but required if ssl_config is required)
      ca_certificate     = "pem_file_here" # CA certificate for MySQL profile (Optional but required if ssl_config is required)
      client_certificate = "pem_file_here" # Client certificate for MySQL profile (Optional but required if ssl_config is required)
    }
  }
}
