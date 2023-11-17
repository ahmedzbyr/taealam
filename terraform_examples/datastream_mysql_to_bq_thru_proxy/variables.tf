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
