locals {

  #   check_secret_set_oracle       = var.oracle_profile != null && contains(keys(var.secret == null ? {} : var.secret), "oracle_profile")
  #   check_secret_set_mysql        = var.mysql_profile != null && contains(keys(var.secret == null ? {} : var.secret), "mysql_profile")
  #   check_secret_set_postgres     = var.postgresql_profile != null && contains(keys(var.secret == null ? {} : var.secret), "postgresql_profile")
  #   check_secret_set_fwd_ssh      = var.forward_ssh_connectivity != null && contains(keys(var.secret == null ? {} : var.secret), "forward_ssh_connectivity")
  #   check_for_non_secret_profiles = var.bigquery_profile != null || var.gcs_profile != null
  #   check_if_have_profile = local.check_secret_set_oracle || local.check_secret_set_mysql || local.check_secret_set_fwd_ssh || local.check_secret_set_postgres || local.check_for_non_secret_profiles

  oracle_only     = var.oracle_profile != null && var.bigquery_profile == null && var.gcs_profile == null && var.mysql_profile == null && var.postgresql_profile == null
  bigquery_only   = var.oracle_profile == null && var.bigquery_profile != null && var.gcs_profile == null && var.mysql_profile == null && var.postgresql_profile == null
  gcs_only        = var.oracle_profile == null && var.bigquery_profile == null && var.gcs_profile != null && var.mysql_profile == null && var.postgresql_profile == null
  mysql_only      = var.oracle_profile == null && var.bigquery_profile == null && var.gcs_profile == null && var.mysql_profile != null && var.postgresql_profile == null
  postgresql_only = var.oracle_profile == null && var.bigquery_profile == null && var.gcs_profile == null && var.mysql_profile == null && var.postgresql_profile != null

  # We need to make sure we have atleast one profile in the connection module 
  check_if_only_one_profile = local.oracle_only || local.bigquery_only || local.gcs_only || local.mysql_only || local.postgresql_only
}

resource "null_resource" "check_if_only_one_profile" {
  count = local.check_if_only_one_profile ? 0 : "ERROR. Please check if we have only one profile set."
}
