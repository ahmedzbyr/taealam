variable "bucket_name" {
  description = "The name of the bucket."
  type        = string
}

variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = "my-project"
}

variable "location" {
  description = "The [GCS location](https://cloud.google.com/storage/docs/locations)."
  type        = string
  default     = "US"
  validation {
    # Adding these conditions to show how we can limit the locations based on requirments
    condition     = contains(["US", "EU", "US-CENTRAL1", "US-EAST1", "US-WEST1", "US-WEST2"], var.location)
    error_message = "ERROR Location: We can only select options - US, EU, US-CENTRAL1, US-EAST1, US-WEST1, US-WEST2."
  }
}

variable "storage_class" {
  description = "The Storage Class of the new bucket. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  type        = string
  default     = "MULTI_REGIONAL"
  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "ERROR Storage Class: We can only select options - STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "access_permissions" {
  description = "Access permission to the bucket."
  type        = any
  default     = []
  validation {
    condition = alltrue([
      for map_key in
      distinct(
        flatten([
          for each_access in var.access_permissions : keys(each_access)
        ])
    ) : contains(["permission", "group", "service_account"], map_key)])
    error_message = "ERROR Access Permissions: We only accept these keys on the access list - service_accounts, permission, groups."
  }
}
