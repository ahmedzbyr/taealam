module "backup_schedule" {
  source          = "../../firestore_backup_schedule"
  project         = "elevated-column-400011"
  frequency       = "WEEKLY"
  retention       = "259200s"
  database        = "(default)"
  day_of_the_week = "MONDAY"
}
