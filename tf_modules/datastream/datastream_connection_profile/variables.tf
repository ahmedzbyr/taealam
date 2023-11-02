
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

# connection_profile_id - (Required) The connection_profile identifier.
variable "connection_profile_id" {
  description = "The connection_profile identifier."
  type        = string
}

# location - (Required) The name of the location this connection profile is located in.
variable "location" {
  description = "The name of the location this connection profile is located in."
  type        = string
  validation {
    condition = contains([
      "us-east1", "us-east5", "us-south1", "us-central1", "us-west4", "us-west2", "us-east4", "us-west1", "us-west3",
      "northamerica-northeast1", "southamerica-east1", "southamerica-west1", "northamerica-northeast2",
      "europe-west1", "europe-north1", "europe-west3", "europe-west2", "europe-southwest1", "europe-west8", "europe-west4", "europe-west9", "europe-west12", "europe-central2", "europe-west6",
      "asia-south2", "asia-east2", "asia-southeast2", "asia-south1", "asia-northeast2", "asia-northeast3", "asia-southeast1", "asia-east1", "asia-northeast1",
      "australia-southeast2", "australia-southeast1"
    ], var.location)
    error_message = "ERROR. Please check the \"location\". We accept below locations:\n\nUS Locations  - \"us-east1\", \"us-east5\", \"us-south1\", \"us-central1\", \"us-west4\", \"us-west2\", \"us-east4\", \"us-west1\", \"us-west3\",\nNorth America - \"northamerica-northeast1\", \"southamerica-east1\", \"southamerica-west1\", \"northamerica-northeast2\",\nEurope        - \"europe-west1\", \"europe-north1\", \"europe-west3\", \"europe-west2\", \"europe-southwest1\", \"europe-west8\", \"europe-west4\", \"europe-west9\", \"europe-west12\", \"europe-central2\", \"europe-west6\",\nAsia          - \"asia-south2\", \"asia-east2\", \"asia-southeast2\", \"asia-south1\", \"asia-northeast2\", \"asia-northeast3\", \"asia-southeast1\", \"asia-east1\", \"asia-northeast1\",\nAustralia     - \"australia-southeast2\", \"australia-southeast1\""

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

# oracle_profile - (Optional) Oracle database profile. 
variable "oracle_profile" {
  description = <<-EOF
  Oracle database profile.

  - `hostname` - (Required) Hostname for the Oracle connection.
  - `port`     - (Optional) Port for the Oracle connection, default value is 1521.
  - `username` - (Required) Username for the Oracle connection.
  - `password` - (Required) Password for the Oracle connection. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `database_service`      - (Required) Database for the Oracle connection.
  - `connection_attributes` - (Optional) `map (key: string, value: string)` Connection string attributes

  **JSON representation**

  ```
  {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,  // IMPORTANT: Use `var.secret` to set this variable.
    "database_service": string,
    "connection_attributes": {
        string: string,
        ...
    }
    
    # NOTE: Currently this is NOT present in terraform and will be added in the future.
    #       Here for information only.
    "oracle_ssl_config": {
      {
        "ca_certificate": string,
        "ca_certificate_set": boolean
      }
    }
  }
  ```  
  EOF
  type        = any
  default     = null
  validation {
    condition = var.oracle_profile == null ? true : (
      length(setsubtract(keys(var.oracle_profile), [
        "hostname",
        "username",
        "port",
        "database_service",
        "connection_attributes"
      ]))
    )
    error_message = "ERROR. Please check \"oracle_profile\". We expect only the below keys.\n\n- `hostname` - (Required) Hostname for the Oracle connection.\n- `port` - (Optional) Port for the Oracle connection, default value is 1521.\n- `username` - (Required) Username for the Oracle connection.\n- `password` - (Required) Password for the Oracle connection. :warning: IMPORTANT: Use `var.secret` to set this variable.\n- `database_service` - (Required) Database for the Oracle connection.\n- `connection_attributes` - (Optional) `map (key: string, value: string)` Connection string attributes"
  }
}

# gcs_profile - (Optional) Cloud Storage bucket profile. 
variable "gcs_profile" {
  description = <<-EOF
  "Cloud Storage bucket profile."

  - `bucket`   - (Required) The Cloud Storage bucket name.
  - `root_path` - (Optional) The root path inside the Cloud Storage bucket.

  **JSON representation**  
  ```   
  {
    "bucket": string,
    "root_path": string
  }
  ```      
  EOF
  type        = any
  default     = null
  validation {
    condition = var.gcs_profile == null ? true : (
      length(setsubtract(keys(var.gcs_profile), [
        "bucket",
        "root_path"
      ])) == 0
    )
    error_message = "ERROR. Please check \"gcs_profile\". We expect only the below keys.\n\n- `bucket`   - (Required) The Cloud Storage bucket name.\n- `root_path` - (Optional) The root path inside the Cloud Storage bucket."
  }
}

# mysql_profile - (Optional) MySQL database profile. 
variable "mysql_profile" {
  description = <<-EOF
  MySQL database profile.

  - `hostname`   - (Required) Hostname for the MySQL connection.
  - `port`       - (Optional) Port for the MySQL connection, default value is 3306.
  - `username`   - (Required) Username for the MySQL connection.
  - `password`   - (Required) Password for the MySQL connection. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `ssl_config` - (Optional) SSL configuration for the MySQL connection. Structure is documented below. 
  
  **`ssl_config`**

  - `ssl_config.client_key`     - (Optional) PEM-encoded private key associated with the Client Certificate. If this field is used then the 'client_certificate' and the 'ca_certificate' fields are mandatory. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `ssl_config.client_key_set` - (Output) Indicates whether the clientKey field is set.
  - `ssl_config.client_certificate`     - (Optional) PEM-encoded certificate that will be used by the replica to authenticate against the source database server. If this field is used then the 'clientKey' and the 'caCertificate' fields are mandatory. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `ssl_config.client_certificate_set` - (Output) Indicates whether the clientCertificate field is set.
  - `ssl_config.ca_certificate`     - (Optional) PEM-encoded certificate of the CA that signed the source database server's certificate. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `ssl_config.ca_certificate_set` - (Output) Indicates whether the clientKey field is set.

  **JSON representation**  
  ```   
  {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,  // IMPORTANT: Use `var.secret` to set this variable.
    "ssl_config": {
        {
        "client_key": string,         // IMPORTANT: Use `var.secret` to set this variable.
        "client_key_set": boolean,
        "client_certificate": string, // IMPORTANT: Use `var.secret` to set this variable. 
        "client_certificate_set": boolean,
        "ca_certificate": string,     // IMPORTANT: Use `var.secret` to set this variable.
        "ca_certificate_set": boolean
        }
    }
  }
  ```  
  EOF
  type        = any
  default     = null
  validation {
    condition = var.mysql_profile == null ? true : (
      length(setsubtract(keys(var.mysql_profile), [
        "hostname",
        "username",
        "port",
        "ssl_config"
      ]))
    )
    error_message = "ERROR. Please check \"mysql_profile\". We expect only the below keys.\n\n- `hostname` - (Required) Hostname for the MySQL connection.\n- `port` - (Optional) Port for the MySQL connection, default value is 3306.\n- `username` - (Required) Username for the MySQL connection.\n- `password` - (Required) Password for the MySQL connection. :warning: IMPORTANT: Use `var.secret` to set this variable.\n- `ssl_config` - (Optional) SSL configuration for the MySQL connection. Structure is documented below."
  }
}

# bigquery_profile - (Optional) BigQuery warehouse profile.
variable "bigquery_profile" {
  description = "BigQuery warehouse profile. This type has no fields."
  type        = any
  default     = null
  validation {
    condition     = var.bigquery_profile == null || var.bigquery_profile == {}
    error_message = "ERROR. Please check \"bigquery_profile\". We only accept {} for bigquery_profile."
  }
}

# postgresql_profile - (Optional) PostgreSQL database profile. 
variable "postgresql_profile" {
  description = <<-EOF
  PostgreSQL database profile.

  - `hostname` - (Required) Hostname for the PostgreSQL connection.
  - `port`     - (Optional) Port for the PostgreSQL connection, default value is 5432.
  - `username` - (Required) Username for the PostgreSQL connection.
  - `password` - (Required) Password for the PostgreSQL connection. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `database` - (Required) Database for the PostgreSQL connection.

  **JSON representation**
  ```
  {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string, // IMPORTANT: Use `var.secret` to set this variable.
    "database": string
  }
  ``` 
  EOF
  type        = any
  default     = null
  validation {
    condition = var.postgresql_profile == null ? true : (
      length(setsubtract(keys(var.postgresql_profile), [
        "hostname",
        "username",
        "port",
        "database"
      ]))
    )
    error_message = "ERROR. Please check \"postgresql_profile\". We expect only the below keys.\n\n- `hostname` - (Required) Hostname for the PostgreSQL connection.\n- `port` - (Optional) Port for the PostgreSQL connection, default value is 5432.\n- `username` - (Required) Username for the PostgreSQL connection.\n- `database` - (Required) Database for the PostgreSQL connection."
  }
}

variable "secret" {
  description = <<-EOF
  This variable serves as a secure container for storing sensitive information related to various profiles. 
  In the future, it will be configured to retrieve data from VAULT and populate this variable dynamically.


  Each profile's information is organized within the `secret` variable as follows:
  
  **Oracle Profile:**
    - `password` (string): Password for Oracle connections.
    - `ca_certificate` (string): CA certificate for Oracle connections.
  
  **PostgreSQL Profile:**
    - `password` (string): Password for PostgreSQL connections.
  
  **MySQL Profile:**
    - `password` (string): Password for MySQL connections.
    - `client_key` (string): Client key for MySQL connections.
    - `client_certificate` (string): Client certificate for MySQL connections.
    - `ca_certificate` (string): CA certificate for MySQL connections.
  
  **Forward SSH Tunnel Connectivity:**
    - `password` (string): Password for SSH tunnel connections.
    - `private_key` (string): Private SSH key for SSH tunnel connections.
  
  
  ```
    secret = {

      // Oracle secrets  
      oracle_profile = {
        password       = string
        ca_certificate = string 
      }  

      // PostgreSQL secrets
      postgresql_profile = {
        password = string
      }

      // MySQL secrets  
      mysql_profile = {
        password           = string
        client_key         = string
        client_certificate = string
        ca_certificate     = string 
      }

      // Forward SSH tunnel connectivity.   
      forward_ssh_connectivity = {
          password    = string  
          private_key = string
      }
    }
  ```
  The `secret` variable functions as a secure secret store, allowing the storage of confidential information required for various profiles. Its content will be dynamically managed through integration with `VAULT` in the future.

  EOF
  type        = any
  default     = null
  sensitive   = true

  validation {
    condition = var.secret == null ? true : (
      length(
        setsubtract(keys(var.secret), [
          "forward_ssh_connectivity",
          "mysql_profile",
          "oracle_profile",
          "postgresql_profile",
        ])
      ) == 0
    )
    error_message = "ERROR. Please check \"secret\". Please use the below information to set the secret.\n\nOracle Profile (oracle_profile):\n- password (string): Password for Oracle connections.\n- ca_certificate (string): CA certificate for Oracle connections.\n\nPostgreSQL Profile (postgresql_profile):\n- password (string): Password for PostgreSQL connections.\n\nMySQL Profile (mysql_profile):\n- password (string): Password for MySQL connections.\n- client_key (string): Client key for MySQL connections.\n- client_certificate (string): Client certificate for MySQL connections.\n- ca_certificate (string): CA certificate for MySQL connections.\n\nForward SSH Tunnel Connectivity (forward_ssh_connectivity):\n- password (string): Password for SSH tunnel connections.\n- private_key (string): Private SSH key for SSH tunnel connections.\n\nsecret = {\n\n  // Oracle secrets\n  oracle_profile = {\n    password = string\n    ca_certificate = string\n  }\n\n  // PostgreSQL secrets\n  postgresql_profile = {\n    password = string\n  }\n\n  // MySQL secrets\n  mysql_profile = {\n    password = string\n    client_key = string\n    client_certificate = string\n    ca_certificate = string\n  }\n\n  // Forward SSH tunnel connectivity.\n  forward_ssh_connectivity = {\n    password = string\n    private_key = string\n  }\n}"
  }
}

# forward_ssh_connectivity - (Optional) Forward SSH tunnel connectivity. 
variable "forward_ssh_connectivity" {
  description = <<-EOF
  Forward SSH tunnel connectivity.

  - `hostname` - (Required) Hostname for the SSH tunnel.
  - `username` - (Required) Username for the SSH tunnel.
  - `port`     - (Optional) Port for the SSH tunnel, default value is 22.

  NOTE: These are taken over the variables `secret` we do not accept passwords/private_key here. 

  - `password` - (Optional) SSH password. :warning: IMPORTANT: Use `var.secret` to set this variable.
  - `private_key` - (Optional) SSH private key. :warning: IMPORTANT: Use `var.secret` to set this variable.

  **JSON representation**
  ```
  {
    "hostname": string,
    "username": string,
    "port": integer,

    // Union field authentication_method can be only one of the following: 
    "password": string,   // IMPORTANT: Use var.secret for this instead
    "private_key": string // IMPORTANT: Use var.secret_key for this instead
    // End of list of possible types for union field authentication_method.
  }
  ```

  EOF
  type        = any
  default     = null
  validation {
    condition = var.forward_ssh_connectivity == null ? true : (
      length(setsubtract(keys(var.forward_ssh_connectivity), [
        "hostname",
        "username",
        "port"
      ]))
    )
    error_message = "ERROR. Please check \"forward_ssh_connectivity\". We expect only the below keys.\n\n - `hostname` - (Required) Hostname for the SSH tunnel.\n - `username` - (Required) Username for the SSH tunnel.\n - `port` - (Optional) Port for the SSH tunnel, default value is 22."
  }
}

# private_connectivity - (Optional) Private connectivity. 
variable "private_connectivity" {
  description = "Private connectivity. A reference to a private connection resource.\n Format: `projects/{project}/locations/{location}/privateConnections/{name}`"
  type        = any
  default     = null
  validation {
    condition     = var.private_connectivity == null || length(regexall("privateConnections", var.private_connectivity != null ? var.private_connectivity : "")) != 0
    error_message = "ERROR. Please check \"private_connectivity\".\nFormat for private_connectivity is \"projects/{project}/locations/{location}/privateConnections/{name}\"."
  }
}
