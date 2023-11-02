
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
  - `password` - (Required) Password for the Oracle connection. Note: This property is sensitive and will not be displayed in the plan.
  - `database_service`      - (Required) Database for the Oracle connection.
  - `connection_attributes` - (Optional) `map (key: string, value: string)` Connection string attributes

  **JSON representation**

  ```
  {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
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
}

# mysql_profile - (Optional) MySQL database profile. 
variable "mysql_profile" {
  description = <<-EOF
  MySQL database profile.

  - `hostname`   - (Required) Hostname for the MySQL connection.
  - `port`       - (Optional) Port for the MySQL connection, default value is 3306.
  - `username`   - (Required) Username for the MySQL connection.
  - `password`   - (Required) Password for the MySQL connection. Note: This property is sensitive and will not be displayed in the plan.
  - `ssl_config` - (Optional) SSL configuration for the MySQL connection. Structure is documented below. 
  
  **`ssl_config`**

  - `ssl_config.client_key`     - (Optional) PEM-encoded private key associated with the Client Certificate. If this field is used then the 'client_certificate' and the 'ca_certificate' fields are mandatory. Note: This property is sensitive and will not be displayed in the plan.
  - `ssl_config.client_key_set` - (Output) Indicates whether the clientKey field is set.
  - `ssl_config.client_certificate`     - (Optional) PEM-encoded certificate that will be used by the replica to authenticate against the source database server. If this field is used then the 'clientKey' and the 'caCertificate' fields are mandatory. Note: This property is sensitive and will not be displayed in the plan.
  - `ssl_config.client_certificate_set` - (Output) Indicates whether the clientCertificate field is set.
  - `ssl_config.ca_certificate`     - (Optional) PEM-encoded certificate of the CA that signed the source database server's certificate. Note: This property is sensitive and will not be displayed in the plan.
  - `ssl_config.ca_certificate_set` - (Output) Indicates whether the clientKey field is set.

  **JSON representation**  
  ```   
  {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
    "ssl_config": {
        {
        "client_key": string,
        "client_key_set": boolean,
        "client_certificate": string,
        "client_certificate_set": boolean,
        "ca_certificate": string,
        "ca_certificate_set": boolean
        }
    }
  }
  ```  
  EOF
  type        = any
  default     = null
}

# bigquery_profile - (Optional) BigQuery warehouse profile.
variable "bigquery_profile" {
  description = "BigQuery warehouse profile. This type has no fields."
  type        = any
  default     = null
}

# postgresql_profile - (Optional) PostgreSQL database profile. 
variable "postgresql_profile" {
  description = <<-EOF
  PostgreSQL database profile.

  - `hostname` - (Required) Hostname for the PostgreSQL connection.
  - `port`     - (Optional) Port for the PostgreSQL connection, default value is 5432.
  - `username` - (Required) Username for the PostgreSQL connection.
  - `password` - (Required) Password for the PostgreSQL connection. :warning: **Note:** This property is sensitive and will not be displayed in the plan.
  - `database` - (Required) Database for the PostgreSQL connection.

  **JSON representation**
  ```
  {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
    "database": string
  }
  ``` 
  EOF
  type        = any
  default     = null
}

# forward_ssh_connectivity - (Optional) Forward SSH tunnel connectivity. 
variable "forward_ssh_connectivity" {
  description = <<-EOF
  Forward SSH tunnel connectivity.

  - `hostname` - (Required) Hostname for the SSH tunnel.
  - `username` - (Required) Username for the SSH tunnel.
  - `port`     - (Optional) Port for the SSH tunnel, default value is 22.
  - `password` - (Optional) SSH password. :warning: **Note:** This property is sensitive and will not be displayed in the plan.
  - `private_key` - (Optional) SSH private key. :warning: **Note:** This property is sensitive and will not be displayed in the plan.

  **JSON representation**
  ```
  {
    "hostname": string,
    "username": string,
    "port": integer,

    // Union field authentication_method can be only one of the following:
    "password": string,
    "private_key": string
    // End of list of possible types for union field authentication_method.
  }
  ```

  EOF
  type        = any
  default     = null
}

# private_connectivity - (Optional) Private connectivity. 
variable "private_connectivity" {
  description = "Private connectivity. A reference to a private connection resource.\n Format: `projects/{project}/locations/{location}/privateConnections/{name}`"
  type        = any
  default     = null
}
