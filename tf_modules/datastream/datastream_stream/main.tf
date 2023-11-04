
resource "google_datastream_stream" "main" {
  project                         = var.project
  display_name                    = var.display_name
  stream_id                       = var.stream_id
  location                        = var.location
  labels                          = var.labels
  customer_managed_encryption_key = var.customer_managed_encryption_key
  desired_state                   = var.desired_state

  dynamic "backfill_none" {
    for_each = var.backfill_none && var.backfill_all == null ? [1] : []
    content {}
  }

  dynamic "backfill_all" {
    for_each = var.backfill_all != null ? [var.backfill_all] : []
    content {
      dynamic "mysql_excluded_objects" {
        for_each = lookup(var.backfill_all, "mysql_excluded_objects", null) != null ? [var.backfill_all.mysql_excluded_objects] : []
        content {
          dynamic "mysql_databases" {
            for_each = lookup(mysql_excluded_objects.value, "mysql_databases", null) != null ? mysql_excluded_objects.value.mysql_databases : []
            content {
              database = mysql_databases.value.database
              dynamic "mysql_tables" {
                for_each = lookup(mysql_databases.value, "mysql_tables", null) != null ? mysql_databases.value.mysql_tables : []
                content {
                  table = mysql_tables.value.table
                  dynamic "mysql_columns" {
                    for_each = lookup(mysql_tables.value, "mysql_columns", "null") != null ? mysql_tables.value.mysql_columns : []
                    content {
                      column           = lookup(mysql_columns.value, "column", null)
                      data_type        = lookup(mysql_columns.value, "data_type", null)
                      length           = lookup(mysql_columns.value, "length", null)
                      collation        = lookup(mysql_columns.value, "collation", null)
                      primary_key      = lookup(mysql_columns.value, "primary_key", null)
                      nullable         = lookup(mysql_columns.value, "nullable", null)
                      ordinal_position = lookup(mysql_columns.value, "ordinal_position", null)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  source_config {
    source_connection_profile = var.source_connection_profile
    mysql_source_config {}
  }

  destination_config {
    destination_connection_profile = var.destination_connection_profile
    bigquery_destination_config {
      source_hierarchy_datasets {
        dataset_template {
          location     = "us-central1"
          kms_key_name = "bigquery-kms-name"
        }
      }
    }
  }
}
