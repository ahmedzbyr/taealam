locals {
  check_daily_backup_retention  = var.frequency == "DAILY" && substr(var.retention, -1, 1) == "d"
  check_weekly_backup_retention = var.frequency == "WEEKLY" && substr(var.retention, -1, 1) == "w"
}

resource "null_resource" "check_rentention_is_valid" {
  count = local.check_daily_backup_retention || local.check_weekly_backup_retention ? 0 : "ERROR: For DAILY backups use retention as `d` format (3d), for WEEKLY backups use rention as `w` format (3w)."
}
