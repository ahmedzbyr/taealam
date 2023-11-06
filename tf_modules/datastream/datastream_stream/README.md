<!-- BEGIN_TF_DOCS -->

# Datastream Module

In this module we will be creating a datastream.

##  Overview of Datastream

- **Datastream Overview:**
  - Serverless change data capture (CDC) and replication service.
  - Synchronizes data with minimal latency.
  - Replicates data from databases into BigQuery.
  - Supports writing to Cloud Storage.
  - Integrates with Dataflow for custom data loading workflows.
  - Handles Oracle, MySQL, PostgreSQL, including AlloyDB.

- **Benefits of Datastream:**
  - Facilitates low-latency ELT pipelines for near real-time BigQuery insights.
  - Serverless: no resource management required, automatic scaling.
  - User-friendly setup and monitoring.
  - Integrates with Google Cloud's data services for comprehensive data integration.
  - Enables data synchronization across diverse databases and applications.
  - Offers security and private connectivity within Google Cloud's secure environment.
  - Provides accuracy and reliability, with robust handling of data and schema changes.
  - Supports various use cases: analytics, database replication, migrations, hybrid-cloud configurations, and event-driven architectures.

- **Use Cases for Datastream:**
  - Enables real-time data replication and synchronization across different databases and apps.
  - Serves analytics and database replication with low latency.
  - Supports migrations and event-driven architectures in hybrid environments.
  - Serverless architecture allows easy scaling up or down according to data volume.

- **Integration with Google Cloud:**
  - Forms part of Google Cloud's data integration suite.
  - Leverages Dataflow templates for loading into BigQuery, Cloud Spanner, and Cloud SQL.
  - Enhances Cloud Data Fusion's CDC Replicator connectors for simplified data pipelining.

- **Key Elements of Datastream:**
  - Private connectivity configurations for secure data source communication over private networks.
  - Connection profiles that define source and destination connectivity for data streams.
  - Streams that utilize connection profiles to transfer CDC and backfill data from source to destination.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_connection_profile"></a> [destination\_connection\_profile](#input\_destination\_connection\_profile) | Destination connection profile resource. Format: `projects/{project}/locations/{location}/connectionProfiles/{name}` | `any` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels for the connection. <br><br>Note: This field is non-authoritative, and will only manage the labels present in your configuration. Also please refer to the field `effective_labels` for all of the labels present on the resource.<br><br>`effective_labels` - All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The name of the location this stream is located in. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_source_connection_profile"></a> [source\_connection\_profile](#input\_source\_connection\_profile) | Source connection profile resource. Format: `projects/{project}/locations/{location}/connectionProfiles/{name}` | `any` | n/a | yes |
| <a name="input_stream_id"></a> [stream\_id](#input\_stream\_id) | The stream identifier. | `string` | n/a | yes |
| <a name="input_backfill_all"></a> [backfill\_all](#input\_backfill\_all) | Backfill strategy to automatically backfill the Stream's objects. Specific objects can be excluded.<br><br>  - `mysql_excluded_objects` - MySQL data source objects to avoid backfilling.<br>  - `postgresql_excluded_objects` - PostgreSQL data source objects to avoid backfilling.<br>  - `oracle_excluded_objects` - PostgreSQL data source objects to avoid backfilling. <br><br>**`mysql_excluded_objects`**<pre>{<br>    mysql_excluded_objects = {<br>      mysql_databases = [{<br>        database     = string<br>        mysql_tables = [{<br>          table         = string<br>          mysql_columns = [{<br>            column           = string<br>            data_type        = string<br>            collation        = string<br>            primary_key      = boolean<br>            nullable         = boolean<br>            ordinal_position = integer<br>          }]<br>        }]<br>      }]<br>    }<br>  }</pre>**`postgresql_excluded_objects`**<pre>{<br>    postgresql_excluded_objects = {<br>      postgresql_schemas = [{<br>        schema     = string<br>        postgresql_tables = [{<br>          table           = string<br>          postgresql_columns = [{<br>            column           = string<br>            data_type        = string<br>            primary_key      = boolean<br>            nullable         = boolean<br>            ordinal_position = integer<br>          }]<br>        }]<br>      }]<br>    }<br>  }</pre>**`oracle_excluded_objects`**<pre>{<br>    oracle_excluded_objects = {<br>      oracle_schemas = [{<br>        schema     = string<br>        oracle_tables = [{<br>          table         = string<br>          oracle_columns = [{<br>            column           = string<br>            data_type        = string<br>          }]<br>        }]<br>      }]<br>    }<br>  }</pre> | `any` | `null` | no |
| <a name="input_backfill_none"></a> [backfill\_none](#input\_backfill\_none) | Backfill strategy to disable automatic backfill for the Stream's objects. | `bool` | `false` | no |
| <a name="input_bigquery_destination_config"></a> [bigquery\_destination\_config](#input\_bigquery\_destination\_config) | A configuration for how data should be loaded to Bigquery Dataset. <br><br>- `data_freshness` - The guaranteed data freshness (in seconds) when querying tables created by the stream. Editing this field will only affect new tables created in the future, but existing tables will not be impacted. Lower values mean that queries will return fresher data, but may result in higher cost. A duration in seconds with up to nine fractional digits, terminated by 's'. Example: "3.5s". Defaults to 900s.<br>- `single_target_dataset` - A single target dataset to which all data will be streamed. Structure is documented below.<br>- `source_hierarchy_datasets` - Destination datasets are created so that hierarchy of the destination data objects matches the source hierarchy. Structure is documented below.<br><br>**`single_target_dataset`**<br>- `dataset_id` - (Required) Dataset ID in the format `projects/{project}/datasets/{dataset_id}` or `{project}:{dataset_id}`<br> <br>**`source_hierarchy_datasets`**<br>- `dataset_template` - (Required) Dataset template used for dynamic dataset creation.<br><br>**`dataset_template`**<br>- `location` - (Required) The geographic location where the dataset should reside. See [locations](https://cloud.google.com/bigquery/docs/locations) for supported locations.<br>- `dataset_id_prefix` - (Optional) If supplied, every created dataset will have its name prefixed by the provided value. The prefix and name will be separated by an underscore. i.e. `_`.<br>- `kms_key_name` - (Optional) Describes the Cloud KMS encryption key that will be used to protect destination BigQuery table. The BigQuery Service Account associated with your project requires access to this encryption key. i.e. `projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{cryptoKey}`.<br><br>**JSON Representation**<pre>{<br>  "data_freshness": string,<br>  <br>  // Union field dataset_config can be only one of the following:<br>  "single_target_dataset": {<br>    dataset_id : string <br>  },<br>  "source_hierarchy_datasets": {<br>    dataset_template : {<br>      location : string <br>      dataset_id_prefix : string <br>      kms_key_name : string<br>    }<br>  }<br>  // End of list of possible types for union field dataset_config.<br>}</pre> | `any` | `null` | no |
| <a name="input_customer_managed_encryption_key"></a> [customer\_managed\_encryption\_key](#input\_customer\_managed\_encryption\_key) | A reference to a KMS encryption key. If provided, it will be used to encrypt the data. If left blank, data will be encrypted using an internal Stream-specific encryption key provisioned through KMS. | `string` | `null` | no |
| <a name="input_desired_state"></a> [desired\_state](#input\_desired\_state) | Desired state of the Stream. Set this field to `RUNNING` to start the stream, and `PAUSED` to pause the stream. | `string` | `"RUNNING"` | no |
| <a name="input_gcs_destination_config"></a> [gcs\_destination\_config](#input\_gcs\_destination\_config) | A configuration for how data should be loaded to Cloud Storage.<br><br>- `path` - Path inside the Cloud Storage bucket to write data to.<br>- `file_rotation_mb`       - The maximum file size to be saved in the bucket.<br>- `file_rotation_interval` - The maximum duration for which new events are added before a file is closed and a new file is created. A duration in seconds with up to nine fractional digits, terminated by 's'. Example: "3.5s". Defaults to 900s.<br>- `avro_file_format` - AVRO file format configuration.<br>- `json_file_format` - JSON file format configuration.<br><br>**`json_file_format`**<br>- `schema_file_format` - The schema file format along `JSON` data files. Possible values are: `NO_SCHEMA_FILE`, `AVRO_SCHEMA_FILE`.<br>- `compression`        - Compression of the loaded `JSON` file. Possible values are: `NO_COMPRESSION`, `GZIP`.<br><br>**JSON representation**<pre>{<br>  "path": string,<br>  "file_rotation_mb": integer,<br>  "file_rotation_interval": string,<br>  <br>  // Union field file_format can be only one of the following:<br>  "avro_file_format": {}, // This type has no fields.<br>  "json_file_format": {<br>    {<br>      "schema_file_format": enum <br>      "compression": enum <br>    }<br>  }<br>  // End of list of possible types for union field file_format.<br>}</pre> | `any` | `null` | no |
| <a name="input_mysql_source_config"></a> [mysql\_source\_config](#input\_mysql\_source\_config) | MySQL data source configuration.<br><br>- `include_objects` - MySQL objects to retrieve from the source. Structure is documented below.<br>- `exclude_objects` - MySQL objects to exclude from the stream. Structure is documented below.<br>- `max_concurrent_cdc_tasks` - Maximum number of concurrent CDC tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.<br>- `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used. <br><br>**`include_objects` and `exclude_objects`**<pre>{<br>  *clude_objects = {<br>    mysql_databases = [{<br>      database     = string<br>      mysql_tables = [{<br>        table         = string<br>        mysql_columns = [{<br>          column           = string<br>          data_type        = string<br>          collation        = string<br>          primary_key      = boolean<br>          nullable         = boolean<br>          ordinal_position = integer<br>        }]<br>      }]<br>    }]<br>  }<br>}</pre> | `any` | `null` | no |
| <a name="input_oracle_source_config"></a> [oracle\_source\_config](#input\_oracle\_source\_config) | Oracle data source configuration.<br><br>- `include_objects` - Oracle objects to retrieve from the source. Structure is documented below.<br>- `exclude_objects` - Oracle objects to exclude from the stream. Structure is documented below.<br>- `max_concurrent_cdc_tasks` - Maximum number of concurrent CDC tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used.<br>- `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used. <br>- `drop_large_objects` - Configuration to drop large object values.<br>- `stream_large_objects` - Configuration to drop large object values.<br><br>**include\_objects and exclude\_objects**<pre>{<br>  *clude_objects = {<br>    oracle_schemas = [{<br>      schema     = string<br>      oracle_tables = [{<br>        table         = string<br>        oracle_columns = [{<br>          column           = string<br>          data_type        = string<br>        }]<br>      }]<br>    }]<br>  }<br>}</pre> | `any` | `null` | no |
| <a name="input_postgresql_source_config"></a> [postgresql\_source\_config](#input\_postgresql\_source\_config) | PostgreSQL data source configuration.<br><br>- `include_objects` - PostgreSQL objects to retrieve from the source. Structure is documented below.<br>- `exclude_objects` - PostgreSQL objects to exclude from the stream. Structure is documented below.<br>- `replication_slot` - (Required) The name of the logical replication slot that's configured with the pgoutput plugin.<br>- `publication` - (Required) The name of the publication that includes the set of all tables that are defined in the stream's include\_objects.<br>- `max_concurrent_backfill_tasks` - Maximum number of concurrent backfill tasks. The number should be non negative. If not set (or set to 0), the system's default value will be used. <br><br>**`include_objects` and `exclude_objects`**<pre>{<br>  *clude_objects = {<br>    postgresql_schemas = [{<br>      schema     = string<br>      postgresql_tables = [{<br>        table           = string<br>        postgresql_columns = [{<br>          column           = string<br>          data_type        = string<br>          primary_key      = boolean<br>          nullable         = boolean<br>          ordinal_position = integer<br>        }]<br>      }]<br>    }]<br>  }<br>}</pre> | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_stream_effective_labels"></a> [this\_stream\_effective\_labels](#output\_this\_stream\_effective\_labels) | All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services. |
| <a name="output_this_stream_id"></a> [this\_stream\_id](#output\_this\_stream\_id) | An identifier for the resource with format `projects/{{project}}/locations/{{location}}/streams/{{stream_id}}` |
| <a name="output_this_stream_name"></a> [this\_stream\_name](#output\_this\_stream\_name) | The resource's name. |
| <a name="output_this_stream_state"></a> [this\_stream\_state](#output\_this\_stream\_state) | State of the Stream. |
| <a name="output_this_stream_terraform_labels"></a> [this\_stream\_terraform\_labels](#output\_this\_stream\_terraform\_labels) | The combination of labels configured directly on the resource and default labels configured on the provider. |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_datastream_stream.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/datastream_stream) | resource |
| [null_resource.check_all_destination_not_null](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.check_back_fill](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.check_if_only_one_source](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.check_not_all_destination_null](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.check_not_all_source_null](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

##  Feature and Key Concepts in Datastream

### Behavior and Use Cases

- Brings RDBMS and other source data into BigQuery and Cloud Storage in near real-time.
- Supports data warehousing, analytics, and artificial intelligence/machine learning workloads.

### Key Concepts

#### Change Data Capture (CDC)

- Software patterns to track and act on data changes.
- Facilitates data integration by delivering changes from enterprise data sources.

#### Event Sourcing

- Introduced in 2005, [event sourcing](https://martinfowler.com/eaaDev/EventSourcing.html) is a design pattern where every change to a state of an application is captured in an event object. 
- Utilizing event sourcing, an application can easily rebuild its state, perform [point-in-time recovery](https://en.wikipedia.org/wiki/Point-in-time_recovery) (by processing the event until that point), recompute the state in case of a change in logic, or enable [Command Query Responsibility Segregation (CQRS)](https://martinfowler.com/bliki/CQRS.html) design. 
- With the evolution of tools for real-time event processing, many applications are moving to the event sourcing model. 
- Historically, transactional databases were always event-oriented, because of [atomicity, consistency, isolation, and durability (ACID)](https://en.wikipedia.org/wiki/ACID) requirements.

#### Transactional Databases

- Uses a write-ahead log (WAL) for operations before execution.
- Ensures atomicity and durability; and also allows high-fidelity replication of the database.

#### Events and Streams

- Datastream ingests and provides near real-time data through events.
- A stream is a continuous ingestion of events from a source to a destination.

#### Unified Types

- Data sources have their own types, some specific to the database itself, and some that are generic and are shared across databases.
- The unified type is a common and lossless way to represent data types across all sources so that they can be consumed in a cohesive manner. 
- The unified types supported by Datastream will represent the superset of all normalized types across all supported source systems so that all types can be supported losslessly.

#### Entity Context

- Private connectivity configurations for secure network communications.
- Connection profiles define connectivity to sources/destinations.
- Streams use connection profiles to transfer data.
- Objects are subsets of streams, like tables within a database stream.
- Events represent DML changes for objects.

### Features

#### Serverless

- Automatic data movement without installation or maintenance overheads.
- Autoscaling capabilities to maintain near real-time data flow.

#### Unified Avro-Based Type Schema

- Converts source-specific types into a unified Avro-based schema.

#### Stream Historical and CDC Data

- Streams both historical and CDC data simultaneously in near real-time.

#### Oracle CDC Without Additional Licenses

- LogMiner-based CDC from Oracle version 11.2g and above, without extra licenses.

#### BigQuery Destination

- Continuously replicates changes to BigQuery for immediate analytics availability.

#### Cloud Storage Destination

- CDC data written to Avro or JSON files for further processing or downstream loading.

### Use Cases

#### Data Integration

- Feeds near real-time data into BigQuery for data integration pipelines.

#### Streaming Analytics

- Ingests database changes for real-time analytics like fraud detection.

#### Near Real-Time Data Availability

- Powers AI and machine learning applications for immediate responsiveness.

### Behavior Overview

- Streams changes from various data sources into Google Cloud directly.

### Sources

- There is setup work required for a source to be used with Datastream, including authentication and additional configuration options.
- Each source generates events that reflect all data manipulation language (DML) changes.
- Each stream can backfill historical data, as well as stream ongoing changes into the destination.

### Destinations

- Supports BigQuery and Cloud Storage.
- Defines BigQuery datasets or Cloud Storage buckets upon stream creation.

### Event Delivery

- The event order isn't guaranteed. Event metadata includes information that can be used to order the events.
- The event delivery occurs at least once. Event metadata includes data that can be used to remove any duplicate data in the destination.
- The event size is limited to 10 MB per event for BigQuery destinations and 30 MB per event for Cloud Storage destinations.

### High Availability and Disaster Recovery

#### High Availability

- Regional service across multiple zones; unaffected by single-zone failures.

#### Disaster Recovery

- Regional outages cause stream interruptions, resuming with potential duplicates post-outage.
- If there's a failure in a region, then any streams running on that region will be down for the duration of the outage. 
- After the outage is resolved, Datastream will continue exactly where it left off, and any data that hasn't been written to the destination will be retrieved again from the source. 
- In this case, duplicates of data may reside in the destination. See [Event delivery](https://cloud.google.com/datastream/docs/behavior-overview#eventdelivery) for more information on removing the duplicate data.

### Initial Data and CDC Data

- Because data sources have data that existed before the time that the source was connected to a stream (historical data), Datastream generates events both from the historical data as well as data changes happening in real-time.
- To ensure fast data access, the historical data and the real-time data changes are replicated simultaneously to the destination. 
- The event metadata indicates whether that event is from the backfill or from the CDC.

---
## Documentation

- [Overview of Datastream](https://cloud.google.com/datastream/docs/overview)
- [Key concepts and features](https://cloud.google.com/datastream/docs/behavior-overview)
- [Create connection profiles](https://cloud.google.com/datastream/docs/create-connection-profiles)
- [Create a private connectivity configuration](https://cloud.google.com/datastream/docs/create-a-private-connectivity-configuration)
- [Create a stream](https://cloud.google.com/datastream/docs/create-a-stream)
<!-- END_TF_DOCS -->    