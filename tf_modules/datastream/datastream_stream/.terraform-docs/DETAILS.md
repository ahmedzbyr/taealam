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
