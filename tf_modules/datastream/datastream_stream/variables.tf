# project - (Optional) The ID of the project in which the resource belongs. 
# If it is not provided, the provider project is used.

variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

# display_name - (Required) Display name.
variable "display_name" {
  description = "Display name."
  type        = string
}

# stream_id - (Required) The stream identifier.
variable "stream_id" {
  description = "The stream identifier."
  type        = string
}

# location - (Required) The name of the location this stream is located in.
variable "location" {
  description = "The name of the location this stream is located in."
  type        = string
  validation {
    condition = contains([
      "us-east1", "us-east5", "us-south1", "us-central1", "us-west4", "us-west2", "us-east4", "us-west1", "us-west3",
      "northamerica-northeast1", "southamerica-east1", "southamerica-west1", "northamerica-northeast2",
      "europe-west1", "europe-north1", "europe-west3", "europe-west2", "europe-southwest1", "europe-west8", "europe-west4", "europe-west9", "europe-west12", "europe-central2", "europe-west6",
      "asia-south2", "asia-east2", "asia-southeast2", "asia-south1", "asia-northeast2", "asia-northeast3", "asia-southeast1", "asia-east1", "asia-northeast1",
      "australia-southeast2", "australia-southeast1"
    ], var.location)
    error_message = "ERROR. Please check the \"location\".\nWe accept below locations:\n\nUS Locations  - \"us-east1\", \"us-east5\", \"us-south1\", \"us-central1\", \"us-west4\", \"us-west2\", \"us-east4\", \"us-west1\", \"us-west3\",\nNorth America - \"northamerica-northeast1\", \"southamerica-east1\", \"southamerica-west1\", \"northamerica-northeast2\",\nEurope        - \"europe-west1\", \"europe-north1\", \"europe-west3\", \"europe-west2\", \"europe-southwest1\", \"europe-west8\", \"europe-west4\", \"europe-west9\", \"europe-west12\", \"europe-central2\", \"europe-west6\",\nAsia          - \"asia-south2\", \"asia-east2\", \"asia-southeast2\", \"asia-south1\", \"asia-northeast2\", \"asia-northeast3\", \"asia-southeast1\", \"asia-east1\", \"asia-northeast1\",\nAustralia     - \"australia-southeast2\", \"australia-southeast1\""

  }
}

# labels - (Optional) Labels. 
#   Note: This field is non-authoritative, and will only manage the labels present in your configuration. 
#   Please refer to the field effective_labels for all of the labels present on the resource.
variable "labels" {
  description = <<-EOF
  Labels for the connection. 

  Note: This field is non-authoritative, and will only manage the labels present in your configuration. Also please refer to the field `effective_labels` for all of the labels present on the resource.
  
  `effective_labels` - All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services.
  EOF
  type        = any
}


# backfill_none - (Optional) Backfill strategy to disable automatic backfill for the Stream's objects.
# :books: **NOTE:** If enabled then `backfill_all` will be ignored or removed from the stream configuration.
variable "backfill_none" {
  description = "Backfill strategy to disable automatic backfill for the Stream's objects."
  type        = bool
  default     = false
}

# customer_managed_encryption_key - (Optional) A reference to a KMS encryption key. If provided, it will be used to encrypt the data. If left blank, data will be encrypted using an internal Stream-specific encryption key provisioned through KMS.
variable "customer_managed_encryption_key" {
  description = "A reference to a KMS encryption key. If provided, it will be used to encrypt the data. If left blank, data will be encrypted using an internal Stream-specific encryption key provisioned through KMS."
  type        = string
  default     = null
}

# desired_state - (Optional) Desired state of the Stream. Set this field to RUNNING to start the stream, and PAUSED to pause the stream.
variable "desired_state" {
  description = "Desired state of the Stream. Set this field to `RUNNING` to start the stream, and `PAUSED` to pause the stream."
  type        = string
  default     = "RUNNING"
  validation {
    condition     = contains(["RUNNING", "PAUSED"], var.desired_state)
    error_message = "ERROR. Please check \"desired_state\".\nWe can only accept \"RUNNING\" to start the stream, and \"PAUSED\" to pause the stream."
  }
}

# backfill_all - (Optional) Backfill strategy to automatically backfill the Stream's objects. Specific objects can be excluded. Structure is documented below.
variable "backfill_all" {
  description = <<-EOF
  Backfill strategy to automatically backfill the Stream's objects. Specific objects can be excluded.

  - `mysql_excluded_objects` - MySQL data source objects to avoid backfilling.
  - `postgresql_excluded_objects` - PostgreSQL data source objects to avoid backfilling.
  - `oracle_excluded_objects` - PostgreSQL data source objects to avoid backfilling. 

**`mysql_excluded_objects`**
  ```
  {
    mysql_excluded_objects = {
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

**`postgresql_excluded_objects`**
  ```
  {
    postgresql_excluded_objects = {
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

**`oracle_excluded_objects`**
  ```
  {
    oracle_excluded_objects = {
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

  EOF
  type        = any
  default     = null
  validation {
    condition = length(setsubtract(keys(var.backfill_all), [
      "mysql_excluded_objects",
      "postgresql_excluded_objects",
      "oracle_excluded_objects"
    ])) == 0
    error_message = "ERROR. Please check \"backfill_all\".\nWe only accept \"mysql_excluded_objects\", \"postgresql_excluded_objects\", \"oracle_excluded_objects\"."
  }
}

# destination_config - (Required) Destination connection profile configuration. Structure is documented below.
# destination_connection_profile - (Required) Destination connection profile resource. Format: projects/{project}/locations/{location}/connectionProfiles/{name}
variable "destination_connection_profile" {
  description = "Destination connection profile resource. Format: `projects/{project}/locations/{location}/connectionProfiles/{name}`"
  type        = any
  validation {
    condition     = length(regexall("connectionProfiles", var.destination_connection_profile)) != 0
    error_message = "ERROR. Please check \"destination_connection_profile\".\nFormat: \"projects/{project}/locations/{location}/connectionProfiles/{name}\"."
  }
}

variable "gcs_destination_config" {
  description = <<-EOF
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

  EOF
  type        = any
  default     = null
  validation {
    condition = (var.gcs_destination_config != null ? (length(setsubtract(keys(var.gcs_destination_config), [
      "path",
      "file_rotation_mb",
      "file_rotation_interval",
      "avro_file_format",
      "json_file_format"
      ])) == 0) : true && (
      var.gcs_destination_config != null ? lookup(var.gcs_destination_config, "avro_file_format", null) != null : true
      ) || (
      var.gcs_destination_config != null ? lookup(var.gcs_destination_config, "json_file_format", null) != null : true
      )) && !(
      var.gcs_destination_config != null ? lookup(var.gcs_destination_config, "avro_file_format", null) != null : false &&
      var.gcs_destination_config != null ? lookup(var.gcs_destination_config, "json_file_format", null) != null : false
    )
    error_message = "ERROR. Please check \"gcs_destination_config\".\nWe accept \"path\", \"file_rotation_mb\", \"file_rotation_interval\", \"avro_file_format\", \"json_file_format\".\nNOTE: Also ONE of \"avro_file_format\" or \"json_file_format\" is required (NOT both)."
  }
}

variable "bigquery_destination_config" {
  description = <<-EOF
  A configuration for how data should be loaded to Bigquery Dataset. 

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

  ```
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

  EOF
  type        = any
  default     = null
  validation {
    condition = (var.bigquery_destination_config != null ? (length(setsubtract(keys(var.bigquery_destination_config), [
      "data_freshness",
      "single_target_dataset",
      "source_hierarchy_datasets"
      ])) == 0) : true && (
      var.bigquery_destination_config != null ? lookup(var.bigquery_destination_config, "single_target_dataset", null) != null : true
      ) || (
      var.bigquery_destination_config != null ? lookup(var.bigquery_destination_config, "source_hierarchy_datasets", null) != null : true
      )) && !(
      var.bigquery_destination_config != null ? lookup(var.bigquery_destination_config, "single_target_dataset", null) != null : false &&
      var.bigquery_destination_config != null ? lookup(var.bigquery_destination_config, "source_hierarchy_datasets", null) != null : false
    )
    error_message = "ERROR. Please check \"bigquery_destination_config\".\nWe accept \"data_freshness\", \"single_target_dataset\", \"source_hierarchy_datasets\".\nNOTE: Also ONE of \"single_target_dataset\" or \"source_hierarchy_datasets\" is required (NOT both)."
  }
}

# source_config - (Required) Source connection profile configuration. Structure is documented below.
# source_connection_profile - (Required) Destination connection profile resource. Format: projects/{project}/locations/{location}/connectionProfiles/{name}
variable "source_connection_profile" {
  description = "Source connection profile resource. Format: `projects/{project}/locations/{location}/connectionProfiles/{name}`"
  type        = any
  validation {
    condition     = length(regexall("connectionProfiles", var.source_connection_profile)) != 0
    error_message = "ERROR. Please check \"source_connection_profile\".\nFormat: \"projects/{project}/locations/{location}/connectionProfiles/{name}\"."
  }
}


# mysql_source_config
variable "mysql_source_config" {
  description = <<-EOF
  MySQL data source configuration.
  
  - `include_objects` - MySQL objects to retrieve from the source. Structure is documented below.
  - `exclude_objects` - MySQL objects to exclude from the stream. Structure is documented below.
  - `max_concurrent_cdc_tasks` - Maximum number of concurrent CDC tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.
  - `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.   

  **`include_objects` and `exclude_objects`**
  ```
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
  EOF

  type    = any
  default = null
  validation {
    condition = var.mysql_source_config != null ? (length(setsubtract(keys(var.mysql_source_config), [
      "include_objects",
      "exclude_objects",
      "max_concurrent_cdc_tasks",
      "max_concurrent_backfill_tasks"
    ])) == 0) : true
    error_message = "ERROR. Please check \"mysql_source_config\".\nWe accept \"include_objects\", \"exclude_objects\", \"max_concurrent_cdc_tasks\", \"max_concurrent_backfill_tasks\"."
  }
}


# oracle_source_config
variable "oracle_source_config" {
  description = <<-EOF
  Oracle data source configuration.
  
  - `include_objects` - Oracle objects to retrieve from the source. Structure is documented below.
  - `exclude_objects` - Oracle objects to exclude from the stream. Structure is documented below.
  - `max_concurrent_cdc_tasks` - Maximum number of concurrent CDC tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.
  - `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.   
  - `drop_large_objects` - Configuration to drop large object values.
  - `stream_large_objects` - Configuration to drop large object values.

  **include_objects and exclude_objects**
  ```
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
  EOF

  type    = any
  default = null
  validation {
    condition = var.oracle_source_config != null ? (length(setsubtract(keys(var.oracle_source_config), [
      "include_objects",
      "exclude_objects",
      "max_concurrent_cdc_tasks",
      "max_concurrent_backfill_tasks",
      "drop_large_objects",
      "stream_large_objects"
    ])) == 0) : true
    error_message = "ERROR. Please check \"oracle_source_config\".\nWe accept \"include_objects\", \"exclude_objects\", \"max_concurrent_cdc_tasks\", \"max_concurrent_backfill_tasks\", \"drop_large_objects\", \"stream_large_objects\"."
  }
}



# postgresql_source_config
variable "postgresql_source_config" {
  description = <<-EOF
  Oracle data source configuration.
  
  - `include_objects` - Oracle objects to retrieve from the source. Structure is documented below.
  - `exclude_objects` - Oracle objects to exclude from the stream. Structure is documented below.
  - `replication_slot` - (Required) The name of the logical replication slot that's configured with the pgoutput plugin.
  - `publication` - (Required) The name of the publication that includes the set of all tables that are defined in the stream's include_objects.
  - `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.   

  **`include_objects` and `exclude_objects`**
  ```
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
  EOF

  type    = any
  default = null
  validation {
    condition = (var.postgresql_source_config != null ? (length(setsubtract(keys(var.postgresql_source_config), [
      "include_objects",
      "exclude_objects",
      "replication_slot",
      "max_concurrent_backfill_tasks",
      "publication"])) == 0) : true) && (
      var.postgresql_source_config != null ? lookup(var.postgresql_source_config, "replication_slot", null) != null : true
      ) && (
      var.postgresql_source_config != null ? lookup(var.postgresql_source_config, "publication", null) != null : true
    )
    error_message = "ERROR. Please check \"postgresql_source_config\".\nWe accept \"include_objects\", \"exclude_objects\", \"publication\", \"max_concurrent_backfill_tasks\", \"replication_slot\".\nNOTE: Also both \"publication\" and \"replication_slot\" are required."
  }
}
