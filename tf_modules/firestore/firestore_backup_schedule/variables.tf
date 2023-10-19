variable "project" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "retention" {
  description = <<EOF
  At what relative time in the future, compared to its creation time, the backup should be deleted, 
  e.g. keep backups for 7 days. A duration in seconds with up to nine fractional digits, ending with 's'. 
  
  Example: "3.5s". For a daily backup recurrence, set this to a value up to 7 days. 
  If you set a weekly backup recurrence, set this to a value up to 14 weeks.
  
  EOF
  type        = string

}

variable "frequency" {
  description = "For a schedule that runs daily at a specified time."
  type        = string
}

variable "day_of_the_week" {
  description = "The day of week to run (only used if frequency == WEEKLY). Possible values are: DAY_OF_WEEK_UNSPECIFIED, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY."
  type        = string
  default     = "SUNDAY"
}

variable "database" {
  description = "The Firestore database id. Defaults to `(default)`."
  type        = string
  default     = "(default)"
}
