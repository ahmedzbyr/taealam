variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "retention" {
  description = <<EOF
  Backup  rentention in days `3d` or weeks `3w` based on the frequency set.  

  We accept only `d` (day) or `w` (week).

  - If the frequency is selected as `DAILY` then use `d` with a min value of `3d` (3 days) and max value of `7d` (7 days) 
  - If the frequency is selected as `WEEKLY` then use `w` with a min value of `3w` (3 weeks) and max value of `14w` (14 weeks) 
  
  EOF
  type        = string
  default     = "3d"
  validation {
    condition     = (substr(var.retention, -1, 1) == "d" || substr(var.retention, -1, 1) == "w") && (substr(var.retention, -1, 1) == "d" ? (tonumber(split(substr(var.retention, -1, 1), var.retention)[0]) >= 3 && tonumber(split(substr(var.retention, -1, 1), var.retention)[0]) <= 7) : (tonumber(split(substr(var.retention, -1, 1), var.retention)[0]) >= 3 && tonumber(split(substr(var.retention, -1, 1), var.retention)[0]) <= 14))
    error_message = "ERROR. Please check the retention. We accept only `d` (day) or `w` (week).\n - If the frequency is selected as `DAILY` then use `d` with a min value of `3d` (3 days) and max value of `7d` (7 days).\n - If the frequency is selected as `WEEKLY` then use `w` with a min value of `3w` (3 weeks) and max value of `14w` (14 weeks)."
  }
}

variable "frequency" {
  description = "For a schedule that runs daily at a specified time. We only accept `DAILY`, `WEEKLY`."
  type        = string
  default     = "DAILY"
  validation {
    condition     = contains(["DAILY", "WEEKLY"], var.frequency)
    error_message = "ERROR. Please check \"frequency\". We only accept \"DAILY\", \"WEEKLY\"."
  }
}

variable "day_of_the_week" {
  description = <<EOF
  The day of week to run (only used if frequency == WEEKLY). 
  
  Possible values are: `DAY_OF_WEEK_UNSPECIFIED`, `MONDAY`, `TUESDAY`, `WEDNESDAY`, `THURSDAY`, `FRIDAY`, `SATURDAY`, `SUNDAY`.
  EOF
  type        = string
  default     = "SUNDAY"
  validation {
    condition     = contains(["DAY_OF_WEEK_UNSPECIFIED", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.day_of_the_week)
    error_message = "ERROR. Please check \"day_of_the_week\".\nAccepted values are: DAY_OF_WEEK_UNSPECIFIED, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY."
  }
}

variable "database" {
  description = "The Firestore database id. Defaults to `(default)`."
  type        = string
  default     = "(default)"
}
