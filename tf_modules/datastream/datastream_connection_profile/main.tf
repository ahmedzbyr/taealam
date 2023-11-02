resource "google_datastream_connection_profile" "main" {
  project               = var.project
  display_name          = var.display_name
  location              = var.location
  connection_profile_id = var.connection_profile_id
  labels                = var.labels

  dynamic "oracle_profile" {
    for_each = var.oracle_profile != null ? [var.oracle_profile] : []
    content {
      hostname              = oracle_profile.value.hostname
      port                  = lookup(oracle_profile.value, "port", null)
      username              = oracle_profile.value.username
      password              = var.secret.oracle_profile.password # NOTE: /// TODO move this to VAULT and access it from there
      database_service      = oracle_profile.value.database_service
      connection_attributes = lookup(oracle_profile.value, "connection_attributes", null)
    }
  }

  dynamic "gcs_profile" {
    for_each = var.gcs_profile != null ? [var.gcs_profile] : []
    content {
      bucket    = gcs_profile.value.bucket
      root_path = lookup(gcs_profile.value, "root_path", "/")
    }
  }

  dynamic "mysql_profile" {
    for_each = var.mysql_profile != null ? [var.mysql_profile] : []
    content {
      hostname = mysql_profile.value.hostname
      port     = lookup(mysql_profile.value, "port", null)
      username = mysql_profile.value.username
      password = var.secret.mysql_profile.password # NOTE: /// TODO move this to VAULT and access it from there
      dynamic "ssl_config" {
        for_each = lookup(mysql_profile.value, "ssl_config", null) != null ? [mysql_profile.value.ssl_config] : []
        content {
          client_key         = var.secret.mysql_profile.client_key         # NOTE: /// TODO move this to VAULT and access it from there
          client_certificate = var.secret.mysql_profile.client_certificate # NOTE: /// TODO move this to VAULT and access it from there
          ca_certificate     = var.secret.mysql_profile.ca_certificate     # NOTE: /// TODO move this to VAULT and access it from there
        }
      }
    }
  }

  dynamic "postgresql_profile" {
    for_each = var.postgresql_profile != null ? [var.postgresql_profile] : []
    content {
      hostname = postgresql_profile.value.hostname
      port     = lookup(postgresql_profile.value, "port", null)
      username = postgresql_profile.value.username
      password = var.secret.postgresql_profile.password # NOTE: /// TODO move this to VAULT and access it from there
      database = postgresql_profile.value.database
    }
  }

  dynamic "forward_ssh_connectivity" {
    for_each = var.forward_ssh_connectivity != null ? [var.forward_ssh_connectivity] : []
    content {
      hostname    = forward_ssh_connectivity.value.hostname
      username    = forward_ssh_connectivity.value.username
      port        = lookup(forward_ssh_connectivity.value, "port", null)
      password    = lookup(var.secret.forward_ssh_connectivity, "password", null)    # NOTE: /// TODO move this to VAULT and access it from there
      private_key = lookup(var.secret.forward_ssh_connectivity, "private_key", null) # NOTE: /// TODO move this to VAULT and access it from there
    }
  }

  dynamic "bigquery_profile" {
    for_each = var.bigquery_profile != null ? [var.bigquery_profile] : []
    content {}
  }

  dynamic "private_connectivity" {
    for_each = var.private_connectivity != null ? [var.private_connectivity] : []
    content {
      private_connection = private_connectivity.value.private_connectivity
    }
  }
}

