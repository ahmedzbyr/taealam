output "this_backup_schedule_id" {
  description = "An identifier for the resource with format projects/{{project}}/databases/{{database}}/backupSchedules/{{name}}"
  value       = google_firestore_backup_schedule.main.id
}

output "this_backup_schedule_name" {
  description = "The unique backup schedule identifier across all locations and databases for the given project. Format: `projects/{{project}}/databases/{{database}}/backupSchedules/{{backupSchedule}}`"
  value       = google_firestore_backup_schedule.main.name
}
