# Define a Google Datastream connection profile resource.
resource "google_datastream_connection_profile" "main" {
  # The project ID in which the connection profile will be created.
  project = var.project

  # A user-friendly name for the connection profile.
  display_name = var.display_name

  # The location where the connection profile will be created.
  location = var.location

  # The unique identifier for the connection profile.
  connection_profile_id = var.connection_profile_id

  # A set of key/value label pairs to assign to the connection profile.
  labels = var.labels

  # A dynamic block for the oracle_profile, which allows conditional creation of this nested block.
  dynamic "oracle_profile" {
    # Create the block only if var.oracle_profile is not null; otherwise create an empty list.
    for_each = var.oracle_profile != null ? [var.oracle_profile] : []

    # The content of the oracle_profile.
    content {
      hostname = oracle_profile.value.hostname
      port     = lookup(oracle_profile.value, "port", null)
      username = oracle_profile.value.username
      # The password is currently sourced from a variable. This should be moved to a more secure storage like Vault.
      password              = var.secret.oracle_profile.password
      database_service      = oracle_profile.value.database_service
      connection_attributes = lookup(oracle_profile.value, "connection_attributes", null)
    }
  }

  # A dynamic block for the Google Cloud Storage profile configuration.
  dynamic "gcs_profile" {
    # Conditionally create this block if var.gcs_profile is not null.
    for_each = var.gcs_profile != null ? [var.gcs_profile] : []
    content {
      bucket = gcs_profile.value.bucket
      # Default root_path to "/" if not provided.
      root_path = lookup(gcs_profile.value, "root_path", "/")
    }
  }

  # A dynamic block for the MySQL profile configuration.
  dynamic "mysql_profile" {
    for_each = var.mysql_profile != null ? [var.mysql_profile] : []
    content {
      hostname = mysql_profile.value.hostname
      port     = lookup(mysql_profile.value, "port", null)
      username = mysql_profile.value.username
      # The password is currently sourced from a variable and should be moved to Vault.
      password = var.secret.mysql_profile.password

      # A nested dynamic block within the mysql_profile for configuring SSL.
      dynamic "ssl_config" {
        # Only create this block if ssl_config is provided.
        for_each = lookup(mysql_profile.value, "ssl_config", null) != null ? [mysql_profile.value.ssl_config] : []
        content {
          # Each of these keys should be moved to Vault for better security practices.
          client_key         = var.secret.mysql_profile.client_key
          client_certificate = var.secret.mysql_profile.client_certificate
          ca_certificate     = var.secret.mysql_profile.ca_certificate
        }
      }
    }
  }

  # A dynamic block for the PostgreSQL profile configuration.
  dynamic "postgresql_profile" {
    for_each = var.postgresql_profile != null ? [var.postgresql_profile] : []
    content {
      hostname = postgresql_profile.value.hostname
      port     = lookup(postgresql_profile.value, "port", null)
      username = postgresql_profile.value.username
      # Again, the password should be moved to a secure storage like Vault.
      password = var.secret.postgresql_profile.password
      database = postgresql_profile.value.database
    }
  }

  # A dynamic block for configuring SSH connectivity.
  dynamic "forward_ssh_connectivity" {
    for_each = var.forward_ssh_connectivity != null ? [var.forward_ssh_connectivity] : []
    content {
      hostname = forward_ssh_connectivity.value.hostname
      username = forward_ssh_connectivity.value.username
      port     = lookup(forward_ssh_connectivity.value, "port", null)
      # Both the password and private_key should be securely stored in Vault.
      password    = lookup(var.secret.forward_ssh_connectivity, "password", null)
      private_key = lookup(var.secret.forward_ssh_connectivity, "private_key", null)
    }
  }

  # A dynamic block for the BigQuery profile, which is empty and has no configuration.
  dynamic "bigquery_profile" {
    for_each = var.bigquery_profile != null ? [var.bigquery_profile] : []
    content {}
  }

  # A dynamic block for private connectivity configuration.
  dynamic "private_connectivity" {
    for_each = var.private_connectivity != null ? [var.private_connectivity] : []
    content {
      private_connection = private_connectivity.value
    }
  }
}
