// Validations will go here 
// Coming soon

locals {
  check_back_fill = var.backfill_none == true && var.backfill_all != null
}

resource "null_resource" "check_back_fill" {
  count = local.check_back_fill ? "ERROR. backfill_none: only one of `backfill_all,backfill_none` can be specified, but `backfill_all,backfill_none` were specified." : 0
}
