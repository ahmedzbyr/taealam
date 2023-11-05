
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

      dynamic "postgresql_excluded_objects" {
        for_each = lookup(var.backfill_all, "postgresql_excluded_objects", null) != null ? [var.backfill_all.postgresql_excluded_objects] : []
        content {
          dynamic "postgresql_schemas" {
            for_each = lookup(postgresql_excluded_objects.value, "postgresql_schemas", null) != null ? postgresql_excluded_objects.value.postgresql_schemas : []
            content {
              schema = postgresql_schemas.value.schema
              dynamic "postgresql_tables" {
                for_each = lookup(postgresql_schemas.value, "postgresql_tables", null) != null ? postgresql_schemas.value.postgresql_tables : []
                content {
                  table = postgresql_tables.value.table
                  dynamic "postgresql_columns" {
                    for_each = lookup(postgresql_tables.value, "postgresql_columns", "null") != null ? postgresql_tables.value.postgresql_columns : []
                    content {
                      column           = lookup(postgresql_columns.value, "column", null)
                      data_type        = lookup(postgresql_columns.value, "data_type", null)
                      primary_key      = lookup(postgresql_columns.value, "primary_key", null)
                      nullable         = lookup(postgresql_columns.value, "nullable", null)
                      ordinal_position = lookup(postgresql_columns.value, "ordinal_position", null)
                    }
                  }
                }
              }
            }
          }
        }
      }

      dynamic "oracle_excluded_objects" {
        for_each = lookup(var.backfill_all, "oracle_excluded_objects", null) != null ? [var.backfill_all.oracle_excluded_objects] : []
        content {
          dynamic "oracle_schemas" {
            for_each = lookup(oracle_excluded_objects.value, "oracle_schemas", null) != null ? oracle_excluded_objects.value.oracle_schemas : []
            content {
              schema = oracle_schemas.value.schema
              dynamic "oracle_tables" {
                for_each = lookup(oracle_schemas.value, "oracle_tables", null) != null ? oracle_schemas.value.oracle_tables : []
                content {
                  table = oracle_tables.value.table
                  dynamic "oracle_columns" {
                    for_each = lookup(oracle_tables.value, "oracle_columns", "null") != null ? oracle_tables.value.oracle_columns : []
                    content {
                      column    = lookup(oracle_columns.value, "column", null)
                      data_type = lookup(oracle_columns.value, "data_type", null) # The Oracle data type. Full data types list can be found here: https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Data-Types.html
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
    dynamic "mysql_source_config" {
      for_each = var.mysql_source_config != null ? [var.mysql_source_config] : []
      content {
        max_concurrent_cdc_tasks      = lookup(mysql_source_config.value, "max_concurrent_cdc_tasks", null)
        max_concurrent_backfill_tasks = lookup(mysql_source_config.value, "max_concurrent_backfill_tasks", null)

        dynamic "include_objects" {
          for_each = lookup(mysql_source_config.value, "include_objects", null) != null ? [mysql_source_config.value.include_objects] : []
          content {
            dynamic "mysql_databases" {
              for_each = lookup(include_objects.value, "mysql_databases", null) != null ? include_objects.value.mysql_databases : []
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

        dynamic "exclude_objects" {
          for_each = lookup(mysql_source_config.value, "exclude_objects", null) != null ? [mysql_source_config.value.exclude_objects] : []
          content {
            dynamic "mysql_databases" {
              for_each = lookup(exclude_objects.value, "mysql_databases", null) != null ? exclude_objects.value.mysql_databases : []
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



    dynamic "oracle_source_config" {
      for_each = var.oracle_source_config != null ? [var.oracle_source_config] : []
      content {
        max_concurrent_cdc_tasks      = lookup(oracle_source_config.value, "max_concurrent_cdc_tasks", null)
        max_concurrent_backfill_tasks = lookup(oracle_source_config.value, "max_concurrent_backfill_tasks", null)

        dynamic "drop_large_objects" {
          for_each = lookup(oracle_source_config.value, "drop_large_objects", null) != null ? [1] : []
          content {}
        }

        dynamic "stream_large_objects" {
          for_each = lookup(oracle_source_config.value, "stream_large_objects", null) != null ? [1] : []
          content {}
        }

        dynamic "include_objects" {
          for_each = lookup(oracle_source_config.value, "include_objects", null) != null ? [oracle_source_config.value.include_objects] : []
          content {
            dynamic "oracle_schemas" {
              for_each = lookup(include_objects.value, "oracle_schemas", null) != null ? include_objects.value.oracle_schemas : []
              content {
                schema = oracle_schemas.value.schema
                dynamic "oracle_tables" {
                  for_each = lookup(oracle_schemas.value, "oracle_tables", null) != null ? oracle_schemas.value.oracle_tables : []
                  content {
                    table = oracle_tables.value.table
                    dynamic "oracle_columns" {
                      for_each = lookup(oracle_tables.value, "oracle_columns", "null") != null ? oracle_tables.value.oracle_columns : []
                      content {
                        column    = lookup(oracle_columns.value, "column", null)
                        data_type = lookup(oracle_columns.value, "data_type", null) # The Oracle data type. Full data types list can be found here: https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Data-Types.html
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "exclude_objects" {
          for_each = lookup(oracle_source_config.value, "exclude_objects", null) != null ? [oracle_source_config.value.exclude_objects] : []
          content {
            dynamic "oracle_schemas" {
              for_each = lookup(exclude_objects.value, "oracle_schemas", null) != null ? exclude_objects.value.oracle_schemas : []
              content {
                schema = oracle_schemas.value.schema
                dynamic "oracle_tables" {
                  for_each = lookup(oracle_schemas.value, "oracle_tables", null) != null ? oracle_schemas.value.oracle_tables : []
                  content {
                    table = oracle_tables.value.table
                    dynamic "oracle_columns" {
                      for_each = lookup(oracle_tables.value, "oracle_columns", "null") != null ? oracle_tables.value.oracle_columns : []
                      content {
                        column    = lookup(oracle_columns.value, "column", null)
                        data_type = lookup(oracle_columns.value, "data_type", null) # The Oracle data type. Full data types list can be found here: https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Data-Types.html
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


    dynamic "postgresql_source_config" {
      for_each = var.postgresql_source_config != null ? [var.postgresql_source_config] : []
      content {
        replication_slot              = postgresql_source_config.value.replication_slot
        publication                   = postgresql_source_config.value.publication
        max_concurrent_backfill_tasks = lookup(postgresql_source_config.value, "max_concurrent_backfill_tasks", null)

        dynamic "include_objects" {
          for_each = lookup(postgresql_source_config.value, "include_objects", null) != null ? [postgresql_source_config.value.include_objects] : []
          content {
            dynamic "postgresql_schemas" {
              for_each = lookup(include_objects.value, "postgresql_schemas", null) != null ? include_objects.value.postgresql_schemas : []
              content {
                schema = postgresql_schemas.value.schema
                dynamic "postgresql_tables" {
                  for_each = lookup(postgresql_schemas.value, "postgresql_tables", null) != null ? postgresql_schemas.value.postgresql_tables : []
                  content {
                    table = postgresql_tables.value.table
                    dynamic "postgresql_columns" {
                      for_each = lookup(postgresql_tables.value, "postgresql_columns", "null") != null ? postgresql_tables.value.postgresql_columns : []
                      content {
                        column           = lookup(postgresql_columns.value, "column", null)
                        data_type        = lookup(postgresql_columns.value, "data_type", null)
                        primary_key      = lookup(postgresql_columns.value, "primary_key", null)
                        nullable         = lookup(postgresql_columns.value, "nullable", null)
                        ordinal_position = lookup(postgresql_columns.value, "ordinal_position", null)
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "exclude_objects" {
          for_each = lookup(postgresql_source_config.value, "exclude_objects", null) != null ? [postgresql_source_config.value.exclude_objects] : []
          content {
            dynamic "postgresql_schemas" {
              for_each = lookup(exclude_objects.value, "postgresql_schemas", null) != null ? exclude_objects.value.postgresql_schemas : []
              content {
                schema = postgresql_schemas.value.schema
                dynamic "postgresql_tables" {
                  for_each = lookup(postgresql_schemas.value, "postgresql_tables", null) != null ? postgresql_schemas.value.postgresql_tables : []
                  content {
                    table = postgresql_tables.value.table
                    dynamic "postgresql_columns" {
                      for_each = lookup(postgresql_tables.value, "postgresql_columns", "null") != null ? postgresql_tables.value.postgresql_columns : []
                      content {
                        column           = lookup(postgresql_columns.value, "column", null)
                        data_type        = lookup(postgresql_columns.value, "data_type", null)
                        primary_key      = lookup(postgresql_columns.value, "primary_key", null)
                        nullable         = lookup(postgresql_columns.value, "nullable", null)
                        ordinal_position = lookup(postgresql_columns.value, "ordinal_position", null)
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
  }

  destination_config {
    destination_connection_profile = var.destination_connection_profile
    dynamic "gcs_destination_config" {
      for_each = var.gcs_destination_config != null ? [var.gcs_destination_config] : []
      content {
        path                   = lookup(gcs_destination_config.value, "path", null)
        file_rotation_mb       = lookup(gcs_destination_config.value, "file_rotation_mb", null)
        file_rotation_interval = lookup(gcs_destination_config.value, "file_rotation_interval", null)
        dynamic "avro_file_format" {
          for_each = lookup(gcs_destination_config.value, "avro_file_format", null) != null ? [1] : []
          content {}
        }
        dynamic "json_file_format" {
          for_each = lookup(gcs_destination_config.value, "json_file_format", null) != null ? [gcs_destination_config.value.json_file_format] : []
          content {
            schema_file_format = lookup(json_file_format.value, "schema_file_format", null)
            compression        = lookup(json_file_format.value, "compression", null)
          }
        }
      }
    }

    dynamic "bigquery_destination_config" {
      for_each = var.bigquery_destination_config != null ? [var.bigquery_destination_config] : []
      content {
        data_freshness = lookup(bigquery_destination_config.value, "data_freshness", null)
        dynamic "single_target_dataset" {
          for_each = lookup(bigquery_destination_config.value, "single_target_dataset", null) != null ? [bigquery_destination_config.value.single_target_dataset] : []
          content {
            dataset_id = single_target_dataset.value.dataset_id
          }
        }
        dynamic "source_hierarchy_datasets" {
          for_each = lookup(bigquery_destination_config.value, "source_hierarchy_datasets", null) != null ? [bigquery_destination_config.value.source_hierarchy_datasets] : []
          content {
            dynamic "dataset_template" {
              for_each = lookup(source_hierarchy_datasets.value, "dataset_template", null) != null ? [source_hierarchy_datasets.value.dataset_template] : []
              content {
                location          = dataset_template.value.location
                dataset_id_prefix = lookup(dataset_template.value, "dataset_id_prefix", null)
                kms_key_name      = lookup(dataset_template.value, "kms_key_name", null)
              }
            }
          }
        }
      }
    }
  }
}
