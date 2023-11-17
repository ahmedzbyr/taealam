# Resource to create a Cloud SQL database instance
resource "google_sql_database_instance" "main" {
  name             = "cloudsql-mysql-instance"   # Name of the SQL database instance
  database_version = "MYSQL_8_0"                 # Version of MySQL to use
  root_password    = random_string.random.result # Root password, randomly generated
  region           = var.region                  # Region for the database instance
  project          = var.project                 # Project ID

  settings {
    tier = "db-f1-micro" # The machine type (tier) for the database

    # Configuration for IP connectivity
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = true
    }


    # Configuration for backups
    backup_configuration {
      enabled                        = true    # Enables backups
      binary_log_enabled             = true    # Enables binary logging for point-in-time recovery
      start_time                     = "20:55" # Start time for backup window
      transaction_log_retention_days = "7"     # Number of days to retain transaction logs
    }
  }
  deletion_protection = "false" # Disables deletion protection, use with caution

  depends_on = [google_service_networking_connection.main]
}

# Resource to create a SQL user
resource "google_sql_user" "users" {
  project  = var.project                            # Project ID
  name     = var.user                               # Name of the SQL user
  instance = google_sql_database_instance.main.name # Associate user with the SQL instance
  host     = "%"                                    # Allow connection from any host
  password = random_string.random.result            # Password for the SQL user, randomly generated
}

# Resource to create a SQL database within the instance
resource "google_sql_database" "datastream_src_database" {
  project         = var.project                            # Project ID
  name            = "datastream-src-database"              # Name of the database
  instance        = google_sql_database_instance.main.name # Database instance name
  deletion_policy = "ABANDON"                              # Deletion policy for the database
}
