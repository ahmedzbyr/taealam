# Region variable
# Specifies the geographic region where the resources will be deployed.
# Type: string
variable "region" {
  description = "The geographic region for deploying resources."
  type        = string
  default     = "us-east1"
}

# Project variable
# Identifies the Google Cloud project to which resources belong.
# Type: string
variable "project" {
  description = "The Google Cloud project ID."
  type        = string
  default     = "my-project-id"
}

# User variable
# Represents a username used in resource configurations, such as database users.
# Type: string
variable "user" {
  description = "The username used for configuring resources."
  type        = string
  default     = "datastream"
}

# Private Connection variable
# Private connection CIDR /29 network
# Type: string
variable "private_connection_cidr" {
  description = "Private connection CIDR for the connection."
  type        = string
  default     = "172.31.200.0/29"
}

# Ports to allow variable
# Ports to allow for inbound connections
# Type: list
variable "ports_to_allow" {
  description = "Ports allowed inbound in to the network to connection to Proxy."
  type        = list(string)
  default     = ["3306", "5432"]
}


# Ports to allow variable
# Ports to allow for inbound connections
# Type: list
variable "cloud_sql_proxy_version" {
  description = "Cloud SQL proxy binary version to download."
  type        = string
  default     = "v2.7.2"
}
