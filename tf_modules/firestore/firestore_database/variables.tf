# We will have all the variables which is required for the setup for firestore.


variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "name" {

  description = <<EOF
    The ID to use for the database, which will become the final component of the database's resource name. 
    
    - This value should be 4-63 characters. 
    - Valid characters are /[a-z][0-9]-/ with first character a letter and the last a letter or a number. 
    - Must not be UUID-like /[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/. 
    - `"(default)"` database id is also valid.
    
  EOF
  type        = string
  validation {
    condition     = (length(var.name) >= 4 && length(var.name) <= 63) && (can(regex("^[[alpha]]*[[:alnum:]]+$", var.name)))
    error_message = "ERROR. Please check the \"name\". Below are the allowed formats.\n\n - This value should be 4-63 characters. \n - Valid characters are /[a-z][0-9]-/ with first character a letter and the last a letter or a number.\n - Must not be UUID-like /[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/.\n - \"(default)\" database id is also valid."
  }
}

variable "location_id" {
  description = "The location of the database. Available locations are listed at https://cloud.google.com/firestore/docs/locations."
  type        = string
  validation {
    condition     = contains(["nam5", "eur3"], var.location_id)
    error_message = "ERROR. Please check the \"location_id\". We accept \"nam5\" or \"eur3\" for multi-region setup, this is recommended for data resilience. "
  }
}

variable "type" {
  description = <<EOF
  The type of the database. 
  - Please See [firestore-or-datastore](https://cloud.google.com/datastore/docs/firestore-or-datastore) for information about how to choose. 
  - Possible values are: `FIRESTORE_NATIVE`, `DATASTORE_MODE`.
  EOF
  type        = string
  validation {
    condition     = contains(["FIRESTORE_NATIVE", "DATASTORE_MODE"], var.type)
    error_message = "ERROR. Please check \"type\". Possible values are: `FIRESTORE_NATIVE`, `DATASTORE_MODE`."
  }
}

variable "concurrency_mode" {
  description = <<EOF
  The concurrency control mode to use for this database. 
  Possible values are: `OPTIMISTIC`, `PESSIMISTIC`, `OPTIMISTIC_WITH_ENTITY_GROUPS`.
  EOF
  type        = string
  default     = null
  validation {
    condition     = contains(["OPTIMISTIC", "PESSIMISTIC", "OPTIMISTIC_WITH_ENTITY_GROUPS"], var.concurrency_mode == null ? "" : var.concurrency_mode) || var.concurrency_mode == null
    error_message = "ERROR. Please check \"concurrency_mode\". Possible values are: `OPTIMISTIC`, `PESSIMISTIC`, `OPTIMISTIC_WITH_ENTITY_GROUPS`."
  }
}

variable "app_engine_integration_mode" {
  description = "App Engine integration mode to use for this database. Possible values are: `ENABLED`, `DISABLED`."
  type        = string
  default     = null
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.app_engine_integration_mode == null ? "" : var.app_engine_integration_mode) || var.app_engine_integration_mode == null
    error_message = "ERROR. Please check \"app_engine_integration_mode\". Possible values are: `ENABLED`, `DISABLED`."
  }
}

variable "point_in_time_recovery_enablement" {
  description = <<EOF
  Whether to enable the PITR feature on this database. 
  
  - If `POINT_IN_TIME_RECOVERY_ENABLED` is selected, reads are supported on selected versions of the data from within the past 7 days. 
    - `versionRetentionPeriod` and `earliestVersionTime` can be used to determine the supported versions. 
    - These include reads against any timestamp within the past hour and reads against 1-minute snapshots beyond 1 hour and within 7 days. 
  - If `POINT_IN_TIME_RECOVERY_DISABLED` is selected, reads are supported on any version of the data from within the past 1 hour. 
  - Default value is `POINT_IN_TIME_RECOVERY_DISABLED`. 

  Possible values are: `POINT_IN_TIME_RECOVERY_ENABLED`, `POINT_IN_TIME_RECOVERY_DISABLED`.
  
  EOF
  type        = string
  default     = "POINT_IN_TIME_RECOVERY_DISABLED"
  validation {
    condition     = contains(["POINT_IN_TIME_RECOVERY_ENABLED", "POINT_IN_TIME_RECOVERY_DISABLED"], var.point_in_time_recovery_enablement)
    error_message = "ERROR. Please check \"point_in_time_recovery_enablement\". Possible values are: `POINT_IN_TIME_RECOVERY_ENABLED`, `POINT_IN_TIME_RECOVERY_DISABLED`."
  }
}

variable "delete_protection_state" {
  description = <<EOF
    State of delete protection for the database. 
    
    Possible values are: `DELETE_PROTECTION_STATE_UNSPECIFIED`, `DELETE_PROTECTION_ENABLED`, `DELETE_PROTECTION_DISABLED`.
    EOF
  type        = string
  default     = null
  validation {
    condition     = var.delete_protection_state == null || contains(["DELETE_PROTECTION_STATE_UNSPECIFIED", "DELETE_PROTECTION_ENABLED", "DELETE_PROTECTION_DISABLED"], var.delete_protection_state == null ? "" : var.delete_protection_state)
    error_message = "ERROR. Please check \"delete_protection_state\". Possible values are: `DELETE_PROTECTION_STATE_UNSPECIFIED`, `DELETE_PROTECTION_ENABLED`, `DELETE_PROTECTION_DISABLED`."
  }

}
