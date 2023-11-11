# Datastream Connection Profiles

Datastream is a user-friendly and serverless change data capture (CDC) and replication service designed to enable dependable data synchronization with minimal latency.

The creation of connection profiles is essential for Datastream to facilitate the seamless transfer of data from source databases to the intended destinations.

This module allows us to establish connection profiles for a variety of source types, including:

- Oracle
- MySQL
- PostgreSQL
- Google Cloud Storage (GCS) buckets
- BigQuery

These connection profiles serve as the bridge for Datastream to efficiently capture and replicate data across different platforms and systems.

## Managing Secrets

In this module, sensitive information is securely managed through a variable called `secret`. This variable contains all the confidential data, such as passwords and keys, required for various configurations within the module. There are two recommended methods for handling this variable:

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
  project               = "my-project-id"              # Project where the connection profile will be created
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

### Example for  **Local Node Secret:** Using `TF_VAR` Environment Variables

You can utilize environment variables to set Terraform variables. These environment variables should follow the format `TF_VAR_name`, and Terraform will prioritize their values when searching for variable assignments. For instance:

```bash
export TF_VAR_region=us-west-1
export TF_VAR_ami=ami-049d8641
export TF_VAR_alist='[1,2,3]'
export TF_VAR_amap='{ foo = "bar", baz = "qux" }'
```

Here is how we setup our secret in the environment variable.

```bash
export TF_VAR_secret='{ postgresql_profile = { password = "secret" }}'
```

Then we just exclude the `secret` variable as we have passed it from the environment variable.

```hcl
module "create_connection_profile_gcs" {
  source                = "../../datastream_connection_profile"
  project               = "my-project-id" # Project where the connection profile will be created
  display_name          = "ahmd-connec-gcs"        # Display name for the connection profile
  location              = "us-east1"               # Location of the connection profile
  connection_profile_id = "ahmd-connec-gcs"        # Unique identifier for the connection profile

  labels = {
    key = "value"
  }

  postgresql_profile = {
    hostname = "127.0.0.1" # (Required) Hostname for the PostgreSQL connection.
    port     = "1521"      # (Optional) Port for the PostgreSQL connection, default value is 5432.
    database = "default"   # (Required) Username for the PostgreSQL connection.
    username = "ahmed"     # (Required) Database for the PostgreSQL connection.
  }
}
```

- To understand how to use `TF_VAR_name` within a broader context, refer to the section on [Variable Configuration](https://developer.hashicorp.com/terraform/language/values/variables).
- For additional details about `TF_VAR_name` and Terraform environment variables, you can also check the [Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_cli_args-and-tf_cli_args_name).
