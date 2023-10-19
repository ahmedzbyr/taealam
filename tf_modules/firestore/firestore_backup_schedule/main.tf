# Local value calculations
locals {
  # Convert the retention duration from days or weeks to seconds. 
  # If the last character of var.retention is 'd', it's treated as days, otherwise it's treated as weeks.
  retention_to_seconds = "${substr(var.retention, -1, 1) == "d" ? tonumber(split(substr(var.retention, -1, 1), var.retention)[0]) * 60 * 60 * 24 : tonumber(split(substr(var.retention, -1, 1), var.retention)[0]) * 60 * 60 * 24 * 7}s"
}

# Resource definition for the Firestore backup schedule
resource "google_firestore_backup_schedule" "main" {
  # The project where the Firestore backup schedule should be created
  project = var.project

  # The retention duration in seconds
  retention = local.retention_to_seconds

  # The Firestore database id (defaults to "(default)" if not provided)
  database = var.database

  # Define a daily recurrence schedule if var.frequency is set to "DAILY"
  dynamic "daily_recurrence" {
    # If frequency is set to DAILY, create one daily_recurrence block, otherwise none
    for_each = var.frequency == "DAILY" ? [1] : []
    content {}
  }

  # Define a weekly recurrence schedule if var.frequency is set to "WEEKLY"
  dynamic "weekly_recurrence" {
    # If frequency is set to WEEKLY, create one weekly_recurrence block, otherwise none
    for_each = var.frequency == "WEEKLY" ? [1] : []
    content {
      # Set the day of the week on which the backup should run (e.g., MONDAY, TUESDAY, etc.)
      day = var.day_of_the_week
    }
  }
}
