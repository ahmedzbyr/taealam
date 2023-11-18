module "create_src_connection_profile_mysql" {
  source                = "git::https://github.com/ahmedzbyr/taealam.git//tf_modules/datastream/datastream_connection_profile"
  project               = var.project                              # Project where the connection profile will be created
  display_name          = "datastream-connection-csql-proxy-mysql" # Display name for the connection profile
  location              = var.region                               # Location of the connection profile
  connection_profile_id = "datastream-connection-csql-proxy-mysql" # Unique identifier for the connection profile

  labels = {
    key = "datastream"
  }

  mysql_profile = {
    hostname = google_compute_instance.main.network_interface.0.network_ip # (Required) Hostname for the MySQL connection.
    username = var.user                                                    # (Required) Username for the MySQL connection.
  }

  # Private connection to use.
  private_connectivity = module.create_private_connection_to_instance.this_private_connection_id

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    mysql_profile = {
      password = random_string.random.result
    }
  }
}
