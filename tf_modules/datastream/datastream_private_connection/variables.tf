
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

# private_connection_id - (Required) The private_connection identifier.
variable "private_connection_id" {
  description = "The private connection identifier."
  type        = string
}

# location - (Required) The name of the location this connection profile is located in.
variable "location" {
  description = "The name of the location this private connection is located in."
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

variable "vpc_peering_config" {
  description = <<-EOF
  The VPC Peering configuration is used to create VPC peering between Datastream and the consumer's VPC.

  `vpc`    - (Required) Fully qualified name of the VPC that Datastream will peer to. Format: `projects/{project}/global/{networks}/{name}` 
  `subnet` - (Required) A free subnet for peering. (CIDR of /29)

  **JSON representation**
  ```
  {
    "vpc": string,
    "subnet": string
  }
  ```
  EOF
  type        = any
  validation {
    condition = length(setsubtract(keys(var.vpc_peering_config), [
      "vpc",
      "subnet"
    ])) == 0
    error_message = "ERROR. Please check \"vpc_peering_config\". We accept \"vpc\" and \"subnet\"."
  }
}
