# Firestore Backup Schedule Example

This example helps in setting up a backup schedule for a Firestore instance in a GCP project.

## Example Information:

- **Source**: The relative path to the Firestore backup schedule Terraform module.
- **Project**: The ID of the project in which the Firestore instance resides.
- **Frequency**: Backup frequency. This can be set to either "`DAILY`" or "`WEEKLY`".
- **Retention**: The retention duration for the backup. It defines how long the backup will be retained. For example, "3d" means the backup will be retained for 3 days.
- **Database**: The ID of the Firestore database to be backed up. By default, it uses "`(default)`" which is the default Firestore database ID.
- **Day of the Week**: This is applicable only if the frequency is set to "`WEEKLY`". It specifies on which day of the week the backup should be taken.

## Usage:

To use this module in your Terraform configuration:

```hcl
module "backup_schedule" {
  source          = "<path_to_module>"
  project         = "<project_id>"
  frequency       = "<backup_frequency>"
  retention       = "<retention_period>"
  database        = "<database_id>"
  day_of_the_week = "<day_of_week>"
}
```

Replace `<placeholders>` with appropriate values for your setup.

:books: Note: Ensure that the retention format aligns with the frequency. Use "d" format (e.g., "3d") for `DAILY` backups and "w" format (e.g., "3w") for `WEEKLY` backups.