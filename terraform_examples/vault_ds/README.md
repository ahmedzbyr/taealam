## Setting Up HashiCorp Vault

In this guide, we'll walk you through the process of setting up HashiCorp Vault to securely manage secrets. We'll cover installing and configuring Vault, storing secrets, and using Terraform to extract and manage secrets for your infrastructure.

We will do this using 2 phases to do this.

1. Setup the vault on a workstation.
2. Store the secret on the vault and retrive it.

##  Phase 1. Setup the vault on a workstation

Setting up a vault setup on the workstation.

### Step 1: Install HashiCorp Vault

You can install HashiCorp Vault by following the official installation instructions for your platform: [HashiCorp Vault Installation Guide](https://learn.hashicorp.com/vault/getting-started/install)

### Step 2: Start Vault Server

Once installed, start the Vault server in development mode for testing purposes:

```bash
vault server -dev
```

**Output**

```bash
2023-11-03T20:56:46.894Z [INFO]  core: successful mount: namespace="" path=secret/ type=kv version=""
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variables:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: MiO51k1m0TV7o7CU4sfL+WAXUYPRYCzhjnAhusvIwxA=
Root Token: hvs.nX8Ji1bhdvVyIhjGYtWWjLRL

Development mode should NOT be used in production installations!
```

### Step 3: Set environment variables

1. Launch a new terminal session.
2. Copy and run the `export VAULT_ADDR ...` command from the terminal output. This will configure the Vault client to talk to the dev server.

```
export VAULT_ADDR='http://127.0.0.1:8200'
```

Vault CLI determines which Vault servers to send requests using the `VAULT_ADDR` environment variable.

3. Save the unseal key somewhere. Don't worry about *how* to save this securely. For now, just save it anywhere.
4. Set the `VAULT_TOKEN` environment variable value to the generated Root Token value displayed in the terminal output.

Example:

```
export VAULT_TOKEN="hvs.6j4cuewowBGit65rheNoceI7"
```

To interact with Vault, you must provide a valid token. Setting this environment variable is a way to provide the token to Vault via CLI. Later, in the [Authentication](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-authentication) tutorial, you will learn to use the `vault login <token_value>` command to authenticate with Vault.

##  Phase 2. Store the secret on the vault and retrive it.

### Step 1: Enable Key-Value (KV) Secret Engine

Enable the Key-Value (KV) version 1 secret engine for storing secrets:

```bash
vault secrets enable -path=profiles kv
```

We can setup the same configuration using the below terraform code.

```hcl
# Create a Vault KV version 1 mount for connection profiles.
resource "vault_mount" "ds_conn_profiles" {
  path = "profiles" # Mount path for connection profiles
  type = "kv"       # Mount type (KV version 1)
  options = {
    version = "1" # Specify KV version 1
  }
}
```

### Step 2: Store a Secret

Store a secret in Vault, for example, a PostgreSQL password:

```bash
vault kv put profiles/secret/postgresql_profile password=my_secret
```

Same can be done using terraform below.

```hcl
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
```

## Terraform Configuration to Extract Secret from Vault

Now that you have Vault set up with a stored secret, you can use Terraform to retrieve this secret for your infrastructure.
We are storing the secret for a postgresql database and retriving it to setup and connection profile for the Datastream on google.

```hcl
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
  project               = "my-project-id"                       # Project where the connection profile will be created
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

In this Terraform configuration:

- We create a Vault KV version 1 mount for connection profiles.
- A generic Vault secret is defined for storing the PostgreSQL password.
- The secret is retrieved from Vault using Terraform's `vault_generic_secret` data source.
- The secret information is exposed as an output, marked as sensitive to avoid exposing secrets in logs.
- Finally, a connection profile for PostgreSQL is created using a Terraform module, and the retrieved secret is used for configuration.

Ensure that you replace `"my-project-id"` and `"my_secret"` with appropriate values for your setup, and use Vault for securely storing and retrieving secrets in your infrastructure.
