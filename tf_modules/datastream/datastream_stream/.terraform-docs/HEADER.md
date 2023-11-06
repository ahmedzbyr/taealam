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
