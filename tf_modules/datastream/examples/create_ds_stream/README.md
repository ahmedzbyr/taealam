# Creating a Datastream Stream: MySQL to BigQuery

This guide walks through the process of setting up a Datastream stream, which facilitates the transfer of data from a MySQL database to a BigQuery dataset.

- [Creating a Datastream Stream: MySQL to BigQuery](#creating-a-datastream-stream-mysql-to-bigquery)
  - [Configuration Parameters](#configuration-parameters)
  - [Backfill Configuration - Handling Historical Data](#backfill-configuration---handling-historical-data)
  - [CMEK - Stream Encryption (Optional)](#cmek---stream-encryption-optional)
  - [ Stream Status](#stream-status)
  - [Source Configuration](#source-configuration)
    - [ MySQL data source configuration](#mysql-data-source-configuration)
    - [ Oracle data source configuration.](#oracle-data-source-configuration)
    - [PostgreSQL data source configuration](#postgresql-data-source-configuration)
  - [ Destination Configuration](#destination-configuration)
    - [GCS Bucket](#gcs-bucket)
    - [Bigquery Dataset](#bigquery-dataset)
  - [Example](#example)



## Configuration Parameters

Below are few of the variables which are required.

```hcl
  # Specify the GCP project ID
  project = "elevated-column-400011"

  # Set a human-readable name for the Datastream stream
  display_name = "ahmed-ds-stream"

  # Unique identifier for the Datastream stream
  stream_id = "ahmed-ds-stream"

  # The location where the Datastream resource will be created
  location = "us-east1"

  # Labels are key/value pairs for tagging and organizing GCP resources
  labels = {
    key = "some_value"
  }
```

## Backfill Configuration - Handling Historical Data

We can give only one of the below configurations not both.

If `backfill_none = true` then `backfill_all` should not be provided.

```hcl
  # Backfill configuration to determine how historical data is handled
  backfill_none = false # If false, historical data is not excluded from the stream
  backfill_all = {
    # Specify any databases and tables to exclude from backfilling
    mysql_excluded_objects = {
      mysql_databases = [
        {
          # Name of the database to exclude from backfill
          database = "ahmed"
          mysql_tables = [
            {
              # Specific tables within the 'ahmed' database to exclude
              table = "atable"
              # Specify columns within 'atable' to exclude from backfill
              mysql_columns = [{ column = "amycol" }]
            },
            {
              # Another table within the 'ahmed' database to exclude
              table = "btable"
              # Specify columns within 'btable' to exclude from backfill
              mysql_columns = [{ column = "bmycol" }]
            }
          ]
        }
      ]
    }
  }
```

## CMEK - Stream Encryption (Optional)

- (Optional) A reference to a KMS encryption key.
- If provided, it will be used to encrypt the data.
- If left blank, data will be encrypted using an internal Stream-specific encryption key provisioned through KMS.

```hcl
customer_managed_encryption_key = "key" # Optional
```

##  Stream Status

- (Optional) Desired state of the Stream.
- Set this field to RUNNING to start the stream, and PAUSED to pause the stream.

```hcl
  # Desired state of the Datastream stream, e.g., "RUNNING" or "PAUSED"
  desired_state = "RUNNING"
```

## Source Configuration

We have give 3 types of source configurations

- MySQL
- PostgreSQL
- Oracle

```hcl
  # Configuration for the source connection profile
  # Replace {project}, {location}, and {name} with appropriate values
  source_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  mysql_source_config       = {} # Placeholder for MySQL source-specific configuration
```

###  MySQL data source configuration
  
:books: **NOTE:** All settings are optional and should be configured as needed:

- `include_objects` - Specifies which MySQL objects to include.
- `exclude_objects` - Specifies which MySQL objects to exclude.
- `max_concurrent_cdc_tasks` - Sets the max number of concurrent CDC tasks.
- `max_concurrent_backfill_tasks` - Sets the max number of concurrent backfill tasks.


**`include_objects` and `exclude_objects`**

```hcl
  {
    *clude_objects = {
      mysql_databases = [{
        database     = string
        mysql_tables = [{
          table         = string
          mysql_columns = [{
            column           = string
            data_type        = string
            collation        = string
            primary_key      = boolean
            nullable         = boolean
            ordinal_position = integer
          }]
        }]
      }]
    }
  } 
```

###  Oracle data source configuration.

:books: **NOTE:** Configure Oracle sources similarly, including optional settings for excluding objects and setting task limits.

- `include_objects` - Oracle objects to retrieve from the source. Structure is documented below.
- `exclude_objects` - Oracle objects to exclude from the stream. Structure is documented below.
- `max_concurrent_cdc_tasks` - Maximum number of concurrent CDC tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.
- `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.
- `drop_large_objects` - Configuration to drop large object values.
- `stream_large_objects` - Configuration to drop large object values.
  
**include_objects and exclude_objects**

```hcl
{
  *clude_objects = {
    oracle_schemas = [{
      schema     = string
      oracle_tables = [{
        table         = string
        oracle_columns = [{
          column           = string
          data_type        = string
        }]
      }]
    }]
  }
} 
```

### PostgreSQL data source configuration

:books: **NOTE:** `replication_slot`and `publication` are required.

- `include_objects` - PostgreSQL objects to retrieve from the source. Structure is documented below.
- `exclude_objects` - PostgreSQL objects to exclude from the stream. Structure is documented below.
- `replication_slot` - (Required) The name of the logical replication slot that's configured with the pgoutput plugin.
- `publication` - (Required) The name of the publication that includes the set of all tables that are defined in the stream's include_objects.
- `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.

**`include_objects` and `exclude_objects`**

```hcl
{
  *clude_objects = {
    postgresql_schemas = [{
      schema     = string
      postgresql_tables = [{
        table           = string
        postgresql_columns = [{
          column           = string
          data_type        = string
          primary_key      = boolean
          nullable         = boolean
          ordinal_position = integer
        }]
      }]
    }]
  }
} 
```

##  Destination Configuration

There are 2 types of destionation we can wrtie the data to:

- GCS Bucket
- BigQuery Dataset.

Choose between GCS Bucket and BigQuery Dataset for the data destination.

```hcl
  # Configuration for the destination connection profile
  # Replace {project}, {location}, and {name} with appropriate values
  destination_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  bigquery_destination_config = {
    # Configuration for BigQuery as the destination
    single_target_dataset = {
      # ID of the BigQuery dataset to which the Datastream will write data
      dataset_id = "some:some"
    }
  }
```

### GCS Bucket

Specify how data should be stored in GCS, including file rotation and format details.

:books: **NOTE:** Union field `file_format` can be only one of the following: `avro_file_format` or `json_file_format` Either one is **required**.

A configuration for how data should be loaded to Cloud Storage.

- `path` - Path inside the Cloud Storage bucket to write data to.
- `file_rotation_mb`       - The maximum file size to be saved in the bucket.
- `file_rotation_interval` - The maximum duration for which new events are added before a file is closed and a new file is created. A duration in seconds with up to nine fractional digits, terminated by 's'. Example: "3.5s". Defaults to 900s.
- `avro_file_format` - AVRO file format configuration.
- `json_file_format` - JSON file format configuration.  

**`json_file_format`**

- `schema_file_format` - The schema file format along `JSON` data files. Possible values are: `NO_SCHEMA_FILE`, `AVRO_SCHEMA_FILE`.
- `compression`        - Compression of the loaded `JSON` file. Possible values are: `NO_COMPRESSION`, `GZIP`.

**JSON representation**

```
{
  "path": string,
  "file_rotation_mb": integer,
  "file_rotation_interval": string,

  // Union field file_format can be only one of the following:
  "avro_file_format": {}, // This type has no fields.
  "json_file_format": {
    {
      "schema_file_format": enum 
      "compression": enum 
    }
  }
  // End of list of possible types for union field file_format.
}
```  

### Bigquery Dataset

Define how data should be structured in BigQuery, including dataset template and data freshness requirements.

:books: **NOTE:** Union field `dataset_config` can be only one of the following: `single_target_dataset` or `source_hierarchy_datasets` Either one is **required**.

- `data_freshness` - The guaranteed data freshness (in seconds) when querying tables created by the stream. Editing this field will only affect new tables created in the future, but existing tables will not be impacted. Lower values mean that queries will return fresher data, but may result in higher cost. A duration in seconds with up to nine fractional digits, terminated by 's'. Example: "3.5s". Defaults to 900s.
- `single_target_dataset` - A single target dataset to which all data will be streamed. Structure is documented below.
- `source_hierarchy_datasets` - Destination datasets are created so that hierarchy of the destination data objects matches the source hierarchy. Structure is documented below.

**`single_target_dataset`**

- `dataset_id` - (Required) Dataset ID in the format `projects/{project}/datasets/{dataset_id}` or `{project}:{dataset_id}`

**`source_hierarchy_datasets`**

- `dataset_template` - (Required) Dataset template used for dynamic dataset creation.  

**`dataset_template`**

- `location` - (Required) The geographic location where the dataset should reside. See [locations](https://cloud.google.com/bigquery/docs/locations) for supported locations.
- `dataset_id_prefix` - (Optional) If supplied, every created dataset will have its name prefixed by the provided value. The prefix and name will be separated by an underscore. i.e. `_`.
- `kms_key_name` - (Optional) Describes the Cloud KMS encryption key that will be used to protect destination BigQuery table. The BigQuery Service Account associated with your project requires access to this encryption key. i.e. `projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{cryptoKey}`.

**JSON Representation**

```hcl
{
  "data_freshness": string,

  // Union field dataset_config can be only one of the following:
  "single_target_dataset": {
    dataset_id : string 
  },
  "source_hierarchy_datasets": {
    dataset_template : {
      location : string 
      dataset_id_prefix : string 
      kms_key_name : string
    }
  }
  // End of list of possible types for union field dataset_config.
}
```

## Example 

```hcl
module "create_ds_stream" {
  # Define the source module path
  source = "../../datastream_stream"

  # Specify the GCP project ID
  project = "elevated-column-400011"

  # Set a human-readable name for the Datastream stream
  display_name = "ahmed-ds-stream"

  # Unique identifier for the Datastream stream
  stream_id = "ahmed-ds-stream"

  # The location where the Datastream resource will be created
  location = "us-east1"

  # Labels are key/value pairs for tagging and organizing GCP resources
  labels = {
    key = "some_value"
  }

  # Backfill configuration to determine how historical data is handled
  backfill_none = false # If true, historical data is not excluded from the stream
  backfill_all = {
    # Specify any databases and tables to exclude from backfilling
    mysql_excluded_objects = {
      mysql_databases = [
        {
          # Name of the database to exclude from backfill
          database = "ahmed"
        }
      ]
    }
  }

  # Desired state of the Datastream stream, e.g., "RUNNING" or "PAUSED"
  desired_state = "RUNNING"

  # Configuration for the source connection profile
  # Replace {project}, {location}, and {name} with appropriate values
  source_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  mysql_source_config       = {} # Placeholder for MySQL source-specific configuration

  # Configuration for the destination connection profile
  # Replace {project}, {location}, and {name} with appropriate values
  destination_connection_profile = "projects/{project}/locations/{location}/connectionProfiles/{name}"
  bigquery_destination_config = {
    # Configuration for BigQuery as the destination
    single_target_dataset = {
      # ID of the BigQuery dataset to which the Datastream will write data
      dataset_id = "some:some"
    }
  }
}
```