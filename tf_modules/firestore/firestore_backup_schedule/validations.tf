# Local variables to check the retention format based on the backup frequency.
locals {
  # Check if frequency is DAILY and retention format ends with "d".
  check_daily_backup_retention = var.frequency == "DAILY" && substr(var.retention, -1, 1) == "d"

  # Check if frequency is WEEKLY and retention format ends with "w".
  check_weekly_backup_retention = var.frequency == "WEEKLY" && substr(var.retention, -1, 1) == "w"
}

# A null resource that checks for the validity of the retention format.
resource "null_resource" "check_rentention_is_valid" {
  # Count is used to determine if the resource should be created or not.
  # If either daily or weekly retention check passes, count will be 0 (resource will not be created).
  # Otherwise, an error message is returned to inform the user of the correct format.
  count = local.check_daily_backup_retention || local.check_weekly_backup_retention ? 0 : "ERROR: For DAILY backups use retention as `d` format (3d), for WEEKLY backups use retention as `w` format (3w)."
}
