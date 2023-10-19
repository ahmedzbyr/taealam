module "backup_schedule" {
  source          = "../../firestore_backup_schedule"
  project         = "elevated-column-400011"
  frequency       = "DAILY"
  retention       = "3d"
  database        = "(default)"
  day_of_the_week = "SUNDAY"
}
