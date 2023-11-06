# Local values to hold the result of various validation conditions
locals {
  # Check if both backfill_none is true and backfill_all is not null, which is likely a misconfiguration
  check_back_fill = var.backfill_none == true && var.backfill_all != null

  # Check if all source configurations are provided, which is likely an error as typically only one should be specified
  check_not_all_source_null = var.postgresql_source_config != null && var.oracle_source_config != null && var.mysql_source_config != null

  # Check if all destination configurations are NOT provided, which is likely an error as only one destination should be specified
  check_not_all_destination_null = var.gcs_destination_config == null && var.bigquery_destination_config == null

  # Check if all destination configurations are provided, which is likely an error as only one destination should be specified
  check_all_destination_not_null = var.gcs_destination_config != null && var.bigquery_destination_config != null

  # Check if only PostgreSQL source is provided and others are null, which is a valid scenario
  check_if_only_postgres_source = var.postgresql_source_config != null && var.oracle_source_config == null && var.mysql_source_config == null

  # Check if only Oracle source is provided and others are null, which is a valid scenario
  check_if_only_oracle_source = var.postgresql_source_config == null && var.oracle_source_config != null && var.mysql_source_config == null

  # Check if only MySQL source is provided and others are null, which is a valid scenario
  check_if_only_mysql_source = var.postgresql_source_config == null && var.oracle_source_config == null && var.mysql_source_config != null

  # Check if exactly one source is provided, which is the required condition for proper configuration
  check_if_only_one_source = local.check_if_only_postgres_source || local.check_if_only_oracle_source || local.check_if_only_mysql_source
}

# Resource blocks to throw errors if the validations fail
resource "null_resource" "check_back_fill" {
  # If the check_back_fill condition is true, raise an error indicating the configuration conflict
  count = local.check_back_fill ? "ERROR. We cannot specify both `backfill_none` and `backfill_all`, please choose one of them." : 0
}

resource "null_resource" "check_not_all_source_null" {
  # If the check_not_all_source_null condition is true, raise an error indicating that no source was provided when one is required
  count = local.check_not_all_source_null ? "ERROR. Please have one source, but NO source was provided." : 0
}

resource "null_resource" "check_not_all_destination_null" {
  # If the check_not_all_destination_null condition is true, raise an error indicating that no destination was provided when one is required
  count = local.check_not_all_destination_null ? "ERROR. Please have one destination, but NO destination was provided." : 0
}

resource "null_resource" "check_all_destination_not_null" {
  # If the check_all_destination_not_null condition is true, raise an error indicating that more than one destination was provided when one is required
  count = local.check_all_destination_not_null ? "ERROR. Please have one destination, but More then one destination was provided." : 0
}

resource "null_resource" "check_if_only_one_source" {
  # If the check_if_only_one_source condition is false, raise an error indicating that exactly one source is required
  count = !(local.check_if_only_one_source) ? "ERROR. Please check source, we can only have ONE source." : 0
}
