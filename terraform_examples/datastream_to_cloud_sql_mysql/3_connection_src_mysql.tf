# Waiting for the users to be created and then setting up a connectionProfile.
resource "time_sleep" "main" {
  create_duration = "30s"
  depends_on      = [google_sql_user.users]
}

module "create_src_connection_profile_mysql" {
  source                = "git::https://github.com/ahmedzbyr/taealam.git//tf_modules/datastream/datastream_connection_profile"
  project               = var.project         # Project where the connection profile will be created
  display_name          = "ahmd-connec-mysql" # Display name for the connection profile
  location              = var.region          # Location of the connection profile
  connection_profile_id = "ahmd-connec-mysql" # Unique identifier for the connection profile
  labels = {
    key = "value"
  }
  mysql_profile = {
    hostname = google_sql_database_instance.main.ip_address.0.ip_address # (Required) Hostname for the MySQL connection.
    port     = "3306"                                                    # (Optional) Port for the MySQL connection, default value is 3306.
    username = var.user                                                  # (Required) Username for the MySQL connection.
  }
  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    mysql_profile = {
      password = random_string.random.result # Password for MySQL profile (Required if using mysql_profile)
    }
  }

  depends_on = [time_sleep.main]
}
