# Datastream Connection Profile Examples

In this we are create different set of examples for each profile type.
There are different types of profiles which we can create.

In this section, you will discover how to create connection profiles for various purposes:

1. Establish connections to source Oracle, MySQL, and PostgreSQL databases.
2. Set up connections to destination datasets within BigQuery.
3. Configure connections to a destination bucket in Cloud Storage.

These connection profiles play a crucial role in enabling Datastream to efficiently transfer data from the source database to the specified destination locations.

- [Datastream Connection Profile Examples](#datastream-connection-profile-examples)
  - [Creating GCS Profile - Destination](#creating-gcs-profile---destination)
  - [Creating BigQuery Profile - Destination Dataset](#creating-bigquery-profile---destination-dataset)
  - [Creating MySQL Profile - Source](#creating-mysql-profile---source)
  - [Creating PostgreSQL Profile - Source](#creating-postgresql-profile---source)
  - [Creating Oracle Profile - Source](#creating-oracle-profile---source)

## Creating GCS Profile - Destination

Code Location: [github](./gcs_profile.tf)

Important fields below.

| Field       | Description                                                                                                                                                                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Location    | Select the region where the connection profile is stored. Connection profiles are saved in a region, and a stream must use connection profiles stored in the same region. The region selection doesn't impact Datastream's ability to connect but may affect availability during region downtime. |
| Bucket Name | Bucket name **without** the "gs://" prefix (Required).                                                                                                                                                                                                                                            |

**Example Code**

```hcl
module "create_connection_profile_gcs" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-gcs"        # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-gcs"        # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  gcs_profile = {
    bucket    = google_storage_bucket.gcs.name # Bucket name without the "gs://" prefix (Required)
    root_path = "/"                            # Root path inside the GCS bucket (Optional, defaults to "/")
  }
}
```

## Creating BigQuery Profile - Destination Dataset

Code Location : [github](./bigquery_profile.tf)

| Field    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Location | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream must use connection profiles stored in the same region as the stream. The region selection doesn't impact Datastream's ability to connect but may affect availability during region downtime. Region selection is also independent of the location type you selected for your BigQuery destination dataset. |

**Example Code**

:books: **NOTE:** There is no configuration for the bigquery connection profile.

```hcl
module "create_connection_profile_bq" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-bq"         # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-bq"         # Unique identifier for the connection profile

  labels = {
    key = "value"
  }
  bigquery_profile = {}
}
```

## Creating MySQL Profile - Source

Code Location : [github](./mysql_profile.tf)

| Field          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Location       | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream can only use connection profiles that are stored in the same region as the stream. Region selection doesn't impact whether Datastream can connect to the source or the destination, but can impact availability if the region experiences downtime.                                                                   |
| Hostname or IP | Enter a hostname or IP address that Datastream can use to connect to the source MySQL database. If you're using private connectivity to communicate with the source database, then specify the private (internal) IP address for the source database. If you're using a reverse proxy for private connectivity, then use the IP address of the proxy. For other connectivity methods, such as IP allowlisting or Forward-SSH, provide the public IP address. |
| Port           | Enter the port number that's reserved for the source database (The default port is typically 3306.).                                                                                                                                                                                                                                                                                                                                                         |
| Username       | Enter the username of the account for the source database (for example, root). This is the Datastream user that you created for the database. For more information about creating this user, see Configure a source MySQL database.                                                                                                                                                                                                                          |
| Password       | Enter the password of the account for the source database.                                                                                                                                                                                                                                                                                                                                                                                                   |

**Example Code.**

```hcl
module "create_connection_profile_mysql" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-mysql"      # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-mysql"      # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  mysql_profile = {
    hostname   = "127.0.0.1" # (Required) Hostname for the MySQL connection.
    port       = "3306"      # (Optional) Port for the MySQL connection, default value is 3306.
    username   = "ahmed"     # (Required) Username for the MySQL connection.
    ssl_config = {}          # SSL configuration for MySQL (empty to enable ssl_config, secrets passed from var.secret)
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    mysql_profile = {
      password           = "secret"        # Password for MySQL profile (Required if using mysql_profile)
      client_key         = "pem_file_here" # Client key for MySQL profile (Optional but required if ssl_config is required)
      ca_certificate     = "pem_file_here" # CA certificate for MySQL profile (Optional but required if ssl_config is required)
      client_certificate = "pem_file_here" # Client certificate for MySQL profile (Optional but required if ssl_config is required)
    }
  }
}

```

## Creating PostgreSQL Profile - Source

Code Location : [github](./postresql_profile.tf)

Here's a markdown table based on the provided information:

| Field          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Location       | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream can only use connection profiles that are stored in the same region as the stream. Region selection doesn't impact whether Datastream can connect to the source or the destination, but can impact availability if the region experiences downtime.                                                                        |
| Hostname or IP | Enter a hostname or IP address that Datastream can use to connect to the source PostgreSQL database. If you're using private connectivity to communicate with the source database, then specify the private (internal) IP address for the source database. If you're using a reverse proxy for private connectivity, then use the IP address of the proxy. For other connectivity methods, such as IP allowlisting or Forward-SSH, provide the public IP address. |
| Port           | Enter the port number that's reserved for the source database (The default port for PostgreSQL is typically 5432.).                                                                                                                                                                                                                                                                                                                                               |
| Username       | Enter the username of the account for the source database (for example, root). This is the Datastream user that you created for the database. For more information about creating this user, see Configure your source PostgreSQL database.                                                                                                                                                                                                                       |
| Password       | Enter the password of the account for the source database.                                                                                                                                                                                                                                                                                                                                                                                                        |
| Database       | Enter the name that identifies the database instance. For PostgreSQL databases, this is typically postgres.                                                                                                                                                                                                                                                                                                                                                       |

**Example Code.**

```hcl
module "create_connection_profile_postgresql" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-postgresql" # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-postgresql" # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  postgresql_profile = {
    hostname = "127.0.0.1" # (Required) Hostname for the PostgreSQL connection.
    port     = "1521"      # (Optional) Port for the PostgreSQL connection, default value is 5432.
    database = "default"   # (Required) Username for the PostgreSQL connection.
    username = "ahmed"     # (Required) Database for the PostgreSQL connection.
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    postgresql_profile = {
      password = "secret" # Password for PostgreSQL profile (Required if using postgresql_profile)
    }
  }
}

```

## Creating Oracle Profile - Source

Code Location : [github](./oracle_profile.tf)

| Field          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Location       | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream can only use connection profiles that are stored in the same region as the stream. Region selection doesn't impact whether Datastream can connect to the source or the destination, but can impact availability if the region experiences downtime.                                                                   |
| Hostname or IP | Enter a hostname or IP address that Datastream can use to connect to the source Oracle database. If you're using private connectivity to communicate with the source database, then specify the private (internal) IP address for the source database. :books: NOTE: If you're using a reverse proxy for private connectivity, then use the IP address of the proxy. For other connectivity methods, such as IP allowlisting, provide the public IP address. |
| Port           | Enter the port number that's reserved for the source database (The default port is typically 1521.).                                                                                                                                                                                                                                                                                                                                                         |
| Username       | Enter the username of the account for the source database (for example, ROOT). This is the Datastream user that you created for the database. For more information about creating this user, see Configure your source Oracle database.                                                                                                                                                                                                                      |
| Password       | Enter the password of the account for the source database. :warning: NOTE: Set this in the `secret` variable.                                                                                                                                                                                                                                                                                                                                                |

**Example Code.**

```hcl
module "create_connection_profile_oracle" {
  source                = "../../datastream_connection_profile"
  project               = "elevated-column-400011" # Project where the connection profile will be created
  display_name          = "ahmd-connec-oracle"     # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-oracle"     # Unique identifier for the connection profile

  labels = {
    key = "value"
  }


  oracle_profile = {
    username         = "ahmed"     # (Required) Hostname for the Oracle connection.
    hostname         = "127.0.0.1" # (Optional) Port for the Oracle connection, default value is 1521.
    port             = "1521"      # (Required) Username for the Oracle connection.
    database_service = "default"   # (Required) Database for the Oracle connection.
    connection_attributes = {      # (Optional) map (key: string, value: string) Connection string attributes
      key = "some_value"
    }
  }

  #
  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only. 
  #
  secret = {
    oracle_profile = {
      password = "secret" # Password for Oracle profile (Required if using oracle_profile)
    }
  }
}

```
