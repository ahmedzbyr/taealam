<!-- BEGIN_TF_DOCS -->

#  Datastream Connection Profile

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connection_profile_id"></a> [connection\_profile\_id](#input\_connection\_profile\_id) | The connection\_profile identifier. | `string` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name. | `string` | n/a | yes |
| <a name="input_gcs_profile"></a> [gcs\_profile](#input\_gcs\_profile) | "Cloud Storage bucket profile."<br><br>- `bucket`   - (Required) The Cloud Storage bucket name.<br>- `root_path` - (Optional) The root path inside the Cloud Storage bucket.<br><br>**JSON representation**<pre>{<br>  "bucket": string,<br>  "root_path": string<br>}</pre> | `any` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels for the connection. <br><br>Note: This field is non-authoritative, and will only manage the labels present in your configuration. Also please refer to the field `effective_labels` for all of the labels present on the resource.<br><br>`effective_labels` - All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services. | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The name of the location this connection profile is located in. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_bigquery_profile"></a> [bigquery\_profile](#input\_bigquery\_profile) | BigQuery warehouse profile. This type has no fields. | `any` | `null` | no |
| <a name="input_forward_ssh_connectivity"></a> [forward\_ssh\_connectivity](#input\_forward\_ssh\_connectivity) | Forward SSH tunnel connectivity.<br><br>- `hostname` - (Required) Hostname for the SSH tunnel.<br>- `username` - (Required) Username for the SSH tunnel.<br>- `port`     - (Optional) Port for the SSH tunnel, default value is 22.<br>- `password` - (Optional) SSH password. :warning: **Note:** This property is sensitive and will not be displayed in the plan.<br>- `private_key` - (Optional) SSH private key. :warning: **Note:** This property is sensitive and will not be displayed in the plan.<br><br>**JSON representation**<pre>{<br>  "hostname": string,<br>  "username": string,<br>  "port": integer,<br><br>  // Union field authentication_method can be only one of the following:<br>  "password": string,<br>  "private_key": string<br>  // End of list of possible types for union field authentication_method.<br>}</pre> | `any` | `null` | no |
| <a name="input_mysql_profile"></a> [mysql\_profile](#input\_mysql\_profile) | MySQL database profile.<br><br>- `hostname`   - (Required) Hostname for the MySQL connection.<br>- `port`       - (Optional) Port for the MySQL connection, default value is 3306.<br>- `username`   - (Required) Username for the MySQL connection.<br>- `password`   - (Required) Password for the MySQL connection. Note: This property is sensitive and will not be displayed in the plan.<br>- `ssl_config` - (Optional) SSL configuration for the MySQL connection. Structure is documented below. <br><br>**`ssl_config`**<br><br>- `ssl_config.client_key`     - (Optional) PEM-encoded private key associated with the Client Certificate. If this field is used then the 'client\_certificate' and the 'ca\_certificate' fields are mandatory. Note: This property is sensitive and will not be displayed in the plan.<br>- `ssl_config.client_key_set` - (Output) Indicates whether the clientKey field is set.<br>- `ssl_config.client_certificate`     - (Optional) PEM-encoded certificate that will be used by the replica to authenticate against the source database server. If this field is used then the 'clientKey' and the 'caCertificate' fields are mandatory. Note: This property is sensitive and will not be displayed in the plan.<br>- `ssl_config.client_certificate_set` - (Output) Indicates whether the clientCertificate field is set.<br>- `ssl_config.ca_certificate`     - (Optional) PEM-encoded certificate of the CA that signed the source database server's certificate. Note: This property is sensitive and will not be displayed in the plan.<br>- `ssl_config.ca_certificate_set` - (Output) Indicates whether the clientKey field is set.<br><br>**JSON representation**<pre>{<br>  "hostname": string,<br>  "port": integer,<br>  "username": string,<br>  "password": string,<br>  "ssl_config": {<br>      {<br>      "client_key": string,<br>      "client_key_set": boolean,<br>      "client_certificate": string,<br>      "client_certificate_set": boolean,<br>      "ca_certificate": string,<br>      "ca_certificate_set": boolean<br>      }<br>  }<br>}</pre> | `any` | `null` | no |
| <a name="input_oracle_profile"></a> [oracle\_profile](#input\_oracle\_profile) | Oracle database profile.<br><br>- `hostname` - (Required) Hostname for the Oracle connection.<br>- `port`     - (Optional) Port for the Oracle connection, default value is 1521.<br>- `username` - (Required) Username for the Oracle connection.<br>- `password` - (Required) Password for the Oracle connection. Note: This property is sensitive and will not be displayed in the plan.<br>- `database_service`      - (Required) Database for the Oracle connection.<br>- `connection_attributes` - (Optional) `map (key: string, value: string)` Connection string attributes<br><br>**JSON representation**<pre>{<br>  "hostname": string,<br>  "port": integer,<br>  "username": string,<br>  "password": string,<br>  "database_service": string,<br>  "connection_attributes": {<br>      string: string,<br>      ...<br>  }<br>    <br>  # NOTE: Currently this is NOT present in terraform and will be added in the future.<br>  #       Here for information only.<br>  "oracle_ssl_config": {<br>    {<br>      "ca_certificate": string,<br>      "ca_certificate_set": boolean<br>    }<br>  }<br>}</pre> | `any` | `null` | no |
| <a name="input_postgresql_profile"></a> [postgresql\_profile](#input\_postgresql\_profile) | PostgreSQL database profile.<br><br>- `hostname` - (Required) Hostname for the PostgreSQL connection.<br>- `port`     - (Optional) Port for the PostgreSQL connection, default value is 5432.<br>- `username` - (Required) Username for the PostgreSQL connection.<br>- `password` - (Required) Password for the PostgreSQL connection. :warning: **Note:** This property is sensitive and will not be displayed in the plan.<br>- `database` - (Required) Database for the PostgreSQL connection.<br><br>**JSON representation**<pre>{<br>  "hostname": string,<br>  "port": integer,<br>  "username": string,<br>  "password": string,<br>  "database": string<br>}</pre> | `any` | `null` | no |
| <a name="input_private_connectivity"></a> [private\_connectivity](#input\_private\_connectivity) | Private connectivity. A reference to a private connection resource.<br> Format: `projects/{project}/locations/{location}/privateConnections/{name}` | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_connection_profile_effective_labels"></a> [this\_connection\_profile\_effective\_labels](#output\_this\_connection\_profile\_effective\_labels) | All of labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform, other clients and services. |
| <a name="output_this_connection_profile_id"></a> [this\_connection\_profile\_id](#output\_this\_connection\_profile\_id) | An identifier for the resource with format `projects/{{project}}/locations/{{location}}/connectionProfiles/{{connection_profile_id}}` |
| <a name="output_this_connection_profile_name"></a> [this\_connection\_profile\_name](#output\_this\_connection\_profile\_name) | The resource's name. |
| <a name="output_this_connection_profile_terraform_labels"></a> [this\_connection\_profile\_terraform\_labels](#output\_this\_connection\_profile\_terraform\_labels) | The combination of labels configured directly on the resource and default labels configured on the provider. |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.4.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_datastream_connection_profile.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/datastream_connection_profile) | resource |


##  Example - Create a connection profile for Oracle database

| Field                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Connection profile name | Enter the display name of the connection profile to the source Oracle database. This is used in the connection profile list as well as when an existing connection profile is selected in the creation of a stream.                                                                                                                                                                                                                                          |
| Connection profile ID   | Datastream populates this field automatically based on the connection profile name that you enter. You can keep the ID that's auto-generated or change it.                                                                                                                                                                                                                                                                                                   |
| Region                  | Select the region where the connection profile is stored. Connection profiles, like all resources, are saved in a region, and a stream can only use connection profiles that are stored in the same region as the stream. Region selection doesn't impact whether Datastream can connect to the source or the destination, but can impact availability if the region experiences downtime.                                                                   |
| Hostname or IP          | Enter a hostname or IP address that Datastream can use to connect to the source Oracle database. If you're using private connectivity to communicate with the source database, then specify the private (internal) IP address for the source database. :books: NOTE: If you're using a reverse proxy for private connectivity, then use the IP address of the proxy. For other connectivity methods, such as IP allowlisting, provide the public IP address. |
| Port                    | Enter the port number that's reserved for the source database (The default port is typically 1521.).                                                                                                                                                                                                                                                                                                                                                         |
| Username                | Enter the username of the account for the source database (for example, ROOT). This is the Datastream user that you created for the database. For more information about creating this user, see Configure your source Oracle database.                                                                                                                                                                                                                      |
| Password                | Enter the password of the account for the source database.                                                                                                                                                                                                                                                                                                                                                                                                   |
| System identifier (SID) | Enter the service that ensures that the source Oracle database is protected and monitored. For Oracle databases, the database service is typically ORCL. For pluggable databases, SID is the pluggable database name.                                                                                                                                                                                                                                        |

### JSON representation

```json
{
  "project": string,
  "display_name": string,
  "connection_profile_id": string,
  "lcoation": string,
  "labels": {
    string: string,
    ...
  },
  "display_name": string,
  "oracle_profile": {
    "hostname": string,
    "port": integer,
    "username": string,
    "password": string,
    "database_service": string,
    "connection_attributes": {
      string: string,
      ...
    }
  }
}
```

###  Connectivity Methods

1. Select a network connectivity method for Datastream from the following options:
   - IP allowlisting
   - Forward-SSH tunnel
   - Private connectivity (VPC peering) **[Recommended for External Sources like `AWS`]**

2. If you choose "**Forward-SSH tunnel**" as the network connectivity method:
   - Enter the hostname or IP address and port of the tunnel host server.
   - Specify the username of the account for the tunnel host server.
   - Select the authentication method for the SSH tunnel, either "Password" or "Private/Public key pair."
   - Provide the password of the account for the bastion host VM (if using Password as the authentication method) or provide a private key (if using Private/Public key pair).
   - Configure the tunnel host to allow incoming connections from the Datastream public IP addresses for the specified region.

3. If you choose "**Private connectivity (VPC peering)**" as the network connectivity method:
   - Establish secure connectivity between Datastream and the source database, either internally within Google Cloud or with external sources connected over VPN or Interconnect.
   - Select a private connectivity configuration from the list if you've created one, containing information for Datastream to communicate with the source database over a private network.
   - If you haven't created a private connectivity configuration, you can create one by clicking "CREATE PRIVATE CONNECTIVITY CONFIGURATION" at the bottom of the drop-down list and following the steps to create it.

---
<!-- END_TF_DOCS -->    