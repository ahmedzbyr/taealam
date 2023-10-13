# Module for setting up Firestore Database on a project. 

resource "google_firestore_database" "main" {
  # Required
  project     = var.project
  name        = var.name
  location_id = var.location_id
  type        = var.type

  # Optional
  concurrency_mode                  = var.concurrency_mode
  app_engine_integration_mode       = var.app_engine_integration_mode
  point_in_time_recovery_enablement = var.point_in_time_recovery_enablement
  delete_protection_state           = var.delete_protection_state
}
