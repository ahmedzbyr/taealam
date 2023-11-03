## Setting Up HashiCorp Vault for Secret Management

In this comprehensive guide, we will walk you through the process of setting up HashiCorp Vault to effectively manage your secrets. The guide is divided into two phases:

### Phase 1: Setting Up Vault on a Workstation

In this phase, we'll cover the steps required to install and configure HashiCorp Vault on your workstation for secure secret management.

#### Step 1: Install HashiCorp Vault

Begin by installing HashiCorp Vault on your workstation. You can find platform-specific installation instructions in the official [HashiCorp Vault Installation Guide](https://learn.hashicorp.com/vault/getting-started/install).

#### Step 2: Start Vault Server

After successfully installing Vault, start the Vault server in development mode, which is ideal for testing purposes:

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

#### Step 3: Set Environment Variables

1. Open a new terminal session.
2. Copy and run the `export VAULT_ADDR ...` command from the terminal output. This command configures the Vault client to communicate with the development server:

   ```bash
   $ export VAULT_ADDR='http://127.0.0.1:8200'
   ```

   The `VAULT_ADDR` environment variable tells the Vault CLI where to send requests.

3. Save the unseal key securely. While this guide doesn't cover secure storage, ensure you keep it in a safe place for future use.
4. Set the `VAULT_TOKEN` environment variable to the generated root token from the terminal output:

   ```bash
   $ export VAULT_TOKEN="hvs.6j4cuewowBGit65rheNoceI7"
   ```

   This token is necessary for interacting with Vault via the CLI. In a production setup, take additional measures to manage tokens securely.

### Phase 2: Storing and Retrieving Secrets

In this phase, we'll demonstrate how to store and retrieve secrets using both the Vault CLI and Terraform.

#### Step 1: Enable Key-Value (KV) Secret Engine

Start by enabling the Key-Value (KV) version 1 secret engine for storing secrets:

```bash
vault secrets enable -path=profiles kv
```

Alternatively, you can achieve the same configuration using the following Terraform code:

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

#### Step 2: Store a Secret

Store a secret in Vault, such as a PostgreSQL password, using the Vault CLI:

```bash
vault kv put profiles/secret/postgresql_profile password=my_secret
```

Alternatively, you can store secrets using Terraform as shown below:

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

### Terraform Configuration for Extracting Secrets from Vault

Now that Vault is set up with stored secrets, you can utilize Terraform to extract these secrets for your infrastructure. In this example, we are storing a secret for a PostgreSQL database and retrieving it to configure a connection profile for Datastream on Google Cloud.

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
