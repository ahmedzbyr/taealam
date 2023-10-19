# This module creates a backup schedule for a Firestore instance.

# Use the "firestore_backup_schedule" module located at "../../firestore_backup_schedule".
module "backup_schedule" {
  # Path to the source module.
  source = "../../firestore_backup_schedule"

  # ID of the project in which the Firestore instance resides.
  project = "elevated-column-400011"

  # Backup frequency. Can be "DAILY" or "WEEKLY".
  frequency = "DAILY"

  # Retention duration for the backup. 
  # Here, "3d" means the backup will be retained for 3 days.
  retention = "3d"

  # ID of the Firestore database to be backed up.
  # "(default)" is the default Firestore database ID.
  database = "(default)"

  # Day of the week for the backup. Only applicable if frequency is "WEEKLY".
  # Since the frequency above is "DAILY", this value won't be used.
  day_of_the_week = "SUNDAY"
}
