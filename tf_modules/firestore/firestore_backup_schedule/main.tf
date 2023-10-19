resource "google_firestore_backup_schedule" "main" {
  project   = var.project
  retention = var.retention
  database  = var.database

  # For a schedule that runs daily at a specified time.
  dynamic "daily_recurrence" {
    for_each = var.frequency == "DAILY" ? [1] : []
    content {}
  }

  # For a schedule that runs weekly on a specific day and time. 
  dynamic "weekly_recurrence" {
    for_each = var.frequency == "WEEKLY" ? [1] : []
    content {
      day = var.day_of_the_week
    }
  }
}
