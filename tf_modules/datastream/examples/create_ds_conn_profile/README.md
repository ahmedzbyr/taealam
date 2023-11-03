# Datastream Connection Profile Examples

In this we are create different set of examples for each profile type.
There are different types of profiles which we can create.

In this section, you will discover how to create connection profiles for various purposes:

1. Establish connections to source Oracle, MySQL, and PostgreSQL databases.
2. Set up connections to destination datasets within BigQuery.
3. Configure connections to a destination bucket in Cloud Storage.

These connection profiles play a crucial role in enabling Datastream to efficiently transfer data from the source database to the specified destination locations.

- [Datastream Connection Profile Examples](#datastream-connection-profile-examples)
  - [Managing Secrets](#managing-secrets)
    - [How to set `secret` variable](#how-to-set-secret-variable)
      - [Postgresql Secret](#postgresql-secret)
      - [Oracle Secret](#oracle-secret)
      - [MySQL Secret](#mysql-secret)
      - [Forward SSH Connectivity Secret](#forward-ssh-connectivity-secret)
    - [Example for **Vault Storage (Recommended):**](#example-for-vault-storage-recommended)
  - [Creating GCS Profile - Destination](#creating-gcs-profile---destination)
  - [Creating BigQuery Profile - Destination Dataset](#creating-bigquery-profile---destination-dataset)
  - [Creating MySQL Profile - Source](#creating-mysql-profile---source)
  - [Creating PostgreSQL Profile - Source](#creating-postgresql-profile---source)
  - [Creating Oracle Profile - Source](#creating-oracle-profile---source)

## Managing Secrets

Code Example : [Github](../vault_create_ds_conn_profile/)

Sensitive information is securely managed through a variable called `secret`. This variable contains all the confidential data, such as passwords and keys, required for various configurations within the module. There are two recommended methods for handling this variable:

1. **Vault Storage (Recommended):** The `secret` variable can be securely stored in a vault system, ensuring that sensitive data is protected and managed centrally.
2. **Local Node Secret:** Alternatively, you can store the `secret` variable as a secret on the node where the module is executed. It can then be passed as an environment variable, providing an additional layer of security by hiding the information stored in the variable during execution.

### How to set `secret` variable

When using this module, it's important to properly configure the `secret` variable to manage sensitive information for different database profiles. Below are examples of how to structure the `secret` variable for specific database types when using this module.

#### Postgresql Secret

```hcl
secret = {
  postgresql_profile = {
    password = "secret" # Password for PostgreSQL profile (Required if using postgresql_profile)
  }
}
```

#### Oracle Secret

```hcl
secret = {
  oracle_profile = {
    password = "secret" # Password for Oracle profile (Required if using oracle_profile)
  }
}
```

#### MySQL Secret

```hcl
secret = {
  mysql_profile = {
    password           = "secret"        # Password for MySQL profile (Required if using mysql_profile)
    client_key         = "pem_file_here" # Client key for MySQL profile (Optional but required if ssl_config is required)
    ca_certificate     = "pem_file_here" # CA certificate for MySQL profile (Optional but required if ssl_config is required)
    client_certificate = "pem_file_here" # Client certificate for MySQL profile (Optional but required if ssl_config is required)
  }
}
```

#### Forward SSH Connectivity Secret

```hcl
secret = {
  forward_ssh_connectivity = {
    password = "secret"
    # or // Either not BOTH
    # private_key = "pem_file_here"
  }
}
```

### Example for **Vault Storage (Recommended):**

```hcl
# Define the Vault provider configuration.
# This can also be set using below (Recommended)
#   export VAULT_ADDR='http://127.0.0.1:8200'
#   export VAULT_TOKEN="hvs.6j4cuewowBGit65rheNoceI7" 
#
provider "vault" {
  address = "http://127.0.0.1:8200"        # Vault server address this is for testing
  token   = "hvs.FEinfYx2Sf7yDTbIxRskJXJj" # Authentication token for Vault 
}

# Create a Vault KV version 1 mount for connection profiles.
resource "vault_mount" "ds_conn_profiles" {
  path = "profiles" # Mount path for connection profiles
  type = "kv"       # Mount type (KV version 1)
  options = {
    version = "1" # Specify KV version 1
  }
}

# Define a generic Vault secret for connection profiles.
resource "vault_generic_secret" "ds_conn_profiles" {
  path = "${vault_mount.ds_conn_profiles.path}/secret" # Path for the secret
  data_json = jsonencode(
    {
      postgresql_profile = {
        password = "my_secret" # PostgreSQL password (example)
      }
    }
  )
}

# Retrieve the Vault secret data for use in the module.
data "vault_generic_secret" "get_secret" {
  path       = "${vault_mount.ds_conn_profiles.path}/secret" # Path to retrieve the secret
  depends_on = [vault_generic_secret.ds_conn_profiles]       # Ensure the secret is generated first
}

# Define an output to expose the secret information.
output "secret_information" {
  value     = jsondecode(data.vault_generic_secret.get_secret.data_json) # Decode and expose the secret data
  sensitive = true                                                       # Mark the output as sensitive to avoid exposing secrets in logs
}

# Create a connection profile for PostgreSQL using a module.
module "create_connection_profile_postgresql" {
  source                = "../../datastream_connection_profile" # Path to the connection profile module
  project               = "elevated-column-400011"              # Project where the connection profile will be created
  display_name          = "ahmd-connec-postgresql"              # Display name for the connection profile
  location              = "us-east1"                            # Location of the connection profile
  connection_profile_id = "ahmd-connec-postgresql"              # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  postgresql_profile = {
    hostname = "127.0.0.1" # (Required) Hostname for the PostgreSQL connection.
    port     = "1521"      # (Optional) Port for the PostgreSQL connection, default value is 5432.
    database = "default"   # (Required) Database for the PostgreSQL connection.
    username = "ahmed"     # (Required) Username for the PostgreSQL connection.
  }

  # IMPORTANT NOTE:
  #   This secret has to be from a VAULT and should not be in plain text as it is here 
  #   Adding it here for testing only.
  secret = jsondecode(data.vault_generic_secret.get_secret.data_json)
}
```


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
