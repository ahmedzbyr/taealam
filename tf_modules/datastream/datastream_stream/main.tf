
# Define a Google Datastream resource to create and manage a data stream.
resource "google_datastream_stream" "main" {
  # General settings for the data stream
  project                         = var.project                         # The GCP project ID where the data stream is created
  display_name                    = var.display_name                    # The display name of the data stream
  stream_id                       = var.stream_id                       # Identifier for the data stream
  location                        = var.location                        # Location (region) where the data stream is created
  labels                          = var.labels                          # A set of key/value label pairs to assign to the data stream
  customer_managed_encryption_key = var.customer_managed_encryption_key # Customer-managed encryption key used to encrypt the data stream
  desired_state                   = var.desired_state                   # Desired state of the data stream ("RUNNING" or "PAUSED")

  # Configuration for no backfill, conditionally included if specified
  dynamic "backfill_none" {
    for_each = var.backfill_none && var.backfill_all == null ? [1] : [] # If backfill_none is true and backfill_all is not specified, include this block
    content {}
  }


  # Configuration for backfilling all data, conditionally included if specified
  dynamic "backfill_all" {
    for_each = var.backfill_all != null ? [var.backfill_all] : [] # Include this block if backfill_all is specified
    content {
      # Exclude specific MySQL objects from backfill, conditionally included if specified
      dynamic "mysql_excluded_objects" {
        for_each = lookup(var.backfill_all, "mysql_excluded_objects", null) != null ? [var.backfill_all.mysql_excluded_objects] : []
        content {
          # Exclude specific MySQL databases from backfill
          dynamic "mysql_databases" {
            for_each = lookup(mysql_excluded_objects.value, "mysql_databases", null) != null ? mysql_excluded_objects.value.mysql_databases : []
            content {
              database = mysql_databases.value.database # The database to exclude from backfill
              # Exclude specific MySQL tables from backfill
              dynamic "mysql_tables" {
                for_each = lookup(mysql_databases.value, "mysql_tables", null) != null ? mysql_databases.value.mysql_tables : []
                content {
                  table = mysql_tables.value.table # The table to exclude from backfill
                  # Exclude specific MySQL columns from backfill
                  dynamic "mysql_columns" {
                    for_each = lookup(mysql_tables.value, "mysql_columns", "null") != null ? mysql_tables.value.mysql_columns : []
                    content {
                      column           = lookup(mysql_columns.value, "column", null)           # The column to exclude from backfill
                      data_type        = lookup(mysql_columns.value, "data_type", null)        # The data type of the column
                      collation        = lookup(mysql_columns.value, "collation", null)        # The collation of the column
                      primary_key      = lookup(mysql_columns.value, "primary_key", null)      # Whether the column is a primary key
                      nullable         = lookup(mysql_columns.value, "nullable", null)         # Whether the column is nullable
                      ordinal_position = lookup(mysql_columns.value, "ordinal_position", null) # The position of the column in the table
                    }
                  }
                }
              }
            }
          }
        }
      }

      # Conditional block for defining PostgreSQL objects to be excluded from data backfill
      dynamic "postgresql_excluded_objects" {
        # Include this block if 'postgresql_excluded_objects' is defined in 'backfill_all'
        for_each = lookup(var.backfill_all, "postgresql_excluded_objects", null) != null ? [var.backfill_all.postgresql_excluded_objects] : []
        content {
          # Nested conditional block for defining PostgreSQL schemas to be excluded
          dynamic "postgresql_schemas" {
            # Iterate over defined schemas in 'postgresql_excluded_objects'
            for_each = lookup(postgresql_excluded_objects.value, "postgresql_schemas", null) != null ? postgresql_excluded_objects.value.postgresql_schemas : []
            content {
              schema = postgresql_schemas.value.schema # The schema name to be excluded from backfill

              # Further nested block to define tables within the excluded PostgreSQL schemas
              dynamic "postgresql_tables" {
                # Iterate over tables defined within the 'postgresql_schemas'
                for_each = lookup(postgresql_schemas.value, "postgresql_tables", null) != null ? postgresql_schemas.value.postgresql_tables : []
                content {
                  table = postgresql_tables.value.table # The table name to be excluded from backfill

                  # Innermost block to define columns within the excluded PostgreSQL tables
                  dynamic "postgresql_columns" {
                    # Iterate over columns defined within the 'postgresql_tables'
                    for_each = lookup(postgresql_tables.value, "postgresql_columns", "null") != null ? postgresql_tables.value.postgresql_columns : []
                    content {
                      column           = lookup(postgresql_columns.value, "column", null)           # The column name to be excluded from backfill
                      data_type        = lookup(postgresql_columns.value, "data_type", null)        # The data type of the column
                      primary_key      = lookup(postgresql_columns.value, "primary_key", null)      # Boolean indicating if the column is part of the primary key
                      nullable         = lookup(postgresql_columns.value, "nullable", null)         # Boolean indicating if the column can contain NULL values
                      ordinal_position = lookup(postgresql_columns.value, "ordinal_position", null) # The ordinal position of the column in the table
                    }
                  }
                }
              }
            }
          }
        }
      }


      # A dynamic block for specifying Oracle objects to exclude during data backfill operations
      dynamic "oracle_excluded_objects" {
        # Conditionally create this block if 'oracle_excluded_objects' is specified within the 'backfill_all' variable
        for_each = lookup(var.backfill_all, "oracle_excluded_objects", null) != null ? [var.backfill_all.oracle_excluded_objects] : []
        content {
          # Nested dynamic block for specifying schemas to exclude from the Oracle database
          dynamic "oracle_schemas" {
            # Iterate over the list of schemas provided in the 'oracle_excluded_objects' map
            for_each = lookup(oracle_excluded_objects.value, "oracle_schemas", null) != null ? oracle_excluded_objects.value.oracle_schemas : []
            content {
              schema = oracle_schemas.value.schema # The name of the Oracle schema to be excluded from data backfill

              # Further nested dynamic block for specifying tables within the excluded Oracle schemas
              dynamic "oracle_tables" {
                # Iterate over the list of tables provided within each specified schema
                for_each = lookup(oracle_schemas.value, "oracle_tables", null) != null ? oracle_schemas.value.oracle_tables : []
                content {
                  table = oracle_tables.value.table # The name of the Oracle table to be excluded from data backfill

                  # Innermost dynamic block to define columns within the excluded Oracle tables
                  dynamic "oracle_columns" {
                    # Iterate over columns specified for exclusion within each table
                    for_each = lookup(oracle_tables.value, "oracle_columns", "null") != null ? oracle_tables.value.oracle_columns : []
                    content {
                      column    = lookup(oracle_columns.value, "column", null)    # The name of the Oracle column to be excluded from data backfill
                      data_type = lookup(oracle_columns.value, "data_type", null) # Specifies the data type of the column
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

    # Source connection profile this is required for the confgiuration. 
    source_connection_profile = var.source_connection_profile
    # A dynamic block to configure MySQL source settings for a data synchronization task
    dynamic "mysql_source_config" {
      # Check if a MySQL source configuration is provided, otherwise set an empty list
      for_each = var.mysql_source_config != null ? [var.mysql_source_config] : []
      content {
        # Maximum number of concurrent CDC (Change Data Capture) tasks
        max_concurrent_cdc_tasks = lookup(mysql_source_config.value, "max_concurrent_cdc_tasks", null)
        # Maximum number of concurrent backfill tasks
        max_concurrent_backfill_tasks = lookup(mysql_source_config.value, "max_concurrent_backfill_tasks", null)

        # Dynamic block to specify which MySQL objects to include in synchronization
        dynamic "include_objects" {
          # If 'include_objects' is specified, create a list with that element, otherwise an empty list
          for_each = lookup(mysql_source_config.value, "include_objects", null) != null ? [mysql_source_config.value.include_objects] : []
          content {
            # Dynamic block for specifying databases to include
            dynamic "mysql_databases" {
              # If 'mysql_databases' is specified under 'include_objects', iterate over the list, otherwise use an empty list
              for_each = lookup(include_objects.value, "mysql_databases", null) != null ? include_objects.value.mysql_databases : []
              content {
                # The database name to include
                database = mysql_databases.value.database

                # Dynamic block for specifying tables within included databases
                dynamic "mysql_tables" {
                  # Iterate over the list of tables provided for the current database, if any
                  for_each = lookup(mysql_databases.value, "mysql_tables", null) != null ? mysql_databases.value.mysql_tables : []
                  content {
                    # The table name to include
                    table = mysql_tables.value.table

                    # Dynamic block to define columns within the included MySQL tables
                    dynamic "mysql_columns" {
                      # Iterate over columns specified for inclusion within each table, if any
                      for_each = lookup(mysql_tables.value, "mysql_columns", "null") != null ? mysql_tables.value.mysql_columns : []
                      content {
                        # The column name to include
                        column = lookup(mysql_columns.value, "column", null)
                        # The data type of the column
                        data_type = lookup(mysql_columns.value, "data_type", null)
                        # The collation setting of the column
                        collation = lookup(mysql_columns.value, "collation", null)
                        # Whether the column is part of the primary key
                        primary_key = lookup(mysql_columns.value, "primary_key", null)
                        # Whether the column is nullable
                        nullable = lookup(mysql_columns.value, "nullable", null)
                        # The ordinal position of the column within the table
                        ordinal_position = lookup(mysql_columns.value, "ordinal_position", null)
                      }
                    }
                  }
                }
              }
            }
          }
        }

        # Dynamic block to specify which MySQL objects to exclude from synchronization
        dynamic "exclude_objects" {
          # If 'exclude_objects' is specified, create a list with that element, otherwise an empty list
          for_each = lookup(mysql_source_config.value, "exclude_objects", null) != null ? [mysql_source_config.value.exclude_objects] : []
          content {
            # Dynamic block for specifying databases to exclude
            dynamic "mysql_databases" {
              # If 'mysql_databases' is specified under 'exclude_objects', iterate over the list, otherwise use an empty list
              for_each = lookup(exclude_objects.value, "mysql_databases", null) != null ? exclude_objects.value.mysql_databases : []
              content {
                # The database name to exclude
                database = mysql_databases.value.database

                # Dynamic block for specifying tables within excluded databases
                dynamic "mysql_tables" {
                  # Iterate over the list of tables provided for the current database, if any
                  for_each = lookup(mysql_databases.value, "mysql_tables", null) != null ? mysql_databases.value.mysql_tables : []
                  content {
                    # The table name to exclude
                    table = mysql_tables.value.table

                    # Dynamic block to define columns within the excluded MySQL tables
                    dynamic "mysql_columns" {
                      # Iterate over columns specified for exclusion within each table, if any
                      for_each = lookup(mysql_tables.value, "mysql_columns", "null") != null ? mysql_tables.value.mysql_columns : []
                      content {
                        # The column name to exclude
                        column = lookup(mysql_columns.value, "column", null)
                        # The data type of the column
                        data_type = lookup(mysql_columns.value, "data_type", null)
                        # The collation setting of the column
                        collation = lookup(mysql_columns.value, "collation", null)
                        # Whether the column is part of the primary key
                        primary_key = lookup(mysql_columns.value, "primary_key", null)
                        # Whether the column is nullable
                        nullable = lookup(mysql_columns.value, "nullable", null)
                        # The ordinal position of the column within the table
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




    # A dynamic block that configures Oracle source settings for a data synchronization task
    dynamic "oracle_source_config" {
      # Determines if an Oracle source configuration has been provided and acts accordingly
      for_each = var.oracle_source_config != null ? [var.oracle_source_config] : []

      content {
        # Specifies the maximum number of concurrent CDC (Change Data Capture) tasks
        max_concurrent_cdc_tasks = lookup(oracle_source_config.value, "max_concurrent_cdc_tasks", null)
        # Specifies the maximum number of concurrent backfill tasks
        max_concurrent_backfill_tasks = lookup(oracle_source_config.value, "max_concurrent_backfill_tasks", null)

        # A flag to drop large objects, possibly for performance optimization
        dynamic "drop_large_objects" {
          # Activates dropping large objects if configured in the source settings
          for_each = lookup(oracle_source_config.value, "drop_large_objects", null) != null ? [1] : []
          content {}
        }

        # A flag to stream large objects, which may be useful for handling BLOB/CLOB data types
        dynamic "stream_large_objects" {
          # Activates streaming large objects if configured in the source settings
          for_each = lookup(oracle_source_config.value, "stream_large_objects", null) != null ? [1] : []
          content {}
        }

        # Dynamic block to specify which Oracle objects to include in synchronization
        dynamic "include_objects" {
          # If 'include_objects' is specified, creates a configuration block for those objects
          for_each = lookup(oracle_source_config.value, "include_objects", null) != null ? [oracle_source_config.value.include_objects] : []
          content {
            # Dynamic block for specifying Oracle schemas to include
            dynamic "oracle_schemas" {
              # Iterates over the schemas provided in the 'include_objects' if any
              for_each = lookup(include_objects.value, "oracle_schemas", null) != null ? include_objects.value.oracle_schemas : []
              content {
                # Specifies the schema name to include in the synchronization
                schema = oracle_schemas.value.schema

                # Dynamic block for specifying tables within the included Oracle schemas
                dynamic "oracle_tables" {
                  # Iterates over the tables provided for the current schema, if any
                  for_each = lookup(oracle_schemas.value, "oracle_tables", null) != null ? oracle_schemas.value.oracle_tables : []
                  content {
                    # Specifies the table name to include in the synchronization
                    table = oracle_tables.value.table

                    # Dynamic block to define columns within the included Oracle tables
                    dynamic "oracle_columns" {
                      # Iterates over columns specified for inclusion within each table, if any
                      for_each = lookup(oracle_tables.value, "oracle_columns", "null") != null ? oracle_tables.value.oracle_columns : []
                      content {
                        # The column name to include
                        column = lookup(oracle_columns.value, "column", null)
                        # The data type of the column
                        data_type = lookup(oracle_columns.value, "data_type", null)
                      }
                    }
                  }
                }
              }
            }
          }
        }

        # Dynamic block to specify which Oracle objects to exclude from synchronization
        dynamic "exclude_objects" {
          # If 'exclude_objects' is specified, creates a configuration block for those objects
          for_each = lookup(oracle_source_config.value, "exclude_objects", null) != null ? [oracle_source_config.value.exclude_objects] : []
          content {
            # Dynamic block for specifying Oracle schemas to exclude
            dynamic "oracle_schemas" {
              # Iterates over the schemas provided in the 'exclude_objects' if any
              for_each = lookup(exclude_objects.value, "oracle_schemas", null) != null ? exclude_objects.value.oracle_schemas : []
              content {
                # Specifies the schema name to exclude from the synchronization
                schema = oracle_schemas.value.schema

                # Dynamic block for specifying tables within the excluded Oracle schemas
                dynamic "oracle_tables" {
                  # Iterates over the tables provided for the current schema, if any
                  for_each = lookup(oracle_schemas.value, "oracle_tables", null) != null ? oracle_schemas.value.oracle_tables : []
                  content {
                    # Specifies the table name to exclude from the synchronization
                    table = oracle_tables.value.table

                    # Dynamic block to define columns within the excluded Oracle tables
                    dynamic "oracle_columns" {
                      # Iterates over columns specified for exclusion within each table, if any
                      for_each = lookup(oracle_tables.value, "oracle_columns", "null") != null ? oracle_tables.value.oracle_columns : []
                      content {
                        # The column name to exclude
                        column = lookup(oracle_columns.value, "column", null)
                        # The data type of the column
                        data_type = lookup(oracle_columns.value, "data_type", null)
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



    # Define a dynamic block for PostgreSQL source configuration settings.
    dynamic "postgresql_source_config" {
      # Determine if PostgreSQL source configuration is provided and iterate over it if not null.
      for_each = var.postgresql_source_config != null ? [var.postgresql_source_config] : []

      # The content of the PostgreSQL source configuration.
      content {
        # Assign replication slot name from the configuration variable.
        replication_slot = postgresql_source_config.value.replication_slot
        # Assign publication name from the configuration variable.
        publication = postgresql_source_config.value.publication
        # Set the maximum number of concurrent backfill tasks from the configuration or default to null if not specified.
        max_concurrent_backfill_tasks = lookup(postgresql_source_config.value, "max_concurrent_backfill_tasks", null)

        # Define a dynamic block to specify which database objects to include in synchronization.
        dynamic "include_objects" {
          # Evaluate if 'include_objects' is specified in the configuration and iterate over it if so.
          for_each = lookup(postgresql_source_config.value, "include_objects", null) != null ? [postgresql_source_config.value.include_objects] : []

          # The content for included database objects.
          content {
            # Define a dynamic block for including specific PostgreSQL schemas.
            dynamic "postgresql_schemas" {
              # Check if there are schemas specified to be included and iterate over them.
              for_each = lookup(include_objects.value, "postgresql_schemas", null) != null ? include_objects.value.postgresql_schemas : []

              # The content for included schemas.
              content {
                # Set the schema name from the configuration to include it in synchronization.
                schema = postgresql_schemas.value.schema

                # Define a dynamic block for including specific tables within the schema.
                dynamic "postgresql_tables" {
                  # Check if there are tables specified within the current schema to be included and iterate over them.
                  for_each = lookup(postgresql_schemas.value, "postgresql_tables", null) != null ? postgresql_schemas.value.postgresql_tables : []

                  # The content for included tables.
                  content {
                    # Set the table name from the configuration to include it in synchronization.
                    table = postgresql_tables.value.table

                    # Define a dynamic block for including specific columns within the table.
                    dynamic "postgresql_columns" {
                      # Check if there are columns specified within the current table to be included and iterate over them.
                      for_each = lookup(postgresql_tables.value, "postgresql_columns", "null") != null ? postgresql_tables.value.postgresql_columns : []

                      # The content for included columns.
                      content {
                        # Set the column name from the configuration to include it in synchronization.
                        column = lookup(postgresql_columns.value, "column", null)
                        # Set the data type of the column from the configuration.
                        data_type = lookup(postgresql_columns.value, "data_type", null)
                        # Indicate whether the column is a primary key based on the configuration.
                        primary_key = lookup(postgresql_columns.value, "primary_key", null)
                        # Indicate whether the column is nullable based on the configuration.
                        nullable = lookup(postgresql_columns.value, "nullable", null)
                        # Set the ordinal position of the column within the table from the configuration.
                        ordinal_position = lookup(postgresql_columns.value, "ordinal_position", null)
                      }
                    }
                  }
                }
              }
            }
          }
        }

        # Define a dynamic block to specify which database objects to exclude from synchronization.
        dynamic "exclude_objects" {
          # Evaluate if 'exclude_objects' is specified in the configuration and iterate over it if so.
          for_each = lookup(postgresql_source_config.value, "exclude_objects", null) != null ? [postgresql_source_config.value.exclude_objects] : []

          # The content for excluded database objects.
          content {
            # Define a dynamic block for excluding specific PostgreSQL schemas.
            dynamic "postgresql_schemas" {
              # Check if there are schemas specified to be excluded and iterate over them.
              for_each = lookup(exclude_objects.value, "postgresql_schemas", null) != null ? exclude_objects.value.postgresql_schemas : []

              # The content for excluded schemas.
              content {
                # Set the schema name from the configuration to exclude it from synchronization.
                schema = postgresql_schemas.value.schema

                # Define a dynamic block for excluding specific tables within the schema.
                dynamic "postgresql_tables" {
                  # Check if there are tables specified within the current schema to be excluded and iterate over them.
                  for_each = lookup(postgresql_schemas.value, "postgresql_tables", null) != null ? postgresql_schemas.value.postgresql_tables : []

                  # The content for excluded tables.
                  content {
                    # Set the table name from the configuration to exclude it from synchronization.
                    table = postgresql_tables.value.table

                    # Define a dynamic block for excluding specific columns within the table.
                    dynamic "postgresql_columns" {
                      # Check if there are columns specified within the current table to be excluded and iterate over them.
                      for_each = lookup(postgresql_tables.value, "postgresql_columns", "null") != null ? postgresql_tables.value.postgresql_columns : []

                      # The content for excluded columns.
                      content {
                        # Set the column name from the configuration to exclude it from synchronization.
                        column = lookup(postgresql_columns.value, "column", null)
                        # Set the data type of the column from the configuration.
                        data_type = lookup(postgresql_columns.value, "data_type", null)
                        # Indicate whether the column is a primary key based on the configuration.
                        primary_key = lookup(postgresql_columns.value, "primary_key", null)
                        # Indicate whether the column is nullable based on the configuration.
                        nullable = lookup(postgresql_columns.value, "nullable", null)
                        # Set the ordinal position of the column within the table from the configuration.
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


  # Configuration block defining settings for data transfer to the destination.
  destination_config {
    # Reference to a predefined destination connection profile variable.
    destination_connection_profile = var.destination_connection_profile

    # Dynamic block to configure Google Cloud Storage (GCS) as the destination.
    dynamic "gcs_destination_config" {
      # If GCS destination configuration is provided, iterate over it; otherwise, provide an empty list.
      for_each = var.gcs_destination_config != null ? [var.gcs_destination_config] : []

      # The content of the GCS destination configuration.
      content {
        # The path in GCS where data will be stored.
        path = lookup(gcs_destination_config.value, "path", null)
        # The file size at which to rotate to a new file.
        file_rotation_mb = lookup(gcs_destination_config.value, "file_rotation_mb", null)
        # The time interval at which to rotate to a new file.
        file_rotation_interval = lookup(gcs_destination_config.value, "file_rotation_interval", null)

        # Optional dynamic block to specify the AVRO file format if used.
        dynamic "avro_file_format" {
          # If AVRO file format is specified, iterate with a dummy list to include the block.
          for_each = lookup(gcs_destination_config.value, "avro_file_format", null) != null ? [1] : []
          # Content block for AVRO format specifics would be defined here.
          content {}
        }

        # Optional dynamic block to specify the JSON file format if used.
        dynamic "json_file_format" {
          # If JSON file format is specified, iterate over it.
          for_each = lookup(gcs_destination_config.value, "json_file_format", null) != null ? [gcs_destination_config.value.json_file_format] : []

          # The content of the JSON file format configuration.
          content {
            # The format of the schema used for the JSON files.
            schema_file_format = lookup(json_file_format.value, "schema_file_format", null)
            # The type of compression used for the JSON files.
            compression = lookup(json_file_format.value, "compression", null)
          }
        }
      }
    }

    # Dynamic block to configure BigQuery as the destination.
    dynamic "bigquery_destination_config" {
      # If BigQuery destination configuration is provided, iterate over it; otherwise, provide an empty list.
      for_each = var.bigquery_destination_config != null ? [var.bigquery_destination_config] : []

      # The content of the BigQuery destination configuration.
      content {
        # The maximum staleness of the data accepted for writes.
        data_freshness = lookup(bigquery_destination_config.value, "data_freshness", null)

        # Optional dynamic block to specify a single target dataset for BigQuery.
        dynamic "single_target_dataset" {
          # If a single target dataset is specified, iterate over it.
          for_each = lookup(bigquery_destination_config.value, "single_target_dataset", null) != null ? [bigquery_destination_config.value.single_target_dataset] : []

          # The content of the single target dataset configuration.
          content {
            # The ID of the dataset in BigQuery where data will be written.
            dataset_id = single_target_dataset.value.dataset_id
          }
        }

        # Optional dynamic block to configure datasets based on the source hierarchy.
        dynamic "source_hierarchy_datasets" {
          # If source hierarchy datasets are specified, iterate over them.
          for_each = lookup(bigquery_destination_config.value, "source_hierarchy_datasets", null) != null ? [bigquery_destination_config.value.source_hierarchy_datasets] : []

          # The content of the source hierarchy datasets configuration.
          content {
            # Dynamic block for specifying the template for new datasets.
            dynamic "dataset_template" {
              # If a dataset template is specified, iterate over it.
              for_each = lookup(source_hierarchy_datasets.value, "dataset_template", null) != null ? [source_hierarchy_datasets.value.dataset_template] : []

              # The content of the dataset template configuration.
              content {
                # The location where the new datasets will be created.
                location = dataset_template.value.location
                # Prefix to be used for new dataset IDs.
                dataset_id_prefix = lookup(dataset_template.value, "dataset_id_prefix", null)
                # The Cloud KMS key to be used for encrypting the new datasets.
                kms_key_name = lookup(dataset_template.value, "kms_key_name", null)
              }
            }
          }
        }
      }
    }
  }
}
